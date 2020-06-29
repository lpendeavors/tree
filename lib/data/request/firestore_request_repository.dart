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

  Future<void> saveRequest({
    @required String to,
    @required String toUser,
    @required String from,
    @required String fromUser,
    @required String image,
    @required String token,
  });
}