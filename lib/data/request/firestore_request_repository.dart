import '../../models/old/request_entity.dart';
import '../../models/old/user_entity.dart';
import 'package:meta/meta.dart';

abstract class FirestoreRequestRepository {
  Stream<RequestEntity> requestById({
    @required String requestId,
  });

  Stream<List<UserEntity>> requestsByOwner({
    @required String uid,
  });

  Stream<List<UserEntity>> requestsByUser({
    @required String uid,
  });

  Future<void> addRequest({
    @required String toName,
    @required String toId,
    @required String fromName,
    @required String fromId,
    @required String image,
    @required String token,
  });

  Future<void> acceptRequest({
    @required String toName,
    @required String toId,
    @required String fromName,
    @required String fromId,
    @required String image,
    @required String token,
  });

  Future<void> declineRequest({
    @required String toName,
    @required String toId,
    @required String fromName,
    @required String fromId,
    @required String image,
    @required String token,
  });
}
