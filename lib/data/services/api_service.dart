// lib/data/services/api_service.dart
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart' hide Response, MultipartFile, FormData;

import 'api_config.dart';
import 'mock_api_service.dart';
import 'storage_service.dart';

class ApiService extends GetxService {
  dio.Dio? _dio; // Made nullable to avoid late initialization
  late dio.CancelToken _cancelToken;
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    // Always initialize cancel token
    _cancelToken = dio.CancelToken();

    // Only initialize Dio if we're not using mock data
    if (!ApiConfig.USE_MOCK_DATA) {
      _initializeDio();
    }
  }

  void _initializeDio() {
    _dio = dio.Dio(
      dio.BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add request interceptor for authentication
    _dio!.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to requests
          final token = await _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print('REQUEST: ${options.method} ${options.path}');
          print('HEADERS: ${options.headers}');
          if (options.data != null) {
            print('DATA: ${options.data}');
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            'RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          print(
            'ERROR: ${error.response?.statusCode} ${error.requestOptions.path}',
          );
          print('ERROR MESSAGE: ${error.message}');

          // Handle token expiration
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the request with new token
              final options = error.requestOptions;
              final token = await _storageService.getToken();
              options.headers['Authorization'] = 'Bearer $token';

              try {
                final response = await _dio!.fetch(options);
                handler.resolve(response);
                return;
              } catch (e) {
                // If retry fails, proceed with original error
              }
            } else {
              // Redirect to login if refresh fails
              await _storageService.clearAll();
              Get.offAllNamed('/auth');
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  // GET Request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    dio.CancelToken? cancelToken,
  }) async {
    // Use mock data if enabled
    if (ApiConfig.USE_MOCK_DATA) {
      // For mock data, we don't need to make actual HTTP calls
      // This method should only be called for endpoints not covered by specific methods
      await Future.delayed(
        Duration(milliseconds: 500),
      ); // Simulate network delay
      return {'success': true, 'message': 'Mock response for $endpoint'};
    }

    if (_dio == null) {
      throw ApiException(
        'ApiService not properly initialized for HTTP requests',
      );
    }

    try {
      final response = await _dio!.get(
        endpoint,
        queryParameters: queryParameters,
        cancelToken: cancelToken ?? _cancelToken,
      );
      return _handleResponse(response);
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.CancelToken? cancelToken,
  }) async {
    // Use mock data if enabled
    if (ApiConfig.USE_MOCK_DATA) {
      // For mock data, we don't need to make actual HTTP calls
      // This method should only be called for endpoints not covered by specific methods
      await Future.delayed(
        Duration(milliseconds: 500),
      ); // Simulate network delay
      return {'success': true, 'message': 'Mock response for $endpoint'};
    }

    if (_dio == null) {
      throw ApiException(
        'ApiService not properly initialized for HTTP requests',
      );
    }

    try {
      final response = await _dio!.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken ?? _cancelToken,
      );
      return _handleResponse(response);
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT Request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.CancelToken? cancelToken,
  }) async {
    // Use mock data if enabled
    if (ApiConfig.USE_MOCK_DATA) {
      // For mock data, we don't need to make actual HTTP calls
      // This method should only be called for endpoints not covered by specific methods
      await Future.delayed(
        Duration(milliseconds: 500),
      ); // Simulate network delay
      return {'success': true, 'message': 'Mock response for $endpoint'};
    }

    if (_dio == null) {
      throw ApiException(
        'ApiService not properly initialized for HTTP requests',
      );
    }

    try {
      final response = await _dio!.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken ?? _cancelToken,
      );
      return _handleResponse(response);
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    dio.CancelToken? cancelToken,
  }) async {
    // Use mock data if enabled
    if (ApiConfig.USE_MOCK_DATA) {
      // For mock data, we don't need to make actual HTTP calls
      // This method should only be called for endpoints not covered by specific methods
      await Future.delayed(
        Duration(milliseconds: 500),
      ); // Simulate network delay
      return {'success': true, 'message': 'Mock response for $endpoint'};
    }

    if (_dio == null) {
      throw ApiException(
        'ApiService not properly initialized for HTTP requests',
      );
    }

    try {
      final response = await _dio!.delete(
        endpoint,
        queryParameters: queryParameters,
        data: data,
        cancelToken: cancelToken ?? _cancelToken,
      );
      return _handleResponse(response);
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH Request
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.CancelToken? cancelToken,
  }) async {
    // Use mock data if enabled
    if (ApiConfig.USE_MOCK_DATA) {
      // For mock data, we don't need to make actual HTTP calls
      // This method should only be called for endpoints not covered by specific methods
      await Future.delayed(
        Duration(milliseconds: 500),
      ); // Simulate network delay
      return {'success': true, 'message': 'Mock response for $endpoint'};
    }

    if (_dio == null) {
      throw ApiException(
        'ApiService not properly initialized for HTTP requests',
      );
    }

    try {
      final response = await _dio!.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken ?? _cancelToken,
      );
      return _handleResponse(response);
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  // File Upload
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    dio.ProgressCallback? onProgress,
    dio.CancelToken? cancelToken,
  }) async {
    // Use mock data if enabled
    if (ApiConfig.USE_MOCK_DATA) {
      await Future.delayed(
        Duration(milliseconds: 1000),
      ); // Simulate upload delay
      return {
        'success': true,
        'message': 'File uploaded successfully',
        'fileUrl': 'https://mockurl.com/uploaded-file.jpg',
      };
    }

    if (_dio == null) {
      throw ApiException(
        'ApiService not properly initialized for HTTP requests',
      );
    }

    try {
      final formData = dio.FormData();

      // Add file
      formData.files.add(
        MapEntry(fieldName, await dio.MultipartFile.fromFile(filePath)),
      );

      // Add additional data
      if (data != null) {
        data.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      final response = await _dio!.post(
        endpoint,
        data: formData,
        onSendProgress: onProgress,
        cancelToken: cancelToken ?? _cancelToken,
      );

      return _handleResponse(response);
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Multiple file upload
  Future<Map<String, dynamic>> uploadMultipleFiles(
    String endpoint,
    List<String> filePaths, {
    String fieldName = 'files',
    Map<String, dynamic>? data,
    dio.ProgressCallback? onProgress,
    dio.CancelToken? cancelToken,
  }) async {
    // Use mock data if enabled
    if (ApiConfig.USE_MOCK_DATA) {
      await Future.delayed(
        Duration(milliseconds: 1500),
      ); // Simulate upload delay
      return {
        'success': true,
        'message': 'Files uploaded successfully',
        'fileUrls': filePaths
            .map((path) => 'https://mockurl.com/${path.split('/').last}')
            .toList(),
      };
    }

    if (_dio == null) {
      throw ApiException(
        'ApiService not properly initialized for HTTP requests',
      );
    }

    try {
      final formData = dio.FormData();

      // Add files
      for (final filePath in filePaths) {
        formData.files.add(
          MapEntry(fieldName, await dio.MultipartFile.fromFile(filePath)),
        );
      }

      // Add additional data
      if (data != null) {
        data.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      final response = await _dio!.post(
        endpoint,
        data: formData,
        onSendProgress: onProgress,
        cancelToken: cancelToken ?? _cancelToken,
      );

      return _handleResponse(response);
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Upload file from bytes
  Future<Map<String, dynamic>> uploadFileFromBytes(
    String endpoint,
    List<int> bytes,
    String fileName, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    dio.ProgressCallback? onProgress,
    dio.CancelToken? cancelToken,
  }) async {
    // Use mock data if enabled
    if (ApiConfig.USE_MOCK_DATA) {
      await Future.delayed(
        Duration(milliseconds: 1000),
      ); // Simulate upload delay
      return {
        'success': true,
        'message': 'File uploaded successfully',
        'fileUrl': 'https://mockurl.com/$fileName',
      };
    }

    if (_dio == null) {
      throw ApiException(
        'ApiService not properly initialized for HTTP requests',
      );
    }

    try {
      final formData = dio.FormData();

      // Add file from bytes
      formData.files.add(
        MapEntry(
          fieldName,
          dio.MultipartFile.fromBytes(bytes, filename: fileName),
        ),
      );

      // Add additional data
      if (data != null) {
        data.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      final response = await _dio!.post(
        endpoint,
        data: formData,
        onSendProgress: onProgress,
        cancelToken: cancelToken ?? _cancelToken,
      );

      return _handleResponse(response);
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Download file
  Future<void> downloadFile(
    String endpoint,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    dio.ProgressCallback? onProgress,
    dio.CancelToken? cancelToken,
  }) async {
    // Use mock data if enabled
    if (ApiConfig.USE_MOCK_DATA) {
      await Future.delayed(
        Duration(milliseconds: 1000),
      ); // Simulate download delay
      return; // Mock download completed
    }

    if (_dio == null) {
      throw ApiException(
        'ApiService not properly initialized for HTTP requests',
      );
    }

    try {
      await _dio!.download(
        endpoint,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken ?? _cancelToken,
      );
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Handle Response
  Map<String, dynamic> _handleResponse(dio.Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        return {'success': true, 'data': response.data};
      }
    } else {
      throw ApiException(
        'Request failed with status: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  // Handle Errors
  ApiException _handleError(dio.DioException error) {
    String message = 'An error occurred';
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case dio.DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case dio.DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        break;
      case dio.DioExceptionType.receiveTimeout:
        message = 'Response timeout. Please try again.';
        break;
      case dio.DioExceptionType.badResponse:
        if (error.response?.data != null && error.response?.data is Map) {
          final data = error.response?.data as Map<String, dynamic>;
          message =
              data['message'] ?? data['error'] ?? 'Server error occurred.';
        } else {
          message = 'Server error: ${error.response?.statusCode}';
        }
        break;
      case dio.DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case dio.DioExceptionType.unknown:
        message = 'Network error. Please check your internet connection.';
        break;
      default:
        message = 'An unexpected error occurred.';
    }

    return ApiException(message, statusCode);
  }

  // Refresh Token
  Future<bool> _refreshToken() async {
    if (ApiConfig.USE_MOCK_DATA || _dio == null) {
      return false;
    }

    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio!.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        await _storageService.saveToken(response.data['token']);
        if (response.data['refresh_token'] != null) {
          await _storageService.saveRefreshToken(
            response.data['refresh_token'],
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Set Custom Headers
  void setHeaders(Map<String, String> headers) {
    if (_dio != null) {
      _dio!.options.headers.addAll(headers);
    }
  }

  // Clear Headers
  void clearHeaders() {
    if (_dio != null) {
      _dio!.options.headers.clear();
      _dio!.options.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
    }
  }

  // Set timeout
  void setTimeout({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    if (_dio != null) {
      if (connectTimeout != null) {
        _dio!.options.connectTimeout = connectTimeout;
      }
      if (receiveTimeout != null) {
        _dio!.options.receiveTimeout = receiveTimeout;
      }
      if (sendTimeout != null) {
        _dio!.options.sendTimeout = sendTimeout;
      }
    }
  }

  // Cancel specific request token
  void cancelRequest(dio.CancelToken cancelToken, [String? reason]) {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel(reason);
    }
  }

  // Cancel all ongoing requests
  void cancelAllRequests([String? reason]) {
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel(reason);
      // Create a new cancel token for future requests
      _cancelToken = dio.CancelToken();
    }
  }

  // Create a new cancel token
  dio.CancelToken createCancelToken() {
    return dio.CancelToken();
  }

  // Check if service is cancelled
  bool get isCancelled => _cancelToken.isCancelled;

  // Get Dio instance (for advanced usage)
  dio.Dio? get dioInstance => _dio;

  // Get current cancel token
  dio.CancelToken get cancelToken => _cancelToken;

  @override
  void onClose() {
    // Cancel all requests when service is disposed
    cancelAllRequests('ApiService disposed');
    super.onClose();
  }

  // Auth APIs
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.login(email, password);
    }

    return await post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.register(userData);
    }

    return await post('/auth/register', data: userData);
  }

  Future<Map<String, dynamic>> logout() async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.logout();
    }

    return await post('/auth/logout');
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.getCurrentUser();
    }

    return await get('/auth/me');
  }

  // User Profile APIs
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.getUserProfile(userId);
    }

    return await get('/users/$userId');
  }

  Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.updateUserProfile(userId, updates);
    }

    return await put('/users/$userId', data: updates);
  }

  Future<Map<String, dynamic>> uploadProfileImage(
    String userId,
    String imagePath,
  ) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.uploadProfileImage(userId, imagePath);
    }

    return await uploadFile('/users/$userId/profile-image', imagePath);
  }

  // Job APIs
  Future<Map<String, dynamic>> getJobs({
    int page = 1,
    int limit = 10,
    String? search,
    String? type,
    String? location,
    String? company,
  }) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.getJobs(
        page: page,
        limit: limit,
        search: search,
        type: type,
        location: location,
        company: company,
      );
    }

    return await get(
      '/jobs',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null) 'search': search,
        if (type != null) 'type': type,
        if (location != null) 'location': location,
        if (company != null) 'company': company,
      },
    );
  }

  Future<Map<String, dynamic>> getJobById(String jobId) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.getJobById(jobId);
    }

    return await get('/jobs/$jobId');
  }

  Future<Map<String, dynamic>> getJobFilters() async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.getJobFilters();
    }

    return await get('/jobs/filters');
  }

  // Application APIs
  Future<Map<String, dynamic>> applyForJob(
    String jobId,
    Map<String, dynamic> applicationData,
  ) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.applyForJob(jobId, applicationData);
    }

    return await post(
      '/applications',
      data: {'jobId': jobId, ...applicationData},
    );
  }

  Future<Map<String, dynamic>> getApplications(
    String studentId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.getApplications(
        studentId,
        page: page,
        limit: limit,
        status: status,
      );
    }

    return await get(
      '/applications',
      queryParameters: {
        'studentId': studentId,
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      },
    );
  }

  Future<Map<String, dynamic>> getApplicationById(String applicationId) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.getApplicationById(applicationId);
    }

    return await get('/applications/$applicationId');
  }

  Future<Map<String, dynamic>> withdrawApplication(String applicationId) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.withdrawApplication(applicationId);
    }

    return await delete('/applications/$applicationId');
  }

  Future<Map<String, dynamic>> getUpcomingInterviews(String studentId) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.getUpcomingInterviews(studentId);
    }

    return await get(
      '/interviews/upcoming',
      queryParameters: {'studentId': studentId},
    );
  }

  // Group APIs
  Future<Map<String, dynamic>> getGroups(
    String studentId, {
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.getGroups(
        studentId,
        page: page,
        limit: limit,
        search: search,
      );
    }

    return await get(
      '/groups',
      queryParameters: {
        'studentId': studentId,
        'page': page,
        'limit': limit,
        if (search != null) 'search': search,
      },
    );
  }

  Future<Map<String, dynamic>> getGroupById(String groupId) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.getGroupById(groupId);
    }

    return await get('/groups/$groupId');
  }

  Future<Map<String, dynamic>> joinGroup(
    String groupId,
    String studentId,
  ) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.joinGroup(groupId, studentId);
    }

    return await post('/groups/$groupId/join', data: {'studentId': studentId});
  }

  Future<Map<String, dynamic>> leaveGroup(
    String groupId,
    String studentId,
  ) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.leaveGroup(groupId, studentId);
    }

    return await post('/groups/$groupId/leave', data: {'studentId': studentId});
  }

  Future<Map<String, dynamic>> getGroupMessages(
    String groupId, {
    int page = 1,
    int limit = 20,
  }) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.getGroupMessages(
        groupId,
        page: page,
        limit: limit,
      );
    }

    return await get(
      '/groups/$groupId/messages',
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  Future<Map<String, dynamic>> sendMessage(
    String groupId,
    String studentId,
    String message,
  ) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.sendMessage(groupId, studentId, message);
    }

    return await post(
      '/groups/$groupId/messages',
      data: {'senderId': studentId, 'message': message},
    );
  }

  // Dashboard APIs
  Future<Map<String, dynamic>> getDashboardData(String studentId) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.getDashboardData(studentId);
    }

    return await get('/dashboard', queryParameters: {'studentId': studentId});
  }

  // Document Upload APIs
  Future<Map<String, dynamic>> uploadDocument(
    String filePath,
    String type,
  ) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.uploadDocument(filePath, type);
    }

    return await uploadFile(
      '/documents/upload',
      filePath,
      data: {'type': type},
    );
  }

  // Settings APIs
  Future<Map<String, dynamic>> updateNotificationSettings(
    String studentId,
    Map<String, bool> settings,
  ) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.updateNotificationSettings(
        studentId,
        settings,
      );
    }

    return await put('/users/$studentId/notification-settings', data: settings);
  }

  Future<Map<String, dynamic>> changePassword(
    String studentId,
    String oldPassword,
    String newPassword,
  ) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.changePassword(
        studentId,
        oldPassword,
        newPassword,
      );
    }

    return await put(
      '/users/$studentId/change-password',
      data: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
  }

  Future<Map<String, dynamic>> deleteAccount(String studentId) async {
    if (ApiConfig.USE_MOCK_DATA) {
      return await MockApiService.deleteAccount(studentId);
    }

    return await delete('/users/$studentId');
  }
}

// Custom API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}
