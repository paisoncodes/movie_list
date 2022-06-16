import 'package:flickd_app/models/main_page_data.dart';
import 'package:flickd_app/models/movie.dart';
import 'package:flickd_app/models/search_category.dart';
import 'package:flickd_app/services/movie_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

class MainPageDataController extends StateNotifier<MainPageData> {
  MainPageDataController() : super(MainPageData.initial()) {
    getMovies();
  }

  final MovieService _movieService = GetIt.instance.get<MovieService>();

  Future<void> getMovies() async {
    try {
      List<Movie> _movies = [];
      if (state.searchText!.isEmpty) {
        if (state.searchCategory == SearchCategory.popular) {
          _movies = await _movieService.getPopularMovies(page: state.page);
        } else if (state.searchCategory == SearchCategory.upcoming) {
          _movies = await _movieService.getUpcomingMovies(page: state.page);
        } else if (state.searchCategory == SearchCategory.none) {
          _movies = [];
        }
      } else {
        _movies =
            await _movieService.searchMovies(searchTerm: state.searchText!);
      }
      state = state.copyWith(
          movies: [...state.movies!, ..._movies],
          searchCategory: state.searchCategory!,
          page: state.page! + 1,
          searchText: state.searchText!);
    } catch (e) {
      rethrow;
    }
  }

  void updateSearchCategory({String? category}) async {
    if (category != null) {
      state = state.copyWith(
          movies: [], page: 1, searchCategory: category, searchText: '');
      getMovies();
    }
  }

  void updateTextSearch(String _searchText) async {
    state = state.copyWith(
        movies: [],
        page: 1,
        searchCategory: SearchCategory.none,
        searchText: _searchText);
    getMovies();
  }
}
