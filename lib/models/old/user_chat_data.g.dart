// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_chat_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatData _$ChatDataFromJson(Map<String, dynamic> json) {
  return ChatData(
    tokenID: json['tokenID'] as String,
    docId: json['docId'] as String,
    image: json['image'] as String,
    uid: json['uid'] as String,
    isChurch: json['isChurch'] as bool,
    chatId: json['chatId'] as String,
    groupImage: json['groupImage'] as String,
    groupMembers: (json['groupMembers'] as List)
        ?.map((e) => e == null
            ? null
            : UserChatGroupMember.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    groupName: json['groupName'] as String,
    isConversation: json['isConversation'] as bool,
    isGroup: json['isGroup'] as bool,
    isRoom: json['isRoom'] as bool,
    isTree: json['isTree'] as bool,
    pushNotificationToken: json['pushNotificationToken'] as String,
  );
}

Map<String, dynamic> _$ChatDataToJson(ChatData instance) => <String, dynamic>{
      'chatId': instance.chatId,
      'docId': instance.docId,
      'groupImage': instance.groupImage,
      'groupMembers': instance.groupMembers?.map((e) => e?.toJson())?.toList(),
      'groupName': instance.groupName,
      'image': instance.image,
      'isChurch': instance.isChurch,
      'isConversation': instance.isConversation,
      'isGroup': instance.isGroup,
      'isRoom': instance.isRoom,
      'isTree': instance.isTree,
      'pushNotificationToken': instance.pushNotificationToken,
      'tokenID': instance.tokenID,
      'uid': instance.uid,
    };
