import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../util/model_utils.dart';
import 'firebase_model.dart';
import 'owner_data.dart';
import 'asset_data.dart';

part 'post_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class PostEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final String body;
  final bool global;
  final List<String> likes;
  final List<String> tags;
  final OwnerData owner;
  final List<AssetData> assets;

  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final Timestamp date;

  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final Timestamp edited;

  const PostEntity({
    this.documentId,
    this.date,
    this.edited,
    this.body,
    this.global,
    this.likes,
    this.tags,
    this.owner,
    this.assets
  });

  String get id => this.documentId;

  factory PostEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$PostEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$PostEntityToJson(this);

  @override
  List get props {
    return [
      documentId,
      date,
      edited,
      body,
      global,
      likes,
      tags,
      owner,
      assets
    ];
  }

  @override
  bool get stringify => true;
}