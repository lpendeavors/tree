import 'package:meta/meta.dart';
import '../../models/event_entity.dart';

abstract class FirestoreEventRepository {
  Stream<EventEntity> getById(String eventId);

  Stream<List<EventEntity>> get();

  Stream<List<EventEntity>> getByOwner(String ownerId);

  Future<Map<String, String>> save(
    String ownerId,
    String id,
    String title,
    DateTime startDate,
    DateTime startTime,
    DateTime endDate,
    DateTime endTime,
    String image,
    String webAddress,
    double cost,
    String venue,
    double budget
  );
}