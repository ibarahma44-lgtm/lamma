import 'package:cloud_firestore/cloud_firestore.dart';
import '../flutter_flow/flutter_flow_util.dart';

class EventsRecord {
  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('events');

  static Stream<EventsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => EventsRecord.fromSnapshot(s));

  static Future<EventsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => EventsRecord.fromSnapshot(s));

  static EventsRecord fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    return EventsRecord(
      reference: snapshot.reference,
      title: data?['title'] as String?,
      description: data?['description'] as String?,
      date: data?['date'] as Timestamp?,
      familyRef: data?['family_ref'] as DocumentReference?,
    );
  }

  final DocumentReference reference;
  final String? title;
  final String? description;
  final Timestamp? date;
  final DocumentReference? familyRef;

  EventsRecord({
    required this.reference,
    this.title,
    this.description,
    this.date,
    this.familyRef,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'family_ref': familyRef,
    };
  }
}

Future<int> queryEventsRecordCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      EventsRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<EventsRecord>> queryEventsRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      EventsRecord.collection,
      EventsRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<EventsRecord>> queryEventsRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      EventsRecord.collection,
      EventsRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
