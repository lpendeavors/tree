import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

///
/// Error
///
@immutable
abstract class FeedError {}

class NotLoggedInError {
  const NotLoggedInError();
}

///
/// State
///
@immutable
class RoomListState extends Equatable {
  final List<RoomItem> roomItems;
  final bool isLoading;
  final Object error;

  const RoomListState({
    @required this.roomItems,
    @required this.isLoading,
    @required this.error,
  });

  RoomListState copyWith({roomItems, isLoading, error}) {
    return RoomListState(
      roomItems: roomItems ?? this.roomItems,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => null;

  @override
  bool get stringify => true;
}

@immutable
class RoomItem extends Equatable {
  final String id;
  final String imageUrl;
  final String roomTitle;
  final String previewText;
  final String chatTime;

  const RoomItem({
    @required this.id,
    @required this.imageUrl,
    @required this.roomTitle,
    @required this.previewText,
    @required this.chatTime,
  });

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;
}