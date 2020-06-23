import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:treeapp/models/old/church_info.dart';

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
  final List<SearchResult> results;
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

class SearchResult extends Equatable{
  final String id;
  final bool isChurch;
  final String image;
  final String churchName;
  final String fullName;
  final String churchDenomination;
  final ChurchInfo churchInfo;
  final String city;
  final String churchAddress;

  const SearchResult({
    @required this.id,
    @required this.isChurch,
    @required this.image,
    @required this.churchName,
    @required this.fullName,
    @required this.churchDenomination,
    @required this.churchInfo,
    @required this.city,
    @required this.churchAddress,
  });

  @override
  List get props => [
    id,
    isChurch,
    image,
    churchName,
    fullName,
    churchDenomination,
    churchInfo,
    city,
    churchAddress
  ];

  @override
  bool get stringify => true;
}