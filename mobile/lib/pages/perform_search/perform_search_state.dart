import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:treeapp/models/old/user_entity.dart';

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
  final UserEntity user;
  final bool isLoading;
  final Object error;

  const SearchState({
    @required this.results,
    @required this.user,
    @required this.isLoading,
    @required this.error
  });

  SearchState copyWith({results, user, isLoading, error}) {
    return SearchState(
        results: results ?? this.results,
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error
    );
  }

  @override
  List get props => [
    results,
    user,
    isLoading,
    error
  ];

  @override
  bool get stringify => true;
}