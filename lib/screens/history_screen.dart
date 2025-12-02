import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../widgets/activity_tile.dart';
import 'activity_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TextEditingController _searchCtl = TextEditingController();
  List? _serverResults;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActivityProvider>(context);
    final cached = provider.cached;
    return Scaffold(
      appBar: AppBar(title: const Text('Activity History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _searchCtl, decoration: const InputDecoration(hintText: 'Search (server)'))),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    final q = _searchCtl.text.trim();
                    final results = await provider.fetchFromServer(q: q.isEmpty ? null : q);
                    setState(() { _serverResults = results; });
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: _serverResults != null
                ? ListView.builder(
              itemCount: _serverResults!.length,
              itemBuilder: (ctx, i) {
                final item = _serverResults![i];
                return ListTile(
                  title: Text('${item.latitude}, ${item.longitude}'),
                  subtitle: Text(item.timestamp.toString()),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityDetailScreen(activity: item))),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final ok = await provider.deleteRemote(item.id);
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted on server')));
                        setState(() { _serverResults!.removeAt(i); });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete')));
                      }
                    },
                  ),
                );
              },
            )
                : ListView.builder(
              itemCount: cached.length,
              itemBuilder: (ctx, i) {
                final a = cached[i];
                return ListTile(
                  leading: a.imagePath.isNotEmpty ? Image.file(File(a.imagePath), width: 56, height: 56, fit: BoxFit.cover) : null,
                  title: Text('${a.latitude.toStringAsFixed(4)}, ${a.longitude.toStringAsFixed(4)}'),
                  subtitle: Text(a.timestamp.toLocal().toString()),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityDetailScreen(activity: a))),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
