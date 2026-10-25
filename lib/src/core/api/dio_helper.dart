import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../utils/date_time_provider.dart';
import 'api_client.dart';
import 'locale_provider.dart';

const String _contentType = 'Content-Type';
const String _applicationJson = 'application/json';
const int _timeOut = 20000;

/// Concrete implementation of [ApiClient] using [Dio].
class DioHelper implements ApiClient {
  final Dio dio;
  final LocaleProvider localeProvider;
  final DateTimeProvider dateTimeProvider;

  DioHelper({
    required this.dio,
    required this.localeProvider,
    required this.dateTimeProvider,
  }) {
    final Map<String, dynamic> headers = {_contentType: _applicationJson};
    dio.options = BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      receiveDataWhenStatusError: true,
      receiveTimeout: const Duration(milliseconds: _timeOut),
      connectTimeout: const Duration(milliseconds: _timeOut),
      headers: headers,
    );
    if (kDebugMode) {
      // dio.interceptors.add(sl<LogInterceptor>());
      // dio.interceptors.add(sl<AppInterceptors>());
    }
  }

  String _getTimezoneName() {
    final offsetHours = dateTimeProvider.now().timeZoneOffset.inMinutes / 60.0;
    final timezoneMap = {
      -11.0: 'Pacific/Midway',
      -10.0: 'Pacific/Honolulu',
      -9.0: 'America/Anchorage',
      -8.0: 'America/Los_Angeles',
      -7.0: 'America/Denver',
      -6.0: 'America/Chicago',
      -5.0: 'America/New_York',
      -4.0: 'America/Halifax',
      -3.0: 'America/Argentina/Buenos_Aires',
      -2.0: 'America/Noronha',
      -1.0: 'Atlantic/Azores',
      0.0: 'UTC',
      1.0: 'Europe/Paris',
      2.0: 'Africa/Cairo',
      3.0: 'Africa/Cairo',
      4.0: 'Asia/Dubai',
      4.5: 'Asia/Kabul',
      5.0: 'Asia/Karachi',
      5.5: 'Asia/Kolkata',
      5.75: 'Asia/Kathmandu',
      6.0: 'Asia/Dhaka',
      6.5: 'Asia/Yangon',
      7.0: 'Asia/Bangkok',
      8.0: 'Asia/Singapore',
      9.0: 'Asia/Tokyo',
      9.5: 'Australia/Adelaide',
      10.0: 'Australia/Sydney',
      11.0: 'Pacific/Guadalcanal',
      12.0: 'Pacific/Auckland',
      13.0: 'Pacific/Apia',
      14.0: 'Pacific/Kiritimati', // Added standard +14 hours for completeness
    };
    return timezoneMap[offsetHours] ?? 'UTC';
  }

  @override
  Future<Response<T>> get<T>({
    required String url,
    Map<String, dynamic>? queryParams,
  }) async {
    final locale = localeProvider.getLocale();
    final mergedQueryParameters = <String, dynamic>{
      'langId':
          locale.languageCode == 'ar'
              ? AppConstants.apiArabicLangId
              : AppConstants.apiEnglishLangId,
      'appTypeId': 5,
      'timezoneName': _getTimezoneName(),
      ...?queryParams,
    };
    return await dio.get<T>(url, queryParameters: mergedQueryParameters);
  }
}
