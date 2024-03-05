import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toptastic/models/data.dart';
import 'package:toptastic/models/song.dart';
import '../models/favorites_songs_model.dart';
import 'video_chooser_screen.dart';

class ChartInfo extends StatefulWidget {
  const ChartInfo({super.key, required this.song});

  final Song song;

  @override
  createState() => _ChartInfoState();
}

class _ChartInfoState extends State<ChartInfo> {
  bool isFavorite = false;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    isOnline().then((value) {
      setState(() {
        _isOnline = value; // Store the value when it's ready
      });
    });
  }

  Future<bool> isOnline() async {
    final prefs = await SharedPreferences.getInstance();
    final offline = prefs.getBool('offlineMode') ?? true;
    return !offline;
  }

  void onVideoIdUpdated(String videoId) {
    setState(() {
      widget.song.updateVideoId(videoId);
    });
    updateVideos([widget.song]);
    updateLastDownloaded(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    // Extract the common style into a variable
    final textStyle = Theme.of(context).textTheme.titleMedium;

    // Access FavoriteSongsModel from the widget tree
    final favoriteSongsModel = Provider.of<FavoriteSongsModel>(context);
    final isFavorite = favoriteSongsModel.favoriteIds
        .contains(widget.song.id); // check if song.id is in favoriteIds

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(
              'Title: ${widget.song.songName}',
              style: textStyle,
            ),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.amber : null,
              ),
              onPressed: () {
                if (isFavorite) {
                  favoriteSongsModel.removeFavoriteId(
                      widget.song.id); // remove song.id from favoriteIds
                } else {
                  favoriteSongsModel.addFavoriteId(
                      widget.song.id); // add song.id to favoriteIds
                }
              },
            ),
          ]),
          Text(
            'Artist: ${widget.song.artist}',
            style: textStyle,
          ),
          Text(
            'Current Position: ${widget.song.position}',
            style: textStyle,
          ),
          Text(
            'Last Week Position: ${widget.song.lw}',
            style: textStyle,
          ),
          Text(
            'Peak Position: ${widget.song.peak}',
            style: textStyle,
          ),
          Text(
            'Weeks in Chart: ${widget.song.weeks}',
            style: textStyle,
          ),
          if (_isOnline)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoChooserScreen(
                        song: widget.song, onVideoIdUpdated: onVideoIdUpdated),
                  ),
                );
              },
              child: const Text('Change Video'),
            ),
        ],
      ),
    );
  }
}
