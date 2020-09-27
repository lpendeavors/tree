import 'package:cloud_firestore/cloud_firestore.dart';
import './firestore_report_repository.dart';
import '../../models/old/report_entity.dart';

class FirestoreReportRepositoryImpl implements FirestoreReportRepository {
  final Firestore _firestore;

  const FirestoreReportRepositoryImpl(
    this._firestore,
  );

  @override
  Stream<List<ReportEntity>> get() {
    return _firestore
        .collection('reportBase')
        .where('status', isEqualTo: 0)
        .orderBy('time')
        .snapshots()
        .map(_toEntities);
  }

  static List<ReportEntity> _toEntities(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((snapshot) {
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
        'reportType': 0,
        'status': 0,
        'time': DateTime.now().millisecondsSinceEpoch,
        'timeUpdated': DateTime.now().millisecondsSinceEpoch,
        'tokenId': token,
        'uid': ownerId,
        'updatedAt': FieldValue.serverTimestamp(),
        'visibility': 0,
        'postId': postId,
      };

      _firestore.collection('reportBase').add(report);

      _firestore.document('userBase/$ownerId').updateData({
        'muted': FieldValue.arrayUnion([postId]),
      });
    };

    return _firestore.runTransaction(transactionHandler).then((_) {
      //
    });
  }
}
