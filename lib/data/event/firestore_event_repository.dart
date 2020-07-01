import 'package:meta/meta.dart';
import '../../models/old/event_entity.dart';
import 'dart:async';

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
    List<String> images,
    String webAddress,
    double cost,
    String venue,
    double budget,
    bool isSponsored,
  );

  Future<List<EventEntity>> runSearchQuery(String query);
}