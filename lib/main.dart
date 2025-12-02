import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/activity_provider.dart';
import 'services/api_service.dart';
import 'repositories/activity_repository.dart';

void main() {
  // TODO: change to your backend URL
  final apiService = ApiService(baseUrl: 'https://your-api.example.com');
  final repo = ActivityRepository(apiService: apiService);

  runApp(MyApp(repository: repo));
}

class MyApp extends StatelessWidget {
  final ActivityRepository repository;
  const MyApp({required this.repository, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ActivityProvider(repository: repository)..loadCached(),
      child: MaterialApp(
        title: 'SmartTracker',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomeScreen(),
      ),
    );
  }
}
