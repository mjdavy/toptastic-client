import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/song.dart';

class YoutubeThumbnail extends StatefulWidget {
  const YoutubeThumbnail(this.song, {Key? key}) : super(key: key);

  final Song song;

  @override
  createState() => _YoutubeThumbnailState();
}

class _YoutubeThumbnailState extends State<YoutubeThumbnail> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.song.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.song.videoId.isEmpty) {
      return const Icon(Icons.video_library);
    } else {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: Text('${widget.song.songName} - ${widget.song.artist}',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                body: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.blueAccent,
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.blue,
                    handleColor: Colors.blueAccent,
                  ),
                ),
              ),
            ),
          ).then((value) {
            // This code will execute when returning from the video playback screen
            // You can add any necessary logic here
          });
        },
        child: Image.network(
          'https://img.youtube.com/vi/${widget.song.videoId}/0.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.video_library);
          },
        ),
      );
    }
  }
}
