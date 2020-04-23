import 'dart:async';

import 'package:meta/meta.dart';
import 'package:treeapp/models/new/room_entity.dart';

abstract class FirestoreRoomRepository {
  Stream<List<RoomEntity>> rooms({
    @required String uid,
  });
}