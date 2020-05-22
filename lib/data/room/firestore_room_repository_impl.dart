import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../../models/new/room_entity.dart';
import 'package:tuple/tuple.dart';
import './firestore_room_repository.dart';

class FirestoreRoomRepositoryImpl implements FirestoreRoomRepository{
  final Firestore _firestore;

  const FirestoreRoomRepositoryImpl(this._firestore);

  @override
  Stream<List<RoomEntity>> rooms({
    String uid,
  }) {
    return _firestore
        .collectionGroup('participants')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .asyncMap(_toEntities);
  }

  Future<List<RoomEntity>> _toEntities(QuerySnapshot querySnapshot) async {
    List<String> ids = [];
    List<RoomEntity> result = [];

    for(var i = 0; i < querySnapshot.documents.length; i++) {
      ids.add(querySnapshot.documents[i].data['room']);
    }

    await Future.forEach(ids, (id) async {
      QuerySnapshot snapshot = await _firestore.collection('(rooms)').where(FieldPath.documentId, isEqualTo: id).getDocuments();
      result.add(RoomEntity.fromDocumentSnapshot(snapshot.documents[0]));
    });

    return result;
  }
}