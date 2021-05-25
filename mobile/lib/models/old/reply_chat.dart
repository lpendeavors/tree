import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'reply_chat.g.dart';

@immutable
@JsonSerializable()
class ReplyChat extends Equatable {
  final String chatId;
  final String churchName;
  final String docId;
  final String fullName;
  final String image;
  final bool isChurch;
  final bool isConversation;
  final bool isGroup;
  final bool isRoom;
  final bool isTree;
  final String pushNotificationToken;
  final String tokenID;
  final String uid;
  final String userImage;

  const ReplyChat({
    this.uid,
    this.fullName,
    this.isChurch,
    this.pushNotificationToken,
    this.image,
    this.docId,
    this.tokenID,
    this.churchName,
    this.isConversation,
    this.userImage,
    this.isGroup,
    this.isRoom,
    this.chatId,
    this.isTree,
  });

  factory ReplyChat.fromJson(Map<String, dynamic> json) => _$ReplyChatFromJson(json);
  Map<String, dynamic> toJson() => _$ReplyChatToJson(this);

  @override
  List get props {
    return [
      uid,
      fullName,
      isChurch,
      pushNotificationToken,
      image,
      docId,
      tokenID,
      churchName,
      isConversation,
      userImage,
      isGroup,
      isRoom,
      chatId,
      isTree,
    ];
  }

  @override
  bool get stringify => true;
}