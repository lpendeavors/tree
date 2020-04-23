import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../util/model_utils.dart';
import '../firebase_model.dart';
import './owner_data.dart';
import './asset_data.dart';


@immutable
@JsonSerializable(explicitToJson: true)
class MessageEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final String body;
  final OwnerData sender;
  final AssetData asset;

  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final Timestamp date;

  const MessageEntity({
    this.documentId,
    this.body,
    this.sender,
    this.asset,
    this.date
  });

  String get id => this.documentId;

  factory MessageEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$MessageEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$MessageEntityToJson(this);

  @override
  List get props {
    return [
      documentId,
      body,
      sender,
      asset,
      date
    ];
  }

  @override
  bool get stringify => true;
}