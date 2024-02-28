import 'package:flutter/material.dart';
import 'package:toptastic/models/song.dart';

class YoutubeThumbnail extends StatelessWidget {
  const YoutubeThumbnail(
      {super.key, required this.song, this.isFavorite = false});

  final Song song;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topRight, children: [
      Image.network(
        'https://img.youtube.com/vi/${song.videoId}/0.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.video_library);
        },
      ),
      if (isFavorite)
        const Icon(
          Icons.star,
          color: Colors.amber,
        ),
    ]);
  }
}
