import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../util/model_utils.dart';
import '../firebase_model.dart';
import './owner_data.dart';
import './location_data.dart';
import './asset_data.dart';

part 'event_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class EventEntity extends Equatable implements FirebaseModel {
  final String documentId;
  final List<AssetData> assets;
  final String description;
  final bool global;
  final LocationData location;
  final OwnerData owner;
  final String title;
  final int type;

  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final Timestamp startDate;

  @JsonKey(
    fromJson: timestampFromJson,
    toJson: timestampToJson,
  )
  final Timestamp endDate;

  const EventEntity({
    this.documentId,
    this.assets,
    this.description,
    this.global,
    this.location,
    this.owner,
    this.title,
    this.type,
    this.startDate,
    this.endDate
  });

  String get id => this.documentId;

  factory EventEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$EventEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$EventEntityToJson(this);

  @override
  List get props {
    return [
      documentId,
      assets,
      description,
      global,
      location,
      owner,
      title,
      type,
      startDate,
      endDate
    ];
  }

  @override
  bool get stringify => true;
}