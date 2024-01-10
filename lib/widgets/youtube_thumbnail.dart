import 'package:flutter/material.dart';

class YoutubeThumbnail extends StatelessWidget {
  const YoutubeThumbnail(this.videoId, {Key? key}) : super(key: key);

  final String videoId;

  @override
  Widget build(BuildContext context) {
    if (videoId.isEmpty) {
      return const Icon(Icons.video_library); // Display default icon when video ID is empty
    } else {
      return Image.network(
        'https://img.youtube.com/vi/$videoId/0.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.video_library); // Display default icon when there is an error loading the thumbnail image
        },
      );
    }
  }
}