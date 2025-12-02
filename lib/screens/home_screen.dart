import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../providers/activity_provider.dart';
import 'capture_screen.dart';
import 'history_screen.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  Marker? _userMarker;
  LatLng _initial = const LatLng(33.6844, 73.0479); // fallback (Islamabad)
  StreamSubscription<Position>? _posSub;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final ok = await LocationService.checkPermission();
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
      return;
    }
    final pos = await LocationService.getCurrentPosition();
    _initial = LatLng(pos.latitude, pos.longitude);
    _moveCamera(_initial);
    _updateMarker(_initial);
    _posSub = LocationService.getPositionStream().listen((p) {
      final latLng = LatLng(p.latitude, p.longitude);
      _updateMarker(latLng);
      _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    });
    setState(() {});
  }

  void _moveCamera(LatLng pos) {
    _mapController?.moveCamera(CameraUpdate.newLatLngZoom(pos, 16));
  }

  void _updateMarker(LatLng pos) {
    setState(() {
      _userMarker = Marker(markerId: const MarkerId('user'), position: pos, infoWindow: const InfoWindow(title: 'You'));
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActivityProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartTracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          )
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _initial, zoom: 14),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _userMarker != null ? {_userMarker!} : {},
            onMapCreated: (c) => _mapController = c,
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Activity'),
              onPressed: () async {
                // open capture screen and return result
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CaptureScreen()));
                if (result != null && result is Map<String, dynamic>) {
                  final lat = result['lat'] as double;
                  final lon = result['lon'] as double;
                  final imagePath = result['imagePath'] as String;
                  final imageFile = File(imagePath);
                  await provider.addActivity(lat, lon, imagePath, imageFile: imageFile);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activity saved')));
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
