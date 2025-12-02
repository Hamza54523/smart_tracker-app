import 'dart:io';
import '../models/activity.dart';
import '../services/api_service.dart';
import '../utils/storage_helper.dart';

class ActivityRepository {
  final ApiService apiService;
  ActivityRepository({required this.apiService});

  Future<void> saveActivity(Activity activity, {File? imageFile, bool sync = true}) async {
    // Save to local last-5 cache
    final list = await StorageHelper.loadLastActivities();
    list.insert(0, activity);
    final trimmed = list.take(5).toList();
    await StorageHelper.saveLastActivities(trimmed);

    // Try to sync to API if asked and an image file is provided
    if (sync && imageFile != null) {
      try {
        final res = await apiService.postActivityWithImage(activity: activity, imageFile: imageFile);
        if (res.statusCode >= 200 && res.statusCode < 300) {
          // success
        } else {
          // Could store in a queue for retry - omitted for brevity
        }
      } catch (e) {
        // offline: leave it locally
      }
    }
  }

  Future<List<Activity>> getCachedActivities() => StorageHelper.loadLastActivities();

  Future<List<Activity>> fetchFromServer({String? query}) => apiService.fetchActivities(query: query);

  Future<bool> deleteOnServer(String id) => apiService.deleteActivity(id);
}
