import 'dart:io';
import 'package:flutter/material.dart';
import '../models/activity.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ActivityDetailScreen extends StatelessWidget {
  final Activity activity;
  const ActivityDetailScreen({required this.activity, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pos = LatLng(activity.latitude, activity.longitude);
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Detail')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: activity.imagePath.isNotEmpty ? Image.file(File(activity.imagePath), width: double.infinity, fit: BoxFit.cover) : const Center(child: Text('No image')),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                ListTile(title: const Text('Coordinates'), subtitle: Text('${activity.latitude}, ${activity.longitude}')),
                ListTile(title: const Text('Timestamp'), subtitle: Text(activity.timestamp.toLocal().toString())),
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(target: pos, zoom: 16),
                    markers: { Marker(markerId: const MarkerId('act'), position: pos) },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
