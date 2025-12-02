import 'dart:convert';

class Activity {
  final String id;
  final double latitude;
  final double longitude;
  final String imagePath; // local file path or remote URL
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'latitude': latitude,
    'longitude': longitude,
    'imagePath': imagePath,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    id: json['id'],
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    imagePath: json['imagePath'],
    timestamp: DateTime.parse(json['timestamp']),
  );

  String toRawJson() => json.encode(toJson());
  static Activity fromRawJson(String str) =>
      Activity.fromJson(json.decode(str));
}
