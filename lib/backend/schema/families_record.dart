import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FamiliesRecord extends FirestoreRecord {
  FamiliesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "created_by" field.
  String? _createdBy;
  String get createdBy => _createdBy ?? '';
  bool hasCreatedBy() => _createdBy != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "members" field.
  List<String>? _members;
  List<String> get members => _members ?? const [];
  bool hasMembers() => _members != null;

  // "family_code" field.
  String? _familyCode;
  String get familyCode => _familyCode ?? '';
  bool hasFamilyCode() => _familyCode != null;

  // "is_active" field.
  bool? _isActive;
  bool get isActive => _isActive ?? false;
  bool hasIsActive() => _isActive != null;

  // "admin_roles" field.
  List<String>? _adminRoles;
  List<String> get adminRoles => _adminRoles ?? const [];
  bool hasAdminRoles() => _adminRoles != null;

  // "is_private" field.
  bool? _isPrivate;
  bool get isPrivate => _isPrivate ?? false;
  bool hasIsPrivate() => _isPrivate != null;

  // "owner" field.
  String? _owner;
  String get owner => _owner ?? '';
  bool hasOwner() => _owner != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _description = snapshotData['description'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _createdBy = snapshotData['created_by'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _members = getDataList(snapshotData['members']);
    _familyCode = snapshotData['family_code'] as String?;
    _isActive = snapshotData['is_active'] as bool?;
    _adminRoles = getDataList(snapshotData['admin_roles']);
    _isPrivate = snapshotData['is_private'] as bool?;
    _owner = snapshotData['owner'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('families');

  static Stream<FamiliesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => FamiliesRecord.fromSnapshot(s));

  static Future<FamiliesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => FamiliesRecord.fromSnapshot(s));

  static FamiliesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      FamiliesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static FamiliesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      FamiliesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'FamiliesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is FamiliesRecord &&
      reference.path.hashCode == other.reference.path.hashCode &&
      name == other.name &&
      description == other.description &&
      photoUrl == other.photoUrl &&
      createdBy == other.createdBy &&
      createdTime == other.createdTime &&
      const ListEquality().equals(members, other.members) &&
      familyCode == other.familyCode &&
      isActive == other.isActive &&
      const ListEquality().equals(adminRoles, other.adminRoles) &&
      isPrivate == other.isPrivate;
}

Map<String, dynamic> createFamiliesRecordData({
  String? name,
  String? description,
  String? photoUrl,
  String? createdBy,
  DateTime? createdTime,
  String? familyCode,
  bool? isActive,
  bool? isPrivate,
  String? owner,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'description': description,
      'photo_url': photoUrl,
      'created_by': createdBy,
      'created_time': createdTime,
      'family_code': familyCode,
      'is_active': isActive,
      'is_private': isPrivate,
      'owner': owner,
    }.withoutNulls,
  );

  return firestoreData;
}

class FamiliesRecordDocumentEquality implements Equality<FamiliesRecord> {
  const FamiliesRecordDocumentEquality();

  @override
  bool equals(FamiliesRecord? e1, FamiliesRecord? e2) {
    const listEquality = ListEquality();
    return e1?.name == e2?.name &&
        e1?.description == e2?.description &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.createdBy == e2?.createdBy &&
        e1?.createdTime == e2?.createdTime &&
        listEquality.equals(e1?.members, e2?.members) &&
        e1?.familyCode == e2?.familyCode &&
        e1?.isActive == e2?.isActive &&
        listEquality.equals(e1?.adminRoles, e2?.adminRoles) &&
        e1?.isPrivate == e2?.isPrivate;
  }

  @override
  int hash(FamiliesRecord? e) => const ListEquality().hash([
        e?.name,
        e?.description,
        e?.photoUrl,
        e?.createdBy,
        e?.createdTime,
        e?.members,
        e?.familyCode,
        e?.isActive,
        e?.adminRoles,
        e?.isPrivate
      ]);

  @override
  bool isValidKey(Object? o) => o is FamiliesRecord;
}
