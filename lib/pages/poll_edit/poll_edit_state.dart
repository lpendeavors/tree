import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// 
/// EditPollMessage
///
@immutable
abstract class EditPollMessage {}

@immutable
abstract class PollAddedMessage implements EditPollMessage {
  const PollAddedMessage();
}

class PollAddedMessageSuccess implements PollAddedMessage {
  const PollAddedMessageSuccess();
}

class PollAddedMessageError implements PollAddedMessage {
  final Object error;
  const PollAddedMessageError(this.error);
}

@immutable
abstract class PollError {}

class NotLoggedInError {
  const NotLoggedInError();
}

@immutable
class EditPollState extends Equatable {
  final FeedPollItem pollItem;
  final bool isLoading;
  final Object error;

  const EditPollState({
    @required this.pollItem,
    @required this.isLoading,
    @required this.error,
  });

  EditPollState copyWith({pollItem, isLoading, error}) {
    return EditPollState(
      pollItem: pollItem ?? this.pollItem,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
    pollItem,
    isLoading,
    error,
  ];

  @override
  bool get stringify => true;
}

@immutable
class FeedPollItem extends Equatable {
  final String id;

  const FeedPollItem({
    @required this.id,
  });

  @override
  List get props => [
    id,
  ];

  @override
  bool get stringify => true;
}