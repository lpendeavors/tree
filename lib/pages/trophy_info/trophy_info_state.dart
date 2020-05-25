import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:treeapp/models/old/trophy.dart';

///
/// Message
///
abstract class TrophyInfoMessage {
  const TrophyInfoMessage();
}

///
/// Error
///
class TrophyInfoNotLoggedInError {
  const TrophyInfoNotLoggedInError();
}

///
/// State
///
@immutable
class TrophyInfoState extends Equatable {
  final bool isLoading;
  final Object error;
  final Trophy trophy;

  const TrophyInfoState({
    @required this.isLoading,
    @required this.error,
    @required this.trophy,
  });

  TrophyInfoState copyWith({isLoading, error, trophy}) {
    return TrophyInfoState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      trophy: trophy ?? this.trophy,
    );
  }

  @override
  List get props => [
    isLoading,
    error,
    trophy
  ];

  @override
  bool get stringify => true;
}