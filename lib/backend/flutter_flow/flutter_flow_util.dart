import 'package:cloud_firestore/cloud_firestore.dart';

Future<int> queryCollectionCount(
  CollectionReference collection, {
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) async {
  Query query = collection;
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  if (limit > 0) {
    query = query.limit(limit);
  }
  final snapshot = await query.count().get();
  return snapshot.count ?? 0;
}

Stream<List<T>> queryCollection<T>(
  CollectionReference collection,
  T Function(DocumentSnapshot) fromSnapshot, {
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) {
  Query query = collection;
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  if (limit > 0) {
    query = query.limit(limit);
  }
  if (singleRecord) {
    return query.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      }
      return [fromSnapshot(snapshot.docs.first)];
    });
  }
  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => fromSnapshot(doc)).toList();
  });
}

Future<List<T>> queryCollectionOnce<T>(
  CollectionReference collection,
  T Function(DocumentSnapshot) fromSnapshot, {
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) async {
  Query query = collection;
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  if (limit > 0) {
    query = query.limit(limit);
  }
  final snapshot = await query.get();
  if (singleRecord) {
    if (snapshot.docs.isEmpty) {
      return [];
    }
    return [fromSnapshot(snapshot.docs.first)];
  }
  return snapshot.docs.map((doc) => fromSnapshot(doc)).toList();
}
