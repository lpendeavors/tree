import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Message
///
abstract class ReportMessage {
  const ReportMessage();
}

///
/// Error
///
class NotLoggedInError {
  const NotLoggedInError();
}

///
/// State
///
@immutable
class ReportState extends Equatable {
  final bool isLoading;
  final Object error;
  final List<ReportItem> reported;

  const ReportState({
    @required this.isLoading,
    @required this.error,
    @required this.reported,
  });

  ReportState copyWith({isLoading, error, reported}) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      reported: reported ?? this.reported,
    );
  }

  @override
  List get props => [
        isLoading,
        error,
        reported,
      ];

  @override
  bool get stringify => true;
}

@immutable
class ReportItem extends Equatable {
  final String id;

  const ReportItem({
    @required this.id,
  });

  @override
  List get props => [id];

  @override
  bool get stringify => true;
}
