import 'package:meta/meta.dart';
import '../../models/old/chat_entity.dart';

abstract class FirestoreChatRepository {
  Stream<ChatEntity> getById({
    @required String chatId,
  });

  Stream<List<ChatEntity>> get();

  Stream<List<ChatEntity>> getByOwner(String ownerId);

  Stream<List<ChatEntity>> getByUser({
    String uid,
    List<String> chatIds,
  });

  Stream<List<ChatEntity>> getByGroup(String groupId);
}