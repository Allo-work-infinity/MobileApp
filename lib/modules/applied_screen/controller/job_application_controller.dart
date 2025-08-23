// lib/modules/applications/controller/job_application_controller.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../model/job_application.dart';
import '../repository/job_application_repository.dart';

/// Controller for listing & managing job applications using JobApplicationRepository.
class JobApplicationController extends ChangeNotifier {
  final JobApplicationRepository _repo;

  JobApplicationController(this._repo);

  // ------------ State ------------
  List<JobApplication> _items = const [];
  PageMeta? _meta;
  JobApplication? _selected;

  bool _initializing = true;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;

  // ------------ Filters / Params sent to server ------------
  String? q;
  String? status;          // 'submitted' | 'under_review' | 'shortlisted' | 'rejected' | 'accepted'
  int? jobOfferId;
  String? from;            // YYYY-MM-DD
  String? to;              // YYYY-MM-DD

  int perPage = 15;
  int page = 1;

  // ------------ Getters ------------
  List<JobApplication> get items => _items;
  PageMeta? get meta => _meta;
  JobApplication? get selected => _selected;

  bool get initializing => _initializing;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;

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

  /// Call on screen open. You can pass an initial status filter if you want.
  Future<void> init({String? initialStatus}) async {
    _initializing = true;
    if (initialStatus != null && initialStatus.trim().isNotEmpty) {
      status = initialStatus.trim();
    }
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

  // =====================================================
  // Loads
  // =====================================================

  /// Load first page (or full list if backend sends a bare array).
  Future<void> firstPage() async {
    _setLoading(true);
    try {
      _error = null;
      page = 1;

      final params = _buildParams(page: page);
      final result = await _repo.index(params: params);

      _items = result.data;
      _meta = result.meta; // may be null (bare list shape)
    } catch (e) {
      _error = e.toString();
      _items = const [];
      _meta = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Append next page when backend supports pagination.
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

  /// Hard reload using current filters.
  Future<void> refresh() => firstPage();

  /// Load one application (ensures local cache stays consistent).
  Future<JobApplication?> show(int id) async {
    _setLoading(true);
    try {
      _error = null;
      final app = await _repo.show(id);
      _selected = app;

      // Upsert in list cache
      final idx = _items.indexWhere((a) => a.id == app.id);
      if (idx >= 0) {
        final copy = List<JobApplication>.from(_items);
        copy[idx] = app;
        _items = copy;
      } else {
        _items = [app, ..._items];
      }
      return app;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // Mutations (create/update/delete)
  // =====================================================

  /// Apply to an offer (POST). Returns the created application and inserts it at the top.
  Future<JobApplication?> applyToOffer({
    required int jobOfferId,
    File? cvFile,
    String? cvFileUrl,
    List<String>? additionalDocuments,
  }) async {
    _setLoading(true);
    try {
      _error = null;
      final created = await _repo.create(
        jobOfferId: jobOfferId,
        cvFile: cvFile,
        cvFileUrl: cvFileUrl,
        additionalDocuments: additionalDocuments,
      );
      _items = [created, ..._items];
      _selected = created;
      return created;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an application (PATCH). Upserts into the list + selected.
  Future<JobApplication?> updateApplication(
      int id, {
        File? cvFile,
        String? cvFileUrl,
        List<String>? additionalDocuments,
      }) async {
    _setLoading(true);
    try {
      _error = null;
      final updated = await _repo.update(
        id,
        cvFile: cvFile,
        cvFileUrl: cvFileUrl,
        additionalDocuments: additionalDocuments,
      );

      final idx = _items.indexWhere((a) => a.id == updated.id);
      if (idx >= 0) {
        final copy = List<JobApplication>.from(_items);
        copy[idx] = updated;
        _items = copy;
      }
      if (_selected?.id == updated.id) _selected = updated;

      return updated;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete (withdraw) an application.
  Future<bool> deleteApplication(int id) async {
    _setLoading(true);
    try {
      _error = null;
      await _repo.destroy(id);
      _items = _items.where((a) => a.id != id).toList();
      if (_selected?.id == id) _selected = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // Filters
  // =====================================================

  /// Bulk apply optional filters (nulls are ignored), then reload.
  Future<void> applyFilters({
    String? q,
    String? status,
    int? jobOfferId,
    String? from, // YYYY-MM-DD
    String? to,   // YYYY-MM-DD
    int? perPage,
  }) async {
    this.q = q ?? this.q;
    this.status = status ?? this.status;
    this.jobOfferId = jobOfferId ?? this.jobOfferId;
    this.from = from ?? this.from;
    this.to = to ?? this.to;

    this.perPage = perPage ?? this.perPage;

    await firstPage();
  }

  /// Clear all filters and restore defaults.
  Future<void> clearFilters({bool keepSearch = false}) async {
    if (!keepSearch) q = null;
    status = null;
    jobOfferId = null;
    from = null;
    to = null;

    perPage = 15;
    page = 1;

    await firstPage();
  }

  /// Handy setters:
  Future<void> setSearch(String? query) async {
    q = (query ?? '').trim().isEmpty ? null : query!.trim();
    await firstPage();
  }

  Future<void> setStatus(String? value) async {
    status = (value ?? '').trim().isEmpty ? null : value!.trim();
    await firstPage();
  }

  Future<void> setOfferFilter(int? offerId) async {
    jobOfferId = offerId;
    await firstPage();
  }

  Future<void> setDateRange({DateTime? fromDate, DateTime? toDate}) async {
    from = fromDate == null ? null : _fmtDate(fromDate);
    to = toDate == null ? null : _fmtDate(toDate);
    await firstPage();
  }

  // =====================================================
  // Private
  // =====================================================

  Map<String, dynamic> _buildParams({required int page}) {
    final params = <String, dynamic>{};

    if (q != null && q!.isNotEmpty) params['q'] = q;
    if (status != null && status!.isNotEmpty) params['status'] = status;
    if (jobOfferId != null) params['job_offer_id'] = jobOfferId;
    if (from != null && from!.isNotEmpty) params['from'] = from;
    if (to != null && to!.isNotEmpty) params['to'] = to;

    // pagination (if server supports)
    params['per_page'] = perPage.toString();
    params['page'] = page.toString();

    return params;
  }

  String _fmtDate(DateTime d) {
    // YYYY-MM-DD
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
