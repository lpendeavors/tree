import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

const kListStringEquality = ListEquality<String>();

DocumentReference documentReferenceFromJson(DocumentReference ref) => ref;
DocumentReference documentReferenceToJson(DocumentReference ref) => ref;

Timestamp timestampFromJson(Timestamp timestamp) => timestamp;
Timestamp timestampToJson(Timestamp timestamp) => timestamp;

Map<String, dynamic> withId(DocumentSnapshot doc) => CombinedMapView([
      doc.data(),
      <String, dynamic>{'documentId': doc.id}
    ]);

List<String> createSearchData(String text) {
  List<String> searchList = List();
  String temp = "";

  for (int i = 0; i < text.length; i++) {
    temp = temp + text[i];
    searchList.add(temp.toLowerCase());
  }

  return searchList;
}
