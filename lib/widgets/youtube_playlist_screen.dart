import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/favorites_songs_model.dart';
import '../models/song.dart';

class YoutubePlaylistScreen extends StatefulWidget {
  const YoutubePlaylistScreen(
      {super.key,
      required this.songs,
      required this.date,
      this.favoritesOnly = false});

  final List<Song> songs;
  final DateTime date;
  final bool favoritesOnly;

  @override
  State<YoutubePlaylistScreen> createState() => _YoutubePlaylistScreenState();
}

class _YoutubePlaylistScreenState extends State<YoutubePlaylistScreen> {
  late YoutubePlayerController _controller;
  int _currentVideoIndex = 0;
  bool _showAppBar = true;
  late List<Song> _playlist;

  void _playNextVideo() {
    _currentVideoIndex++;
    if (_currentVideoIndex < _playlist.length) {
      _controller.load(_playlist[_currentVideoIndex].videoId);
      _controller.play();
    }
  }

  @override
  void initState() {
    super.initState();

    // Access FavoriteSongsModel from the widget tree
    final favoriteSongsModel =
        Provider.of<FavoriteSongsModel>(context, listen: false);
    final favoriteIds = favoriteSongsModel
        .favoriteIds; // get favoriteIds from FavoriteSongsModel

    _playlist = widget.favoritesOnly
        ? widget.songs
            .where((song) => favoriteIds.contains(song.id))
            .toList() // if favoritesOnly, filter songs by favoriteIds
        : widget.songs;

    _controller = YoutubePlayerController(
      initialVideoId: _playlist[_currentVideoIndex].videoId,
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

    // Schedule a call to enterFullScreen() in the next event loop
    Future.delayed(Duration.zero, () {
      _controller.toggleFullScreenMode();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).primaryColor;
    final accentColor = Theme.of(context).primaryColorDark;
    return Scaffold(
      appBar: _showAppBar
          ? AppBar(
              title: Text(
                DateFormat('EEEE, MMMM d, yyyy').format(widget.date),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blueAccent,
            progressColors: ProgressBarColors(
              playedColor: themeColor,
              handleColor: accentColor,
            ),
          ),
          builder: (context, player) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                player,
              ],
            );
          },
          onEnterFullScreen: () => setState(() => _showAppBar = false),
          onExitFullScreen: () => setState(() => _showAppBar = true),
        ),
      ),
    );
  }
}
