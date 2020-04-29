import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'group_member.g.dart';

@immutable
@JsonSerializable()
class GroupMember extends Equatable {
  final String groupId;
  final String fullName;
  final bool groupAdmin;
  final String image;
  final String tokenID;
  final String uid;

  const GroupMember({
    this.groupId,
    this.uid,
    this.image,
    this.tokenID,
    this.fullName,
    this.groupAdmin,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) => _$GroupMemberFromJson(json);
  Map<String, dynamic> toJson() => _$GroupMemberToJson(this);

  @override
  List get props {
    return [
      groupAdmin,
      groupId,
      uid,
      image,
      tokenID,
      fullName,
    ];
  }

  @override
  bool get stringify => true;
}