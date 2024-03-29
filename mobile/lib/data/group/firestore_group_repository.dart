import 'package:meta/meta.dart';
import 'package:treeapp/user_bloc/user_login_state.dart';
import 'package:treeapp/pages/create_message/create_message_state.dart';
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
    String groupName,
    String groupImage,
    String groupDescription,
    bool mediaChanged,
  );

  Future<Map<String, dynamic>> launchDM(String userID, LoggedInUser loginState);

  Future<List<GroupEntity>> runSearchQuery(String query);

  Stream<List<GroupEntity>> getGroupsByUser(
    String uid,
  );

  Stream<List<GroupEntity>> getRoomsByUser(
    String uid,
  );

  Stream<List<GroupEntity>> getDefaultRooms();

  Future<void> joinGroup(
    String groupId,
    String uid,
    String image,
    String name,
  );

  Stream<List<GroupEntity>> getChurchRoom(String churchId);

  Future<void> delete(String groupId, bool permanent);

  Future<void> leave(String groupId, String userId);

  Future<void> makeAdmin(String groupId, String userId);
}
