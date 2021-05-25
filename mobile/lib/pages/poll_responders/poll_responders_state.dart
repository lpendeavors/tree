import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// PollRespondersMessage
///
@immutable
abstract class PollRespondersMessage {}

class NotLoggedInError {
  const NotLoggedInError();
}

@immutable
class PollRespondersState extends Equatable {
  final List<ResponderItem> responders;
  final bool isLoading;
  final Object error;

  const PollRespondersState({
    @required this.responders,
    @required this.isLoading,
    @required this.error,
  });

  PollRespondersState copyWith({responders, isLoading, error}) {
    return PollRespondersState(
      responders: responders ?? this.responders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
        responders,
        isLoading,
        error,
      ];

  @override
  bool get stringify => true;
}

@immutable
class ResponderItem extends Equatable {
  final String id;
  final String image;
  final String name;
  final String answer;

  const ResponderItem({
    @required this.id,
    @required this.image,
    @required this.name,
    @required this.answer,
  });

  @override
  List get props => [
        id,
        image,
        name,
        answer,
      ];

  @override
  bool get stringify => true;
}
