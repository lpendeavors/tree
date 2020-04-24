import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../util/model_utils.dart';
import '../firebase_model.dart';

part 'room_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class RoomEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final String title;
  final String about;
  final String photo;
  final int accessibility;

  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final Timestamp created;

  const RoomEntity({
    this.documentId,
    this.title,
    this.about,
    this.photo,
    this.accessibility,
    this.created,
  });

  String get id => this.documentId;

  factory RoomEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$RoomEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$RoomEntityToJson(this);

  @override
  List get props {
    return [
      documentId,
      title,
      about,
      photo,
      accessibility,
      created
    ];
  }

  @override
  bool get stringify => true;
}