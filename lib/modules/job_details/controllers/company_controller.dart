// lib/controllers/company_controller.dart
import 'package:flutter/foundation.dart';
import 'package:job_finding/modules/job_details/Repository/company_repository.dart';
import 'package:job_finding/modules/job_details/model/company.dart';

enum LoadState { idle, loading, loaded, notFound, error }

class CompanyController extends ChangeNotifier {
  final CompanyRepositoryHttp _repo;

  Company? _company;
  String? _errorMessage;
  LoadState _state = LoadState.idle;

  CompanyController(this._repo);

  /// Convenience factory if you just want to pass a baseUrl.
  factory CompanyController.withBaseUrl(
      String baseUrl, {
        Map<String, String>? defaultHeaders,
      }) {
    return CompanyController(
      CompanyRepositoryHttp(baseUrl: baseUrl, defaultHeaders: defaultHeaders),
    );
  }

  // Getters
  Company? get company => _company;
  String? get errorMessage => _errorMessage;
  LoadState get state => _state;
  bool get isLoading => _state == LoadState.loading;

  /// Load a company by ID. If `usePost` is true, sends JSON body {id:x}; else uses query ?id=x
  Future<void> fetchCompanyById(int id, {bool usePost = true}) async {
    _state = LoadState.loading;
    _errorMessage = null;
    _company = null;
    notifyListeners();

    try {
      final result = await _repo.getById(id, usePost: usePost);
      _company = result;
      _state = LoadState.loaded;
    } on NotFoundException {
      _state = LoadState.notFound;
      _errorMessage = 'Company not found';
    } on ApiException catch (e) {
      _state = LoadState.error;
      _errorMessage = e.message;
    } catch (e) {
      _state = LoadState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  /// Safe variant that returns true if found (and sets state/data), false otherwise.
  Future<bool> tryFetchCompanyById(int id, {bool usePost = true}) async {
    await fetchCompanyById(id, usePost: usePost);
    return _state == LoadState.loaded;
  }

  /// Reset controller to idle state
  void reset() {
    _company = null;
    _errorMessage = null;
    _state = LoadState.idle;
    notifyListeners();
  }
}
