import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import 'package:uuid/uuid.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({Key? key}) : super(key: key);

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  XFile? _picked;
  bool _saving = false;
  double? _lat;
  double? _lon;

  Future<void> _getLocation() async {
    final ok = await LocationService.checkPermission();
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission denied')));
      return;
    }
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    _lat = pos.latitude;
    _lon = pos.longitude;
    setState(() {});
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
    if (img != null) {
      setState(() {
        _picked = img;
      });
    }
  }

  Future<String> _saveToAppDir(XFile file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final id = const Uuid().v4();
    final newPath = '${appDir.path}/activity_$id${file.name.contains('.') ? '' : '.jpg'}';
    final saved = await File(file.path).copy(newPath);
    return saved.path;
  }

  Future<void> _onSave() async {
    if (_picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please take a photo first')));
      return;
    }
    if (_lat == null || _lon == null) {
      await _getLocation();
      if (_lat == null) return;
    }
    setState(() { _saving = true; });
    final savedPath = await _saveToAppDir(_picked!);
    // Return savedPath + coords to home
    Navigator.pop(context, {'imagePath': savedPath, 'lat': _lat!, 'lon': _lon!});
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Activity')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _picked == null
                    ? const Text('No image yet. Tap camera icon to take photo.')
                    : Image.file(File(_picked!.path)),
              ),
            ),
            if (_lat != null && _lon != null) Text('Location: ${_lat!.toStringAsFixed(5)}, ${_lon!.toStringAsFixed(5)}'),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    onPressed: _pickImage,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: _saving ? const Text('Saving...') : const Text('Save Activity'),
                    onPressed: _saving ? null : _onSave,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
