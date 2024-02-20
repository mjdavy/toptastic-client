import 'package:flutter/material.dart';
import 'package:toptastic/widgets/song_position_indicator.dart';
import '../models/song.dart';
import 'song_details_screen.dart';
import 'youtube_thumbnail.dart';

class SongItem extends StatefulWidget {
  final Song song;

  const SongItem(this.song, {super.key});

  @override
  State<SongItem> createState() => _SongItemState();
}

class _SongItemState extends State<SongItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: SongPositionIndicator(widget.song),
        title: Text(
          widget.song.songName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(widget.song.artist),
        trailing: widget.song.videoId.isEmpty
            ? null
            : YoutubeThumbnail(widget.song), // Use your YoutubeThumbnail widget here
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SongDetailScreen(
                  song: widget.song,
                  onVideoIdUpdated: (videoId) {
                    setState(() {});
                  },
                  ),
              ),
            );
        },
      ),
    );
  }
}