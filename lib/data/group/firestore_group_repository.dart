import 'package:meta/meta.dart';
import '../../models/old/group_entity.dart';

abstract class FirestoreGroupRepository {
  Stream<GroupEntity> getById({
    @required String groupId,
  });

  Stream<List<GroupEntity>> get();
}