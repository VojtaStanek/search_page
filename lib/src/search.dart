import 'package:flutter/material.dart';

typedef SearchFilter<T> = List<String> Function(T t);
typedef ResultBuilder<T> = Widget Function(T t);

/// This class helps to implement a search view, using [SearchDelegate].
/// It can show suggestion & unsuccessful-search widgets.
class SearchPage<T> extends SearchDelegate<T> {
  /// Widget that is built when current query is empty.
  /// Suggests the user what's possible to do.
  final Widget suggestion;

  /// Widget built when there's no item in [items] that
  /// matches current query.
  final Widget failure;

  /// Method that builds a widget for each item that matches
  /// the current query parameter entered by the user.
  final ResultBuilder<T> builder;

  /// Method that returns the specific parameters intrinsic
  /// to a [T] instance.
  ///
  /// For example, filter a person by its name & age parameters:
  /// filter: (person) => [
  ///   person.name,
  ///   person.age.toString(),
  /// ]
  ///
  /// Al parameters to filter through must be [String] instances.
  final SearchFilter<T> filter;

  /// This text will be shown in the [AppBar] when
  /// current query is empty.
  final String searchLabel;

  /// List of items where the search is going to take place on.
  /// They have [T] on run time.
  final List<T> items;

  SearchPage({
    this.suggestion = const SizedBox(),
    this.failure = const SizedBox(),
    this.builder,
    this.filter,
    this.items,
    this.searchLabel,
  }) : super(searchFieldLabel: searchLabel);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      textTheme: TextTheme(
        title: TextStyle(color: Colors.white, fontSize: 20),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      AnimatedOpacity(
        opacity: query.isNotEmpty ? 1.0 : 0.0,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        child: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const BackButtonIcon(),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    final String cleanQuery = query.toLowerCase().trim();
    final List<T> result = items
        .where(
          (item) => filter(item)
              .map((value) => value = value?.toLowerCase()?.trim())
              .any((value) => value?.contains(cleanQuery) == true),
        )
        .toList();

    return cleanQuery.isEmpty
        ? suggestion
        : result.isEmpty
            ? failure
            : ListView(children: result.map(builder).toList());
  }
}
