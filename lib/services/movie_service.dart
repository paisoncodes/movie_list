import 'package:dio/dio.dart';
import 'package:flickd_app/models/movie.dart';
import 'package:flickd_app/services/http_service.dart';
import 'package:get_it/get_it.dart';

class MovieService {
  final GetIt getIt = GetIt.instance;

  late HTTPService _http;

  MovieService() {
    _http = getIt.get<HTTPService>();
  }

  Future<List<Movie>?> getPopularMovies({int? page}) async {
    Response _response = await _http.get('/movie/popular', query: {
      "page": page,
    });

    if (_response.statusCode == 200) {
      Map _data = _response.data;
      List<Movie> _movies = _data["results"].map<Movie>((_movieData) {
        return Movie.fromJson(_movieData);
      }).toList;
      return _movies;
    } else {
      throw Exception("Couldn't load popular movies");
    }
  }
}
