import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../util/model_utils.dart';
import '../firebase_model.dart';

part 'request_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class RequestEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final String from;
  final String to;

  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final Timestamp date;

  const RequestEntity({
    this.documentId,
    this.from,
    this.to,
    this.date
  });

  String get id => this.documentId;

  factory RequestEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$RequestEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$RequestEntityToJson(this);

  @override
  List get props {
    return [
      documentId,
      from,
      to,
      date
    ];
  }

  @override
  bool get stringify => true;
}