import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import './firestore_event_repository.dart';
import '../../models/old/event_entity.dart';

class FirestoreEventRepositoryImpl implements FirestoreEventRepository {
  final Firestore _firestore;
  final FirebaseStorage _storage;

  const FirestoreEventRepositoryImpl(
    this._firestore,
    this._storage
  );

  @override
  Stream<List<EventEntity>> get() {
    var now = new DateTime.now();
    var yesterday = new DateTime(now.year, now.month, now.day - 1);

    return _firestore
      .collection('eventBase')
      // .where('eventStartDate', isGreaterThanOrEqualTo: yesterday)
      .snapshots()
      .map(_toEntities);
  }

  @override
  Stream<EventEntity> getById(String eventId) {
    return _firestore
      .collection('eventBase')
      .document(eventId)
      .snapshots()
      .map((snapshot) => EventEntity.fromDocumentSnapshot(snapshot));
  }

  @override
  Stream<List<EventEntity>> getByOwner(String ownerId) {
    return _firestore
      .collection('eventBase')
      .where('ownerId', isEqualTo: ownerId)
      // .orderBy('eventStartDate')
      .snapshots()
      .map(_toEntities);
  }

  @override
  Future<void> save(
    String ownerId,
    String ownerEmail,
    String ownerName,
    String ownerImage,
    String token,
    bool isChurch,
    String id,
    String title,
    String description,
    int type,
    DateTime startDate,
    DateTime startTime,
    DateTime endDate,
    DateTime endTime,
    List<String> images,
    String webAddress,
    double cost,
    String venue,
    double latitude,
    double longitude,
    double budget,
    bool isSponsored,
    bool byAdmin,
    bool isVerified,
  ) async {
    List<String> imageUrls = await Future.wait(
      images.map((image) async {
        String id = Uuid().v1();
        StorageReference storageRef = _storage.ref().child(id);
        StorageUploadTask upload = storageRef.putFile(File(image));
        StorageTaskSnapshot task = await upload.onComplete;
        String url = await task.ref.getDownloadURL();

        return url;
      }).toList(),
    );

    final event = <String, dynamic>{
      'attending': [ownerId],
      'attendingUsers': [
        {
          'email': ownerEmail,
          'fullName': ownerName,
          'image': ownerImage,
          'uid': ownerId,
        }
      ],
      'byAdmin': byAdmin,
      'clicks': [],
      'createdAt': FieldValue.serverTimestamp(),
      'email': ownerEmail,
      'eventData': imageUrls.map((image) {
        return {
          'imageUrl': image,
          'type': 1,
        };
      }),
      'eventDetails': description,
      'eventEndDate': endDate,
      'eventEndTime': endTime,
      'eventindex': type,
      'eventLatitude': latitude,
      'eventLongitude': longitude,
      'eventPrice': cost,
      'eventStartDate': startDate,
      'eventStartTime': startTime,
      'eventTitle': title,
      'eventWebAddress': webAddress,
      'fullName': ownerName,
      'image': ownerImage,
      'isChurch': isChurch,
      'isReported': false,
      'isSponsored': isSponsored,
      'isVerified': isVerified,
      'location': venue,
      'ownerId': ownerId,
      'pushNotificationToken': token,
      'sponsorFee': budget,
      'sponsorMaxReach': 0,
      'sponsorMinReach': 0,
      'status': 0,
      'type': 4,
      'uid': ownerId,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (id != null) {
      return _firestore
        .collection('eventBase')
        .document(id)
        .setData(event, merge: true);
    } else {
      return _firestore
        .collection('eventBase')
        .add(event);
    }
  }

  List<EventEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((documentSnapshot) {
      return EventEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }
}