// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportEntity _$ReportEntityFromJson(Map<String, dynamic> json) {
  return ReportEntity(
    documentId: json['documentId'] as String,
    reportPost: json['reportPost'] == null
        ? null
        : ReportPost.fromJson(json['reportPost'] as Map<String, dynamic>),
    image: json['image'] as String,
    fullName: json['fullName'] as String,
    isChurch: json['isChurch'] as bool,
    time: json['time'] as int,
    uid: json['uid'] as String,
    userImage: json['userImage'] as String,
    churchName: json['churchName'] as String,
    tokenID: json['tokenID'] as String,
    status: json['status'] as int,
    email: json['email'] as String,
    phoneNo: json['phoneNo'] as String,
    databaseName: json['databaseName'] as String,
    visibility: json['visibility'] as int,
    updatedAt: timestampFromJson(json['updatedAt'] as Timestamp),
    createdAt: timestampFromJson(json['createdAt'] as Timestamp),
    timeUpdated: json['timeUpdated'] as int,
    ownerId: json['ownerId'] as String,
    country: json['country'] as String,
    gender: json['gender'] as int,
    username: json['username'] as String,
    byAdmin: json['byAdmin'] as bool,
    reportReason: json['reportReason'] as String,
    reportType: json['reportType'] as int,
  );
}

Map<String, dynamic> _$ReportEntityToJson(ReportEntity instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'byAdmin': instance.byAdmin,
      'churchName': instance.churchName,
      'country': instance.country,
      'databaseName': instance.databaseName,
      'email': instance.email,
      'fullName': instance.fullName,
      'gender': instance.gender,
      'image': instance.image,
      'isChurch': instance.isChurch,
      'ownerId': instance.ownerId,
      'phoneNo': instance.phoneNo,
      'reportPost': instance.reportPost?.toJson(),
      'reportReason': instance.reportReason,
      'reportType': instance.reportType,
      'status': instance.status,
      'time': instance.time,
      'timeUpdated': instance.timeUpdated,
      'tokenID': instance.tokenID,
      'uid': instance.uid,
      'userImage': instance.userImage,
      'username': instance.username,
      'visibility': instance.visibility,
      'createdAt': timestampToJson(instance.createdAt),
      'updatedAt': timestampToJson(instance.updatedAt),
    };
