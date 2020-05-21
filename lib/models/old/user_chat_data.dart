import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import './user_chat_group_member.dart';

part 'user_chat_data.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class ChatData extends Equatable {
  final String chatId;
  final String docId;
  final String groupImage;
  final List<UserChatGroupMember> groupMembers;
  final String groupName;
  final String image;
  final bool isChurch;
  final bool isConversation;
  final bool isGroup;
  final bool isRoom;
  final bool isTree;
  final String pushNotificationToken;
  final String tokenID;
  final String uid;

  const ChatData({
    this.tokenID,
    this.docId,
    this.image,
    this.uid,
    this.isChurch,
    this.chatId,
    this.groupImage,
    this.groupMembers,
    this.groupName,
    this.isConversation,
    this.isGroup,
    this.isRoom,
    this.isTree,
    this.pushNotificationToken,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) => _$ChatDataFromJson(json);
  Map<String, dynamic> toJson() => _$ChatDataToJson(this);

  @override
  List get props => [
    tokenID,
    docId,
    image,
    uid,
    isChurch,
    chatId,
    groupImage,
    groupMembers,
    groupName,
    isConversation,
    isGroup,
    isRoom,
    isTree,
    pushNotificationToken,
  ];

  @override
  bool get stringify => true;
}