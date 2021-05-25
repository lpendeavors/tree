import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Message
///
class NotLoggedInError {
  const NotLoggedInError();
}

///
/// State
///
@immutable
class HomeTabsState extends Equatable {
  final bool hasMessages;
  final bool hasRequests;
  final bool isLoading;
  final Object error;

  const HomeTabsState({
    @required this.hasMessages,
    @required this.hasRequests,
    @required this.isLoading,
    @required this.error,
  });

  HomeTabsState copyWith({hasMessages, hasRequests, isLoading, error}) {
    return HomeTabsState(
      hasMessages: hasMessages ?? this.hasMessages,
      hasRequests: hasRequests ?? this.hasRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List get props => [
        hasMessages,
        hasRequests,
        isLoading,
        error,
      ];

  @override
  bool get stringify => true;
}
