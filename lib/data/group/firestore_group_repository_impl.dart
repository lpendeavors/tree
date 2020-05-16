import 'package:cloud_firestore/cloud_firestore.dart';
import './firestore_group_repository.dart';
import '../../models/old/group_entity.dart';

class FirestoreGroupRepositoryImpl implements FirestoreGroupRepository {
  final Firestore _firestore;

  const FirestoreGroupRepositoryImpl(this._firestore);
  
  @override
  Stream<List<GroupEntity>> get() {
    return _firestore
      .collection('groupBase')
      .snapshots()
      .map(_toEntities);
  }

  @override
  Stream<GroupEntity> getById({String groupId}) {
    return _firestore
      .collection('groupBase')
      .document(groupId)
      .snapshots()
      .map((snapshot) => GroupEntity.fromDocumentSnapshot(snapshot));
  }

  List<GroupEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((documentSnapshot) {
      return GroupEntity.fromDocumentSnapshot(documentSnapshot);
    }).toList();
  }

}