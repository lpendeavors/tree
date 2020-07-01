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

  Stream<List<ChatEntity>> getByGroup(String roomId);

  Future<Map<String,String>> send(
    String message,
    int messageType,
    bool byAdmin,
    String chatId,
    String ownerName,
    String ownerEmail,
    String ownerImage,
    bool isVerified,
    bool isChurch,
    bool isRoom,
    String token,
    bool showDate,
  );
}