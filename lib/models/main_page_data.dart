import 'package:flickd_app/models/movie.dart';
import 'package:flickd_app/models/search_category.dart';

class MainPageData {
  final List<Movie>? movies;
  final int? page;
  final String? searchCategory;
  final String? searchText;
  final String? error;

  MainPageData(
      {this.movies,
      this.page,
      this.searchCategory,
      this.searchText,
      this.error});

  MainPageData.initial()
      : movies = [],
        page = 1,
        searchCategory = SearchCategory.popular,
        searchText = '',
        error = null;
  MainPageData copyWith(
      {List<Movie>? movies,
      int? page,
      String? searchCategory,
      String? searchText,
      String? error}) {
    return MainPageData(
        movies: movies ?? this.movies,
        page: page ?? this.page,
        searchCategory: searchCategory ?? this.searchCategory,
        searchText: searchText ?? this.searchText,
        error: this.error);
  }
}
