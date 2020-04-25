import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../util/model_utils.dart';
import '../firebase_model.dart';

part 'report_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class ReportEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final String email;
  final String fromUID;
  final String name;
  final String reason;
  final String reporting;
  final int type;

  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final Timestamp date;

  const ReportEntity({
    this.documentId,
    this.email,
    this.fromUID,
    this.name,
    this.reason,
    this.reporting,
    this.type,
    this.date
  });

  String get id => this.documentId;

  factory ReportEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$ReportEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$ReportEntityToJson(this);

  @override
  List get props {
    return [
      documentId,
      email,
      fromUID,
      name,
      reason,
      reporting,
      type,
      date
    ];
  }

  @override
  bool get stringify => true;
}