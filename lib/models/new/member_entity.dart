import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import '../../util/model_utils.dart';
import '../firebase_model.dart';

part 'member_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class MemberEntity extends Equatable implements FirebaseModel {
  final String uid;
  final String name;
  final String photo;
  final String room;

  const MemberEntity({
    this.uid,
    this.name,
    this.photo,
    this.room
  });

  String get id => this.uid;

  factory MemberEntity.fromDocumentSnapshot(DocumentSnapshot doc) =>
      _$MemberEntityFromJson(withId(doc));

  Map<String, dynamic> toJson() => _$MemberEntityToJson(this);

  @override
  List get props {
    return [
      uid,
      name,
      photo,
      room
    ];
  }

  @override
  bool get stringify => true;
}