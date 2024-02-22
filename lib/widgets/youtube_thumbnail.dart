import 'package:flutter/material.dart';
import 'package:toptastic/models/song.dart';

class YoutubeThumbnail extends StatelessWidget {
  const YoutubeThumbnail(this.song, {super.key});

  final Song song;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://img.youtube.com/vi/${song.videoId}/0.jpg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.video_library);
      },
    );
  }
}
