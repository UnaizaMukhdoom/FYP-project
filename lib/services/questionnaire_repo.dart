import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

/// Immutable config model for the questionnaire (read from Firestore).
class QuestionnaireConfig {
  final List<String> bodyTypes;
  final List<String> sizeRanges;
  final List<String> fitPrefs;
  final List<String> styleGoals;
  final double heightMin, heightMax;
  final double weightMin, weightMax;

  const QuestionnaireConfig({
    required this.bodyTypes,
    required this.sizeRanges,
    required this.fitPrefs,
    required this.styleGoals,
    required this.heightMin,
    required this.heightMax,
    required this.weightMin,
    required this.weightMax,
  });

  factory QuestionnaireConfig.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? <String, dynamic>{};

    List<String> list(String key) =>
        (data[key] as List? ?? const []).map((e) => e.toString()).toList();

    double parseNumber(String key, double fallback) {
      final v = data[key];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? fallback;
      return fallback;
    }

    return QuestionnaireConfig(
      bodyTypes: list('bodyTypes'),
      sizeRanges: list('sizeRanges'),
      fitPrefs: list('fitPrefs'),
      styleGoals: list('styleGoals'),
      heightMin: parseNumber('heightMin', 120),
      heightMax: parseNumber('heightMax', 210),
      weightMin: parseNumber('weightMin', 35),
      weightMax: parseNumber('weightMax', 140),
    );
  }
}

/// Repository for reading the questionnaire configuration.
class QuestionnaireRepo {
  static const QuestionnaireConfig _fallbackConfig = QuestionnaireConfig(
    bodyTypes: ['Hourglass', 'Triangle', 'Inverted triangle', 'Rectangle', 'Round'],
    sizeRanges: ['Regular', 'Plus size'],
    fitPrefs: ['Fitted', 'Loose', 'Relaxed', 'Tailored'],
    styleGoals: [
      'Learning how to complement my natural features',
      'Looking chic and fashionable',
      'Standing out from the crowd',
      'Shopping smart and buying less',
    ],
    heightMin: 120,
    heightMax: 210,
    weightMin: 35,
    weightMax: 140,
  );

  static Future<QuestionnaireConfig>? _assetConfigFuture;

  QuestionnaireRepo({
    FirebaseFirestore? firestore,
    this.collectionPath = 'config',
    this.documentId = 'questionnaire_v1',
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final String collectionPath;
  final String documentId;

  /// Fetch the configuration once.
  Future<QuestionnaireConfig> fetch() async {
    final ref = _db.collection(collectionPath).doc(documentId);
    final snap = await ref.get();
    if (!snap.exists) {
      return await _loadAssetOrFallback();
    }
    return QuestionnaireConfig.fromFirestore(snap);
  }

  /// Stream the configuration (auto-updates UI if the doc changes).
  Stream<QuestionnaireConfig> stream() {
    final ref = _db.collection(collectionPath).doc(documentId);
    return ref.snapshots().asyncMap((d) async {
      if (!d.exists) return await _loadAssetOrFallback();
      return QuestionnaireConfig.fromFirestore(d);
    });
  }

  static Future<QuestionnaireConfig> _loadAssetOrFallback() {
    _assetConfigFuture ??= _loadAssetConfig();
    return _assetConfigFuture!;
  }

  static Future<QuestionnaireConfig> _loadAssetConfig() async {
    try {
      final raw = await rootBundle.loadString('assets/data/questions.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final questions = data['questions'] as Map<String, dynamic>? ?? const {};

      List<String> listFor(String key, List<String> fallback) {
        final question = questions[key] as Map<String, dynamic>?;
        final opts = question?['options'] as List?;
        if (opts == null || opts.isEmpty) return fallback;
        return opts.map((e) => e.toString()).toList();
      }

      double rangeValue(String questionKey, String field, double fallback) {
        final question = questions[questionKey] as Map<String, dynamic>?;
        final range = question?['range'] as Map<String, dynamic>?;
        final value = range?[field];
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? fallback;
        return fallback;
      }

      final heightMin = rangeValue('height', 'min', _fallbackConfig.heightMin);
      final heightMaxRaw = rangeValue('height', 'max', _fallbackConfig.heightMax);
      final heightMax = heightMaxRaw > heightMin ? heightMaxRaw : heightMin + 1;
      final weightMin = rangeValue('weight', 'min', _fallbackConfig.weightMin);
      final weightMaxRaw = rangeValue('weight', 'max', _fallbackConfig.weightMax);
      final weightMax = weightMaxRaw > weightMin ? weightMaxRaw : weightMin + 1;

      return QuestionnaireConfig(
        bodyTypes: listFor('body_type', _fallbackConfig.bodyTypes),
        sizeRanges: listFor('size_range', _fallbackConfig.sizeRanges),
        fitPrefs: listFor('fit_prefs', _fallbackConfig.fitPrefs),
        styleGoals: listFor('style_goal', _fallbackConfig.styleGoals),
        heightMin: heightMin,
        heightMax: heightMax,
        weightMin: weightMin,
        weightMax: weightMax,
      );
    } catch (_) {
      return _fallbackConfig;
    }
  }
}
