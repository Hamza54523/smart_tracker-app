import 'dart:io';                       // <-- REQUIRED for File()
import 'package:flutter/material.dart';
import '../models/activity.dart';

class ActivityTile extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ActivityTile({
    required this.activity,
    this.onTap,
    this.onDelete,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: activity.imagePath.isNotEmpty
          ? Image.file(
        File(activity.imagePath),
        width: 56,
        height: 56,
        fit: BoxFit.cover,
      )
          : const Icon(Icons.image),

      title: Text(
        '${activity.latitude.toStringAsFixed(4)}, '
            '${activity.longitude.toStringAsFixed(4)}',
      ),

      subtitle: Text(activity.timestamp.toLocal().toString()),

      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),

      onTap: onTap,
    );
  }
}
