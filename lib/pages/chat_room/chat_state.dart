import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class FeedItem extends Equatable {
  final String id;

  const FeedItem({
    @required this.id,
  });

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;
}