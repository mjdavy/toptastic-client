import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/song.dart';

class YoutubePlaylistScreen extends StatefulWidget {
  const YoutubePlaylistScreen(this.songs, {super.key});

  final List<Song> songs;

  @override
  State<YoutubePlaylistScreen> createState() => _YoutubePlaylistScreenState();
}

class _YoutubePlaylistScreenState extends State<YoutubePlaylistScreen> {
  late YoutubePlayerController _controller;
  int _currentVideoIndex = 0;

  void _playNextVideo() {
    _currentVideoIndex++;
    if (_currentVideoIndex < widget.songs.length) {
      _controller.load(widget.songs[_currentVideoIndex].videoId);
      _controller.play();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.songs[_currentVideoIndex].videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );
    _controller.addListener(() {
      if (_controller.value.playerState == PlayerState.ended) {
        _playNextVideo();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlist'),
      ),
      body: const Center(
        child: Text('Playlist'),
      ),
    );
  }
}
