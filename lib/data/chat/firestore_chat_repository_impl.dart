import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import '../../data/chat/firestore_chat_repository.dart';

class FirestoreChatRepositoryImpl implements FirestoreChatRepository{
  final Firestore _firestore;

  const FirestoreChatRepositoryImpl(
      this._firestore,
  );


}