import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../repositories/activity_repository.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityRepository repository;
  List<Activity> _cached = [];
  bool _loading = false;

  bool get loading => _loading;
  List<Activity> get cached => _cached;

  ActivityProvider({required this.repository});

  Future<void> loadCached() async {
    _cached = await repository.getCachedActivities();
    notifyListeners();
  }

  Future<void> addActivity(double lat, double lon, String imagePath, {File? imageFile}) async {
    _loading = true;
    notifyListeners();

    final activity = Activity(
      id: Uuid().v4(),
      latitude: lat,
      longitude: lon,
      imagePath: imagePath,
      timestamp: DateTime.now(),
    );

    await repository.saveActivity(activity, imageFile: imageFile, sync: true);
    await loadCached();

    _loading = false;
    notifyListeners();
  }

  Future<List<Activity>> fetchFromServer({String? q}) => repository.fetchFromServer(query: q);

  Future<bool> deleteRemote(String id) => repository.deleteOnServer(id);
}
