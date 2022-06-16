// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flickd_app/models/app_config.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class HTTPService {
  final Dio dio = Dio();
  final GetIt getIt = GetIt.instance;

  String? _base_url;
  String? _api_key;

  HTTPService() {
    AppConfig _config = getIt.get<AppConfig>();
    _base_url = _config.BASE_API_URL;
    _api_key = _config.API_KEY;
  }

  Future<Response> get(String _path, {Map<String, dynamic>? query}) async {
    try {
      String _url = '$_base_url$_path';
      Map<String, dynamic> _header = {
        'Content-Type': "application/json",
        'Accept': "application/json",
      };
      Map<String, dynamic> _query = {
        'api_key': _api_key,
        'language': 'en-US',
      };
      if (query != null) {
        _query.addAll(query);
      }
      return await dio.get(_url,
          queryParameters: _query, options: Options(headers: _header));
    } on DioError catch (e) {
      print("Unable to complete request.");
      print("DioError: $e");
      rethrow;
    }
  }
}
