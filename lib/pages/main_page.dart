// ignore_for_file: avoid_renaming_method_parameters, prefer_const_constructors, no_leading_underscores_for_local_identifiers

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flickd_app/controllers/main_page_data_controller.dart';
import 'package:flickd_app/models/main_page_data.dart';
import 'package:flickd_app/models/search_category.dart';
import 'package:flickd_app/widgets/movie_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mainPageDataControllerProvider =
    StateNotifierProvider<MainPageDataController, MainPageData>((ref) {
  return MainPageDataController();
});

var selectedMoviePosterUrlProvider = StateProvider<String?>((ref) {
  final _movies = ref.watch(mainPageDataControllerProvider).movies;
  return _movies!.isNotEmpty ? _movies[0].posterUrl() : null;
});

class MainPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  TextEditingController? _searchTextFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    final _mainPageData = ref.watch(mainPageDataControllerProvider);
    final _selectedMoviePosterUrl = ref.watch(selectedMoviePosterUrlProvider);

    _searchTextFieldController!.text = _mainPageData.searchText!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SizedBox(
        height: _deviceHeight,
        width: _deviceWidth,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _backgroundWidget(_selectedMoviePosterUrl),
            _foregroundWidget(_mainPageData, _selectedMoviePosterUrl),
          ],
        ),
      ),
    );
  }

  Widget _foregroundWidget(
      MainPageData _mainPageData, _selectedMoviePosterUrl) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, _deviceHeight * 0.02, 0, 0),
      width: _deviceWidth * 0.88,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _topBarWidget(_mainPageData),
          _movieListViewWidget(_mainPageData, _selectedMoviePosterUrl),
        ],
      ),
    );
  }

  Widget _topBarWidget(MainPageData _mainPageData) {
    return Container(
      height: _deviceHeight * 0.08,
      decoration: BoxDecoration(
          color: Colors.black54, borderRadius: BorderRadius.circular(20.0)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: _deviceWidth * 0.5,
            height: _deviceHeight * 0.05,
            child: TextField(
                controller: _searchTextFieldController,
                onSubmitted: (_input) => _input.isNotEmpty
                    ? ref
                        .read(mainPageDataControllerProvider.notifier)
                        .updateTextSearch(_input)
                    : null,
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                    focusedBorder: InputBorder.none,
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white24,
                    ),
                    hintStyle: TextStyle(color: Colors.white54),
                    filled: false,
                    fillColor: Colors.white24,
                    hintText: "Search...")),
          ),
          DropdownButton(
            dropdownColor: Colors.black38,
            value: _mainPageData.searchCategory,
            icon: Icon(
              Icons.menu,
              color: Colors.white24,
            ),
            underline: Container(
              height: 1,
              color: Colors.white24,
            ),
            onChanged: (_value) {
              _value.toString().isNotEmpty
                  ? ref
                      .read(mainPageDataControllerProvider.notifier)
                      .updateSearchCategory(category: _value.toString())
                  : null;
            },
            items: <DropdownMenuItem<String>>[
              DropdownMenuItem(
                value: SearchCategory.popular,
                child: Text(
                  SearchCategory.popular,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              DropdownMenuItem(
                value: SearchCategory.upcoming,
                child: Text(
                  SearchCategory.upcoming,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              DropdownMenuItem(
                value: SearchCategory.none,
                child: Text(
                  SearchCategory.none,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _movieListViewWidget(
      MainPageData _mainPageData, _selectedMoviePosterUrl) {
    return Container(
      height: _deviceHeight * 0.83,
      padding: EdgeInsets.symmetric(vertical: _deviceHeight * 0.01),
      child: _mainPageData.movies != null
          ? NotificationListener(
              onNotification: (_onScrollNotification) {
                if (_onScrollNotification is ScrollEndNotification) {
                  final before = _onScrollNotification.metrics.extentBefore;
                  final max = _onScrollNotification.metrics.maxScrollExtent;
                  if (before == max) {
                    ref
                        .read(mainPageDataControllerProvider.notifier)
                        .getMovies();
                    return true;
                  }
                  return false;
                }
                return false;
              },
              child: ListView.builder(
                  itemCount: _mainPageData.movies!.length,
                  itemBuilder: (BuildContext _context, int index) {
                    final movie = _mainPageData.movies![index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _deviceHeight * 0.01, horizontal: 0),
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(selectedMoviePosterUrlProvider.notifier)
                              .state = movie.posterUrl();
                        },
                        child: MovieTile(
                            height: _deviceHeight * 0.2,
                            width: _deviceWidth * 0.85,
                            movie: movie),
                      ),
                    );
                  }),
            )
          : Center(
              child: CircularProgressIndicator(backgroundColor: Colors.white),
            ),
    );
  }

  Widget _backgroundWidget(String? _selectedMoviePosterUrl) {
    if (_selectedMoviePosterUrl != null) {
      return Container(
        height: _deviceHeight,
        width: _deviceWidth,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
                image: CachedNetworkImageProvider(
                  _selectedMoviePosterUrl,
                ),
                fit: BoxFit.cover)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
          ),
        ),
      );
    } else {
      return Container(
        height: _deviceHeight,
        width: _deviceWidth,
        color: Colors.black,
      );
    }
  }
}
