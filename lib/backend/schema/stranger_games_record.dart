import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class StrangerGamesRecord extends FirestoreRecord {
  StrangerGamesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // "topic" field.
  String? _topic;
  String get topic => _topic ?? '';
  bool hasTopic() => _topic != null;

  // "createdTime" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  void _initializeFields() {
    _category = snapshotData['category'] as String?;
    _topic = snapshotData['topic'] as String?;
    _createdTime = snapshotData['createdTime'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('stranger_games');

  static Stream<StrangerGamesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StrangerGamesRecord.fromSnapshot(s));

  static Future<StrangerGamesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => StrangerGamesRecord.fromSnapshot(s));

  static StrangerGamesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      StrangerGamesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static StrangerGamesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      StrangerGamesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'StrangerGamesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StrangerGamesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createStrangerGamesRecordData({
  String? category,
  String? topic,
  DateTime? createdTime,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'category': category,
      'topic': topic,
      'createdTime': createdTime,
    }.withoutNulls,
  );

  return firestoreData;
}
