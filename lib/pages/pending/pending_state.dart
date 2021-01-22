import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Message
///
abstract class PendingMessage {
  const PendingMessage();
}

abstract class PendingApprovalMessage {
  const PendingApprovalMessage();
}

class PendingApprovalSuccess implements PendingApprovalMessage {
  const PendingApprovalSuccess();
}

class PendingApprovalError implements PendingApprovalMessage {
  final Object error;
  const PendingApprovalError(this.error);
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
class PendingState extends Equatable {
  final bool isLoading;
  final Object error;
  final List<PendingItem> pending;

  const PendingState({
    @required this.isLoading,
    @required this.error,
    @required this.pending,
  });

  PendingState copyWith({isLoading, error, pending}) {
    return PendingState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      pending: pending ?? this.pending,
    );
  }

  @override
  List get props => [
        isLoading,
        error,
        pending,
      ];

  @override
  bool get stringify => true;
}

@immutable
class PendingItem extends Equatable {
  final String id;
  final String image;
  final String name;
  final bool isChurch;
  final String denomination;
  final String churchAddress;
  final String city;
  final String churchName;
  final String token;

  const PendingItem({
    @required this.id,
    @required this.image,
    @required this.name,
    @required this.isChurch,
    @required this.denomination,
    @required this.churchAddress,
    @required this.city,
    @required this.churchName,
    @required this.token,
  });

  @override
  List get props => [
        id,
        image,
        name,
        isChurch,
        denomination,
        churchAddress,
        city,
        churchName,
        token,
      ];

  @override
  bool get stringify => true;
}
