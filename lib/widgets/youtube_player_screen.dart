import 'package:flutter/material.dart';
import 'package:toptastic/widgets/song_info.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/song.dart';
import 'chart_info.dart';

class YoutubePlayerScreen extends StatefulWidget {
  const YoutubePlayerScreen({super.key, required this.song});

  final Song song;

  @override
  createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;
  bool _showAppBar = true;

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
    final themeColor = Theme.of(context).primaryColor;
    final accentColor = Theme.of(context).primaryColorDark;
    return Scaffold(
      appBar: _showAppBar
          ? AppBar(
              title: Text('${widget.song.songName} - ${widget.song.artist}'),
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
                ChartInfo(song: widget.song),
                Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: SongInfo(widget.song),
                      ),
                    ),
                  ),
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
