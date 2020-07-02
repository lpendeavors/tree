import 'package:meta/meta.dart';
import '../../pages/create_message/create_message_state.dart';
import '../../models/old/group_entity.dart';

abstract class FirestoreGroupRepository {
  Stream<GroupEntity> getById({
    @required String groupId,
  });

  Stream<List<GroupEntity>> get();

  Future<Map<String, dynamic>> save(
    String groupId,
    List<MemberItem> members,
    bool isPrivate,
    bool isGroup,
    bool isRoom,
    bool isConversation,
    String ownerId,
    bool byAdmin,
    bool isVerified,
  );

  Future<List<GroupEntity>> runSearchQuery(
      String query
  );
}