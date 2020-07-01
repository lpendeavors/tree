import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Message
///
abstract class ProfileMessage {
  const ProfileMessage();
}

///
/// State
///
@immutable
class SearchState extends Equatable {
  final List<dynamic> results;
  final bool isLoading;
  final Object error;

  const SearchState({
    @required this.results,
    @required this.isLoading,
    @required this.error
  });

  SearchState copyWith({results, isLoading, error}) {
    return SearchState(
        results: results ?? this.results,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error
    );
  }

  @override
  List get props => [
    results,
    isLoading,
    error
  ];

  @override
  bool get stringify => true;
}