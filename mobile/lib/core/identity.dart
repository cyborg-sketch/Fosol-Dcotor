import 'package:hive_flutter/hive_flutter.dart';

/// Persists this device's real farmer/crop identity — created once via
/// POST /farmers on first launch (see onboarding_screen.dart), never a
/// pinned/seeded demo identity. Every diagnosis submitted from this device
/// is tied to whatever is stored here.
class IdentityStore {
  static const _boxName = 'identity';

  static Future<Box> _box() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  static Future<String?> getFarmerId() async => (await _box()).get('farmer_id') as String?;
  static Future<String?> getCropId() async => (await _box()).get('crop_id') as String?;

  static Future<void> setFarmerId(String farmerId) async => (await _box()).put('farmer_id', farmerId);
  static Future<void> setCropId(String cropId) async => (await _box()).put('crop_id', cropId);

  static Future<bool> hasIdentity() async {
    final farmerId = await getFarmerId();
    final cropId = await getCropId();
    return farmerId != null && cropId != null;
  }
}
