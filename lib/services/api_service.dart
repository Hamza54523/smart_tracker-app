import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/activity.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  final String baseUrl;
  ApiService({required this.baseUrl});

  // POST activity with image file as multipart
  Future<http.StreamedResponse> postActivityWithImage({
    required Activity activity,
    required File imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/activities');
    final req = http.MultipartRequest('POST', uri);

    req.fields['id'] = activity.id;
    req.fields['latitude'] = activity.latitude.toString();
    req.fields['longitude'] = activity.longitude.toString();
    req.fields['timestamp'] = activity.timestamp.toIso8601String();

    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
    final parts = mimeType.split('/');
    final multipartFile = await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: MediaType(parts[0], parts[1]),
    );
    req.files.add(multipartFile);

    return req.send();
  }

  // Simple GET list
  Future<List<Activity>> fetchActivities({String? query}) async {
    final url = Uri.parse('$baseUrl/activities${query != null ? '?q=$query' : ''}');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final List list = json.decode(res.body);
      return list.map((e) => Activity.fromJson(e)).toList();
    }
    throw Exception('Failed to load activities: ${res.statusCode}');
  }

  Future<bool> deleteActivity(String id) async {
    final url = Uri.parse('$baseUrl/activities/$id');
    final res = await http.delete(url);
    return res.statusCode == 200 || res.statusCode == 204;
  }
}
