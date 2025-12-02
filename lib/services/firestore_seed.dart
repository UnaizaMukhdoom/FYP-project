import 'package:cloud_firestore/cloud_firestore.dart';

/// Call this ONCE (manually) to create/update the config doc in Firestore.
Future<void> seedQuestionnaire({
  String collectionPath = 'config',
  String documentId = 'questionnaire_v1',
}) async {
  final db = FirebaseFirestore.instance;

  final payload = {
    "bodyTypes": [
      "Hourglass",
      "Triangle",
      "Inverted triangle",
      "Rectangle",
      "Round"
    ],
    "sizeRanges": ["Regular", "Plus size"],
    "fitPrefs": ["Fitted", "Loose", "Relaxed", "Tailored"],
    "styleGoals": [
      "Learning how to complement my natural features",
      "Looking chic and fashionable",
      "Standing out from the crowd",
      "Shopping smart and buying less"
    ],
    "heightMin": 120.0,
    "heightMax": 210.0,
    "weightMin": 35.0,
    "weightMax": 140.0,
    "updatedAt": FieldValue.serverTimestamp(),
  };

  await db.collection(collectionPath).doc(documentId).set(payload, SetOptions(merge: true));
}
