import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../util/model_utils.dart';
import 'firebase_model.dart';

part 'trophy_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class TrophyEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final String icon;
  final String key;
  final String title;
  final int value;

  const TrophyEntity({
    this.documentId,
    this.icon,
    this.key,
    this.title,
    this.value
  });

  String get id => this.documentId;

  factory TrophyEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$TrophyEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$TrophyEntityToJson(this);

  @override
  List get props {
    return [
      documentId,
      icon,
      key,
      title,
      value
    ];
  }

  @override
  bool get stringify => true;
}