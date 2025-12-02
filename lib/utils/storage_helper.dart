import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';

class StorageHelper {
  static const String keyLast5 = 'last_5_activities';

  static Future<void> saveLastActivities(List<Activity> activities) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = activities.map((a) => a.toRawJson()).toList();
    await prefs.setStringList(keyLast5, rawList);
  }

  static Future<List<Activity>> loadLastActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(keyLast5) ?? [];
    return raw.map((r) => Activity.fromRawJson(r)).toList();
  }
}
