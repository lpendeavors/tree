import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'user_chat_group_member.g.dart';

@immutable
@JsonSerializable()
class UserChatGroupMember extends Equatable {
  final String docId;
  final String fullName;
  final bool groupAdmin;
  final String image;
  final String tokenID;
  final String uid;

  const UserChatGroupMember({
    this.uid,
    this.image,
    this.fullName,
    this.docId,
    this.groupAdmin,
    this.tokenID,
  });

  factory UserChatGroupMember.fromJson(Map<String, dynamic> json) => _$UserChatGroupMemberFromJson(json);
  Map<String, dynamic> toJson() => _$UserChatGroupMemberToJson(this);

  @override 
  List get props => [
    uid,
    image,
    fullName,
    docId,
    groupAdmin,
    tokenID,
  ];

  @override
  bool get stringify => true;
}