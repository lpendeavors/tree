import 'package:cloud_firestore/cloud_firestore.dart';
import './firestore_report_repository.dart';
import '../../models/old/report_entity.dart';

class FirestoreReportRepositoryImpl implements FirestoreReportRepository {
  final FirebaseFirestore _firestore;

  const FirestoreReportRepositoryImpl(
    this._firestore,
  );

  @override
  Stream<List<ReportEntity>> get() {
    return _firestore
        .collection('reportBase')
        .where('status', isEqualTo: 0)
        .orderBy('time', descending: true)
        .snapshots()
        .map(_toEntities);
  }

  static List<ReportEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((snapshot) {
      return ReportEntity.fromDocumentSnapshot(snapshot);
    }).toList();
  }

  @override
  Future<void> save(
    String ownerId,
    String ownerEmail,
    String ownerName,
    String ownerImage,
    String token,
    bool byAdmin,
    bool isVerified,
    bool isChurch,
    String postId,
    String message,
    String userId,
    int reportType,
    String groupId,
  ) {
    final TransactionHandler transactionHandler = (tranaction) async {
      final report = <String, dynamic>{
        'byAdmin': byAdmin,
        'createdAt': FieldValue.serverTimestamp(),
        'email': ownerEmail,
        'fullName': ownerName,
        'image': ownerImage,
        'ownerId': ownerId,
        'reportReason': message,
        'reportType': reportType,
        'status': 0,
        'time': DateTime.now().millisecondsSinceEpoch,
        'timeUpdated': DateTime.now().millisecondsSinceEpoch,
        'tokenId': token,
        'uid': ownerId,
        'updatedAt': FieldValue.serverTimestamp(),
        'visibility': 0,
        'postId': postId,
        'userId': userId,
      };

      _firestore.collection('reportBase').add(report);

      _firestore.doc('userBase/$ownerId').update({
        'muted': FieldValue.arrayUnion([postId]),
      });
    };

    return _firestore.runTransaction(transactionHandler).then((_) {
      //
    });
  }

  @override
  Stream<List<ReportEntity>> getGroups() {
    return _firestore
        .collection('reportBase')
        .where('reportType', isEqualTo: 1)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Stream<List<ReportEntity>> getPosts() {
    return _firestore
        .collection('reportBase')
        .where('reportType', isEqualTo: 0)
        .snapshots()
        .map(_toEntities);
  }

  @override
  Future<void> saveUserReport(
    String ownerId,
    String ownerEmail,
    String ownerName,
    String ownerImage,
    String token,
    bool byAdmin,
    bool isVerified,
    bool isChurch,
    String message,
    String userId,
    int reportType,
    String groupId,
  ) {
    final TransactionHandler transactionHandler = (tranaction) async {
      final report = <String, dynamic>{
        'byAdmin': byAdmin,
        'createdAt': FieldValue.serverTimestamp(),
        'email': ownerEmail,
        'fullName': ownerName,
        'image': ownerImage,
        'ownerId': ownerId,
        'reportReason': message,
        'reportType': reportType,
        'status': 0,
        'time': DateTime.now().millisecondsSinceEpoch,
        'timeUpdated': DateTime.now().millisecondsSinceEpoch,
        'tokenId': token,
        'uid': ownerId,
        'updatedAt': FieldValue.serverTimestamp(),
        'visibility': 0,
        'userId': userId,
      };

      _firestore.collection('reportBase').add(report);

      _firestore.doc('userBase/$ownerId').update({
        'muted': FieldValue.arrayUnion([userId]),
      });
    };

    return _firestore.runTransaction(transactionHandler).then((_) {
      //
    });
  }
}
