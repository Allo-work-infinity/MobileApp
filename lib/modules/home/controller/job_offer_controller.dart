// lib/modules/home/controller/job_offer_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:job_finding/core/api_exceptions.dart';

import '../repository/job_offer_repository.dart';
import '../model/job_offer.dart';

/// Controller for listing & viewing JobOffers using JobOfferRepository.
class JobOfferController extends ChangeNotifier {
  final JobOfferRepository _repo;
  String? categoryName;
  JobOfferController(this._repo);

  // ------------ State ------------
  List<JobOffer> _items = const [];
  PageMeta? _meta;
  JobOffer? _selected;

  bool _initializing = true;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;

  // ------------ Active filter (server-side) ------------
  /// One of: 'open' (default) | 'all' | 'my-offer' | 'featured' | 'remote' | 'popular'
  String _activeFilter = 'open';

  // ------------ Query params (server) ------------
  String? q;
  int? companyId;
  String? jobType;           // 'full_time' | 'part_time' | 'contract' | 'internship' | 'remote'
  String? experienceLevel;   // 'entry' | 'junior' | 'mid' | 'senior' | 'lead'
  String? city;
  String? governorate;
  double? minSalary;
  double? maxSalary;
  String? deadlineBefore;    // YYYY-MM-DD
  String? deadlineAfter;     // YYYY-MM-DD
  List<int> ids = const [];

  // NEW: Category filters
  int? categoryId;
  List<int> categoryIds = const [];
  String? categorySlug;                 // single slug
  List<String> categorySlugs = const []; // multiple slugs
  String? categoryMode;                 // 'all' | 'any' (default null -> server default)

  bool includeClosed = false;
  bool? withCompany;  // null = don't send the param
  bool withPlans = false;
  bool? remoteAllowed;       // true/false -> sent as 1/0
  bool? isFeatured;          // true/false -> sent as 1/0

  String sort = 'created_at';
  String order = 'desc';

  int perPage = 15; // used only if backend returns pagination
  int page = 1;

  // add state
  bool _cooldownActive = false;
  DateTime? _retryAt;
  int? _retryAfterSeconds;

// getters
  bool get cooldownActive => _cooldownActive;
  DateTime? get retryAt => _retryAt;
  int? get retryAfterSeconds => _retryAfterSeconds;
  void _clearCooldown() {
    _cooldownActive = false;
    _retryAt = null;
    _retryAfterSeconds = null;
  }
  // ------------ Getters ------------
  List<JobOffer> get items => _items;
  PageMeta? get meta => _meta;
  JobOffer? get selected => _selected;

  bool get initializing => _initializing;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;

  String get activeFilter => _activeFilter;

  bool get hasMore {
    final m = _meta;
    if (m == null) return false; // bare list -> no pagination
    return page < m.lastPage;
  }

  int get totalCount {
    final m = _meta;
    if (m == null) return _items.length;
    return m.total;
  }

  // =====================================================
  // Lifecycle
  // =====================================================

  /// Decide automatically: if [filterOrCategory] is a known server filter, use it.
  /// Otherwise treat it as a **category name** and send `category_slug`.
  Future<void> initByFilterOrCategory({
    required String filterOrCategory,
    Map<String, dynamic>? params,
  }) async {
    final v = filterOrCategory.trim();
    final normalized = _normalizeFilter(v);

    if (normalized != 'open' || _isKnownFilter(v)) {
      // known server filter
      await init(
        filter: normalized,
        clearCategories: true,
        clearSearch: !(params?.containsKey('q') ?? false), // keep q only if provided now
      );
      if (params != null && params.isNotEmpty) {
        await load(params: params);
      }
      return;
    }

    // ----- category path -----
    _initializing = true;
    notifyListeners();
    try {
      _error = null;
      // Clear previous category filters, then set new slug/name
      _clearCategoryFilters();
      categorySlug = null;
      categoryName = v;

      q = null; // <<< IMPORTANT: drop previous search text

      await firstPage();
    } catch (e) {
      _error = e.toString();
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }


  /// Call when the screen opens (explicit server filter).
  Future<void> init({String filter = 'open', bool clearCategories = true, bool clearSearch = true}) async {
    _initializing = true;
    if (clearCategories) _clearCategoryFilters();
    if (clearSearch) q = null;                 // <<< new line
    _activeFilter = _normalizeFilter(filter);
    notifyListeners();
    try {
      _error = null;
      await firstPage();
    } catch (e) {
      _error = e.toString();
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }


  // Future<void> initByFilterOrCategory({
  //   required String filterOrCategory,
  //   Map<String, dynamic>? params,
  // }) async {
  //   final v = filterOrCategory.trim();
  //   final normalized = _normalizeFilter(v);
  //
  //   if (_isKnownFilter(v)) {                       // ✅ only for known server filters
  //     await init(filter: normalized, clearCategories: true);
  //     if (params != null && params.isNotEmpty) {
  //       await load(params: params);
  //     }
  //     return;
  //   }
  //
  //   // --- Category path (unchanged) ---
  //   _initializing = true;
  //   notifyListeners();
  //   try {
  //     _error = null;
  //     // Clear previous category filters, then set new category
  //     _clearCategoryFilters();
  //     categorySlug = _slugify(v);
  //     categoryName = v;
  //     await firstPage();
  //   } catch (e) {
  //     _error = e.toString();
  //   } finally {
  //     _initializing = false;
  //     notifyListeners();
  //   }
  // }


  // =====================================================
  // Loads
  // =====================================================

  Future<void> load({String? filter, Map<String, dynamic>? params}) async {
    if (filter != null) {
      await setFilter(filter);
      return;
    }
    if (params != null) {
      await applyFilters(
        q: _asString(params['q']),
        companyId: _asInt(params['company_id']),
        jobType: _asString(params['job_type']),
        experienceLevel: _asString(params['experience_level']),
        city: _asString(params['city']),
        governorate: _asString(params['governorate']),
        minSalary: _asDouble(params['min_salary']),
        maxSalary: _asDouble(params['max_salary']),
        deadlineBefore: _asString(params['deadline_before']),
        deadlineAfter: _asString(params['deadline_after']),
        ids: _asIntList(params['ids']),
        includeClosed: _asBool(params['include_closed']),
        withCompany: _asBool(params['with_company']),
        withPlans: _asBool(params['with_plans']),
        remoteAllowed: _asBool(params['remote_allowed']),
        isFeatured: _asBool(params['is_featured']),
        sort: _asString(params['sort']),
        order: _asString(params['order']),
        perPage: _asInt(params['per_page']),
        // NEW: categories from params (if passed explicitly)
        categoryId: _asInt(params['category_id']),
        categoryIds: _asIntList(params['category_ids']),
        categorySlug: _asString(params['category_slug']),
        categorySlugs: _asStringList(params['category_slugs']),
        categoryMode: _asString(params['category_mode']),
        categoryName: _asString(params['category_name']),

      );
      return;
    }
    await firstPage();
  }

// lib/modules/home/controller/job_offer_controller.dart
  Future<void> firstPage() async {
    _setLoading(true);
    try {
      _error = null;
      _clearCooldown();
      page = 1;

      final params = _buildParams(page: page);
      final result = await _repo.index(params: params);

      _items = result.data;
      _meta = result.meta;
    } on CooldownException catch (e) {
      _error = e.message;
      _cooldownActive = true;
      _retryAt = e.retryAt;
      _retryAfterSeconds = e.retryAfterSeconds;
    } catch (e) {
      _error = e.toString();
      _items = const [];
      _meta = null;
    } finally {
      _setLoading(false);
    }
  }

// optional helper to try again from UI


// optional helper to try again from UI
  Future<void> tryAgainAfterCooldown() => firstPage();


  Future<void> loadMore() async {
    if (_loadingMore || !hasMore) return;
    _loadingMore = true;
    notifyListeners();

    try {
      _error = null;
      final nextPage = page + 1;

      final params = _buildParams(page: nextPage);
      final result = await _repo.index(params: params);

      _items = [..._items, ...result.data];
      _meta = result.meta ?? _meta;
      page = nextPage;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => firstPage();

  Future<JobOffer?> show(int id) async {
    _setLoading(true);
    try {
      _error = null;
      final offer = await _repo.show(id);
      _selected = offer;

      final idx = _items.indexWhere((o) => o.id == offer.id);
      if (idx >= 0) {
        final copy = List<JobOffer>.from(_items);
        copy[idx] = offer;
        _items = copy;
      } else {
        _items = [..._items, offer];
      }
      return offer;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // Filters & Helpers
  // =====================================================

  Future<void> setFilter(String filter) async {
    final normalized = _normalizeFilter(filter);
    if (_activeFilter == normalized) return;
    _activeFilter = normalized;
    await firstPage();
  }

  Future<void> applyFilters({
    String? q,
    int? companyId,
    String? jobType,
    String? experienceLevel,
    String? city,
    String? governorate,
    double? minSalary,
    double? maxSalary,
    String? deadlineBefore, // YYYY-MM-DD
    String? deadlineAfter,  // YYYY-MM-DD
    List<int>? ids,
    bool? includeClosed,
    bool? withCompany,
    bool? withPlans,
    bool? remoteAllowed,
    bool? isFeatured,
    String? sort,
    String? order,
    int? perPage,
    // NEW: categories
    int? categoryId,
    List<int>? categoryIds,
    String? categorySlug,
    List<String>? categorySlugs,
    String? categoryMode, String? categoryName,
  }) async {
    this.q = q ?? this.q;
    this.companyId = companyId ?? this.companyId;
    this.jobType = jobType ?? this.jobType;
    this.experienceLevel = experienceLevel ?? this.experienceLevel;
    this.city = city ?? this.city;
    this.governorate = governorate ?? this.governorate;
    this.minSalary = minSalary ?? this.minSalary;
    this.maxSalary = maxSalary ?? this.maxSalary;
    this.deadlineBefore = deadlineBefore ?? this.deadlineBefore;
    this.deadlineAfter = deadlineAfter ?? this.deadlineAfter;
    this.ids = ids ?? this.ids;

    // categories
    this.categoryId = categoryId ?? this.categoryId;
    this.categoryIds = categoryIds ?? this.categoryIds;
    this.categorySlug = categorySlug ?? this.categorySlug;
    this.categorySlugs = categorySlugs ?? this.categorySlugs;
    this.categoryMode = categoryMode ?? this.categoryMode;

    if (includeClosed != null) this.includeClosed = includeClosed;
    if (withCompany != null) this.withCompany = withCompany;
    if (withPlans != null) this.withPlans = withPlans;
    this.remoteAllowed = remoteAllowed ?? this.remoteAllowed;
    this.isFeatured = isFeatured ?? this.isFeatured;

    this.sort = sort ?? this.sort;
    this.order = order ?? this.order;
    this.perPage = perPage ?? this.perPage;

    await firstPage();
  }

  Future<void> clearFilters({bool keepSearch = false}) async {
    if (!keepSearch) q = null;
    companyId = null;
    jobType = null;
    experienceLevel = null;
    city = null;
    governorate = null;
    minSalary = null;
    maxSalary = null;
    deadlineBefore = null;
    deadlineAfter = null;
    categoryName = null; // NEW
    ids = const [];

    // clear categories too
    categoryId = null;
    categoryIds = const [];
    categorySlug = null;
    categorySlugs = const [];
    categoryMode = null;

    includeClosed = false;
    withCompany = null;
    withPlans = false;
    remoteAllowed = null;
    isFeatured = null;

    sort = 'created_at';
    order = 'desc';
    perPage = 15;
    page = 1;

    await firstPage();
  }

  Future<void> setSearch(String? query) async {
    q = (query ?? '').trim().isEmpty ? null : query!.trim();
    await firstPage();
  }

  Future<void> onCategoryTapped(String tag) async {
    final t = tag.trim();
    if (t.isEmpty || t.toLowerCase() == 'toute' || t.toLowerCase() == 'all') {
      // clear category filters
      categoryId = null;
      categoryIds = const [];
      categorySlug = null;
      categorySlugs = const [];
      categoryMode = null;
      await firstPage();
    } else {
      // set a single slug from display name
      categoryId = null;
      categoryIds = const [];
      categorySlugs = const [];
      categoryMode = null;
      categorySlug = _slugify(t);
      await firstPage();
    }
  }
  void _clearCategoryFilters() {
    categoryId = null;
    categoryIds = const [];
    categorySlug = null;
    categorySlugs = const [];
    categoryMode = null;
    categoryName = null;
  }

  // ------------ Quick helpers for common views ------------
  Future<void> loadOpen() => setFilter('open');
  Future<void> loadAll() => setFilter('all');
  Future<void> loadMyOffers() => setFilter('my-offer');
  Future<void> loadFeatured() => setFilter('featured');
  Future<void> loadRemote() => setFilter('remote');
  Future<void> loadPopular() => setFilter('popular');

  // =====================================================
  // Private
  // =====================================================

  Map<String, dynamic> _buildParams({required int page}) {
    final params = <String, dynamic>{};

    final hasCategory = (categoryId != null) ||
        categoryIds.isNotEmpty ||
        (categorySlug != null && categorySlug!.isNotEmpty) ||
        categorySlugs.isNotEmpty ||
        (categoryName != null && categoryName!.trim().isNotEmpty);

    // ✅ Only send filter if NO category is active
    if (!hasCategory) {
      params['filter'] = _activeFilter;
    }

    // Scalars...
    if (q != null && q!.isNotEmpty) params['q'] = q;
    if (companyId != null) params['company_id'] = companyId;
    if (jobType != null) params['job_type'] = jobType;
    if (experienceLevel != null) params['experience_level'] = experienceLevel;
    if (city != null && city!.isNotEmpty) params['city'] = city;
    if (governorate != null && governorate!.isNotEmpty) {
      params['governorate'] = governorate;
    }
    if (minSalary != null) params['min_salary'] = minSalary;
    if (maxSalary != null) params['max_salary'] = maxSalary;
    if (deadlineBefore != null && deadlineBefore!.isNotEmpty) {
      params['deadline_before'] = deadlineBefore;
    }
    if (deadlineAfter != null && deadlineAfter!.isNotEmpty) {
      params['deadline_after'] = deadlineAfter;
    }

    // Categories (IDs/slugs)
    if (categoryId != null) params['category_id'] = categoryId;
    if (categoryIds.isNotEmpty) params['category_ids'] = categoryIds;
    if (categorySlug != null && categorySlug!.isNotEmpty) {
      params['category_slug'] = categorySlug;
    }
    if (categorySlugs.isNotEmpty) params['category_slugs'] = categorySlugs;
    if (categoryMode != null && categoryMode!.isNotEmpty) {
      params['category_mode'] = categoryMode;
    }

    // ✅ Plain category name
    if ((categoryName ?? '').trim().isNotEmpty) {
      // ✅ name wins
      params['category_name'] = categoryName!.trim();
    } else if (categoryId != null) {
      params['category_id'] = categoryId;
    } else if (categoryIds.isNotEmpty) {
      params['category_ids'] = categoryIds;
    } else if ((categorySlug ?? '').trim().isNotEmpty) {
      params['category_slug'] = categorySlug!.trim();
    } else if (categorySlugs.isNotEmpty) {
      params['category_slugs'] = categorySlugs;
    }

    // Booleans
    if (includeClosed) params['include_closed'] = '1';
    // if (withCompany) params['with_company'] = '1';
    if (withCompany == true) {
      params['with_company'] = '1';
    } else if (withCompany == false) {
      params['with_company'] = '0';
    }
    if (withPlans) params['with_plans'] = '1';
    if (remoteAllowed != null) {
      params['remote_allowed'] = remoteAllowed! ? '1' : '0';
    }
    if (isFeatured != null) {
      params['is_featured'] = isFeatured! ? '1' : '0';
    }

    // Sorting & pagination
    params['sort'] = sort;
    params['order'] = order;
    params['per_page'] = perPage.toString();
    params['page'] = page.toString();

    if (ids.isNotEmpty) params['ids'] = ids;
    return params;
  }


  bool _isKnownFilter(String value) {
    final v = value.trim().toLowerCase();
    return [
      'open',
      'all',
      'my-offer',
      'featured',
      'remote',
      'popular',
      'populer',
      'closed',
    ].contains(v);
  }

  String _normalizeFilter(String value) {
    final v = value.trim().toLowerCase();
    if (v == 'populer') return 'popular'; // normalize UI spelling
    if (_isKnownFilter(v)) {
      // keep 'closed' & others as is
      return v == 'populer' ? 'popular' : v;
    }
    // unknown -> we'll treat as category elsewhere; keep server filter 'open'
    return 'open';
  }
  Future<void> initByCategoryName(String title) async {
    final name = _extractCategoryNameFromTitle(title);
    _initializing = true;
    notifyListeners();
    try {
      _error = null;
      // Clear any other category styles
      categoryId = null;
      categoryIds = const [];
      categorySlug = null;
      categorySlugs = const [];
      categoryMode = null;

      categoryName = name; // e.g. "Mobile"
      await firstPage();
    } catch (e) {
      _error = e.toString();
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  String _extractCategoryNameFromTitle(String t) {
    var s = t.trim();
    // Support both "Catégorie" and "Categorie", with or without colon/spaces
    const prefixes = [
      'Catégorie :', 'Catégorie:', 'Catégorie',
      'Categorie :', 'Categorie:', 'Categorie',
    ];
    final lower = s.toLowerCase();

    for (final p in prefixes) {
      if (lower.startsWith(p.toLowerCase())) {
        s = s.substring(p.length).trim();
        break;
      }
    }
    return s;
  }


  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}

// ----------------------------
// Tiny coercion & helpers
// ----------------------------
String? _asString(dynamic v) => v == null ? null : v.toString();

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString());
}

double? _asDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

bool? _asBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  final s = v.toString().toLowerCase();
  if (s == '1' || s == 'true') return true;
  if (s == '0' || s == 'false') return false;
  return null;
}

List<int>? _asIntList(dynamic v) {
  if (v is List) {
    return v.map((e) => _asInt(e)).whereType<int>().toList();
  }
  return null;
}

List<String>? _asStringList(dynamic v) {
  if (v is List) {
    return v.map((e) => _asString(e)).whereType<String>().toList();
  }
  return null;
}

/// Basic slugifier for labels like "Développement Mobile" -> "developpement-mobile"
String _slugify(String input) {
  final lower = input.toLowerCase();
  // remove common accents (minimal mapping for fr)
  const from = 'àáâäãåçèéêëìíîïñòóôöõùúûüýÿœæ';
  const to   = 'aaaaaaceeeeiiiinooooouuuuyyoeae';
  var s = StringBuffer();
  for (final ch in lower.characters) {
    final idx = from.indexOf(ch);
    s.write(idx >= 0 ? to[idx] : ch);
  }
  var out = s.toString();
  out = out.replaceAll(RegExp(r'[_\s]+'), '-');
  out = out.replaceAll(RegExp(r'[^a-z0-9-]'), '');
  out = out.replaceAll(RegExp(r'-{2,}'), '-');
  out = out.replaceAll(RegExp(r'^-+|-+$'), '');
  return out;
}
