// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReplyChat _$ReplyChatFromJson(Map<String, dynamic> json) {
  return ReplyChat(
    uid: json['uid'] as String,
    fullName: json['fullName'] as String,
    isChurch: json['isChurch'] as bool,
    pushNotificationToken: json['pushNotificationToken'] as String,
    image: json['image'] as String,
    docId: json['docId'] as String,
    tokenID: json['tokenID'] as String,
    churchName: json['churchName'] as String,
    isConversation: json['isConversation'] as bool,
    userImage: json['userImage'] as String,
    isGroup: json['isGroup'] as bool,
    isRoom: json['isRoom'] as bool,
    chatId: json['chatId'] as String,
    isTree: json['isTree'] as bool,
  );
}

Map<String, dynamic> _$ReplyChatToJson(ReplyChat instance) => <String, dynamic>{
      'chatId': instance.chatId,
      'churchName': instance.churchName,
      'docId': instance.docId,
      'fullName': instance.fullName,
      'image': instance.image,
      'isChurch': instance.isChurch,
      'isConversation': instance.isConversation,
      'isGroup': instance.isGroup,
      'isRoom': instance.isRoom,
      'isTree': instance.isTree,
      'pushNotificationToken': instance.pushNotificationToken,
      'tokenID': instance.tokenID,
      'uid': instance.uid,
      'userImage': instance.userImage,
    };
