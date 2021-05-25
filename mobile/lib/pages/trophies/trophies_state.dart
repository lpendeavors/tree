import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../models/old/trophy.dart';

///
/// Message
///
abstract class TrophiesMessage {
  const TrophiesMessage();
}

///
/// Error
///
class TrophiesNotLoggedInError {
  const TrophiesNotLoggedInError();
}

///
/// State
///
@immutable
class TrophiesState extends Equatable {
  final bool isLoading;
  final Object error;
  final List<Trophy> trophies;

  const TrophiesState({
    @required this.isLoading,
    @required this.error,
    @required this.trophies,
  });

  TrophiesState copyWith({isLoading, error, trophies}) {
    return TrophiesState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      trophies: trophies ?? this.trophies,
    );
  }

  @override
  List get props => [
    isLoading,
    error,
    trophies
  ];

  @override
  bool get stringify => true;
}