import 'package:flutter/material.dart';
import 'package:toptastic/models/song.dart';
import 'youtube_player_screen.dart';

class YoutubeThumbnail extends StatelessWidget {
  const YoutubeThumbnail(this.song, {super.key});

  final Song song;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => YoutubePlayerScreen(song: song),
          ),
        );
      },
      child: Image.network(
        'https://img.youtube.com/vi/${song.videoId}/0.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.video_library);
        },
      ),
    );
  }
}