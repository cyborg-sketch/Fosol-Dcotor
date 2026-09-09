import 'package:hive_flutter/hive_flutter.dart';

/// Caches disease/treatment reference data locally so a common-disease result
/// can still be shown with no network — the offline P0 requirement. This is a
/// cache of curated data, never a substitute for the deterministic backend
/// ranking; when connectivity returns the farmer is prompted to re-verify.
class OfflineCache {
  static const _diseasesBox = 'cached_diseases';
  static const _treatmentsBox = 'cached_treatments';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_diseasesBox);
    await Hive.openBox(_treatmentsBox);
  }

  static Future<void> cacheDiseases(List<Map<String, dynamic>> diseases) async {
    final box = Hive.box(_diseasesBox);
    for (final d in diseases) {
      await box.put(d['id'], d);
    }
  }

  static Future<void> cacheTreatments(List<Map<String, dynamic>> treatments) async {
    final box = Hive.box(_treatmentsBox);
    for (final t in treatments) {
      await box.put(t['id'], t);
    }
  }

  static List<Map> cachedDiseases() => Hive.box(_diseasesBox).values.cast<Map>().toList();
  static List<Map> cachedTreatments() => Hive.box(_treatmentsBox).values.cast<Map>().toList();
}
