import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:treeapp/models/new/room_entity.dart';
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
        .where(FieldPath.documentId, isEqualTo: uid)
        .snapshots()
        .map(_toEntities);
  }

  List<RoomEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((documentSnapshot) {
      return RoomEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }
}