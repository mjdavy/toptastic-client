import 'package:flutter/material.dart';

import '../models/song.dart';
import 'youtube_thumbnail.dart';

class SongDetailScreen extends StatefulWidget {
  final Song song;

  const SongDetailScreen({Key? key, required this.song}) : super(key: key);

  @override
    createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  late TextEditingController _videoIdController;

  @override
  void initState() {
    super.initState();
    _videoIdController = TextEditingController(text: widget.song.videoId);
  }

  @override
  void dispose() {
    _videoIdController.dispose();
    super.dispose();
  }

  void updateVideoId(String videoId) {
    setState(() {
      widget.song.updateVideoId(videoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Song Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${widget.song.songName}',
              style: Theme.of(context).textTheme.titleMedium
            ),
            const SizedBox(height: 8.0),
            Text(
              'Artist: ${widget.song.artist}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            
            TextFormField(
              controller: _videoIdController,
              onChanged: (value) {
                updateVideoId(value);
              },
              decoration: const InputDecoration(
                labelText: 'Video ID',
              ),
            ),
            const SizedBox(height: 16.0),
            YoutubeThumbnail(widget.song.videoId),
          ],
        ),
      ),
    );
  }
}