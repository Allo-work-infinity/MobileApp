// lib/modules/categories/controller/category_controller.dart
import 'package:flutter/foundation.dart';
import 'package:job_finding/modules/home/model/Category.dart';
import '../repository/category_repository.dart';

/// If you already have a Category model elsewhere, import it instead:
/// import '../model/category.dart';
///
/// This controller uses the CategoryModel declared inside CategoryRepository.dart.
/// If you split it into its own file, update the import accordingly.
class CategoryController extends ChangeNotifier {
  final CategoryRepository _repo;

  CategoryController(this._repo);

  // ---------- State ----------
  List<CategoryModel> _categories = const [];
  CategoryModel? _selected;
  bool _loading = false;
  String? _error;
  bool _initializing = true; // similar to AuthController

  // ---------- Getters ----------
  List<CategoryModel> get categories => _categories;
  CategoryModel? get selected => _selected;
  bool get loading => _loading;
  String? get error => _error;
  bool get initializing => _initializing;

  // ---------- Init (load once on screen open / app start if needed) ----------
  Future<void> init() async {
    _initializing = true;
    notifyListeners();
    try {
      _error = null;
      _categories = await _repo.index(); // GET /api/categories
    } catch (e) {
      _error = e.toString();
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  // ---------- Actions ----------
  Future<void> refresh() async {
    _setLoading(true);
    try {
      _error = null;
      _categories = await _repo.index();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Loads a single category by id or slug and marks it as selected.
  Future<bool> loadOne(String idOrSlug) async {
    _setLoading(true);
    try {
      _error = null;
      _selected = await _repo.show(idOrSlug); // GET /api/categories/{idOrSlug}
      // Optionally update list cache with the selected item (upsert)
      final idx = _categories.indexWhere((c) => c.id == _selected!.id);
      if (idx >= 0) {
        final copy = List<CategoryModel>.from(_categories);
        copy[idx] = _selected!;
        _categories = copy;
      } else if (_selected != null) {
        _categories = [..._categories, _selected!];
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Local selection helper (no API call).
  void select(CategoryModel? category) {
    _selected = category;
    notifyListeners();
  }

  /// Clear last error message.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ---------- Helpers ----------
  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
