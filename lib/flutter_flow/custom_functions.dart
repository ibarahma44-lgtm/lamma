// lib/flutter_flow/custom_functions.dart
// -------------------------------------------------------------
// Your app‑wide helper functions live here.
// This refactor makes the family‑code generator more secure and
// adds an async helper that guarantees uniqueness inside Firestore.
// -------------------------------------------------------------

import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

// Alphanumeric *uppercase* alphabet.
const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
final _rand = math.Random.secure(); // Cryptographically secure RNG.

// Generates a random code of [length] characters.
String _randomCode(int length) =>
    List.generate(length, (_) => _chars[_rand.nextInt(_chars.length)]).join();

/// Use this when you just need *any* code and collisions are acceptable.
String generateFamilyCode({int length = 6}) => _randomCode(length);

/// Generates a code and checks Firestore so that every family_code is unique.
/// Throws if it cannot find a unique value within [maxAttempts].
Future<String> generateUniqueFamilyCode(
    {int length = 6, int maxAttempts = 8}) async {
  final coll = FirebaseFirestore.instance.collection('families');
  for (var i = 0; i < maxAttempts; i++) {
    final code = _randomCode(length);
    final snap =
        await coll.where('family_code', isEqualTo: code).limit(1).get();
    if (snap.docs.isEmpty) return code; // success!
  }
  throw Exception(
      'Unable to generate a unique family code after $maxAttempts attempts');
}

// -------------------------------------------------------------
//  EXAMPLE USAGE
// -------------------------------------------------------------
// final code = await generateUniqueFamilyCode();
// await FamiliesRecord.collection.doc().set({
//   ...createFamiliesRecordData(familyCode: code, ...),
// });
