import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../util/model_utils.dart';
import '../firebase_model.dart';
import './owner_data.dart';


@immutable
@JsonSerializable(explicitToJson: true)
class CommentEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final String body;
  final List<String> likes;
  final OwnerData owner;
  final String parent;

  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final Timestamp date;

  const CommentEntity({
    this.documentId,
    this.body,
    this.likes,
    this.owner,
    this.parent,
    this.date,
  });

  String get id => this.documentId;

  factory CommentEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$CommentEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$CommentEntityToJson(this);

  @override
  List get props {
    return [
      documentId,
      body,
      likes,
      owner,
      parent,
      date,
    ];
  }

  @override
  bool get stringify => true;
}