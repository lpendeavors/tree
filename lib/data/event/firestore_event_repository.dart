import 'package:meta/meta.dart';
import '../../models/old/event_entity.dart';
import 'dart:async';

abstract class FirestoreEventRepository {
  Stream<EventEntity> getById(String eventId);

  Stream<List<EventEntity>> get();

  Stream<List<EventEntity>> getByOwner(String ownerId);

  Future<Map<String, String>> save(
    String ownerId,
    String ownerEmail,
    String ownerName,
    String ownerImage,
    String token,
    bool isChurch,
    String id,
    String title,
    String description,
    int type,
    DateTime startDate,
    DateTime startTime,
    DateTime endDate,
    DateTime endTime,
    List<String> images,
    String webAddress,
    double cost,
    String venue,
    double latitude,
    double longitude,
    double budget,
    bool isSponsored,
    bool byAdmin,
    bool isVerified,
  );

  Future<List<EventEntity>> runSearchQuery(String query);
}