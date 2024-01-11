import 'package:flutter/material.dart';
import 'package:toptastic/widgets/song_position_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/song.dart';
import 'youtube_thumbnail.dart';

class SongItem extends StatelessWidget {
  final Song song;
  final int position;

  const SongItem(this.position, this.song, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: SongPositionIndicator(position, song),
        title: Text(
          song.songName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(song.artist),
        trailing: song.videoId.isEmpty
            ? null
            : YoutubeThumbnail(song), // Use your YoutubeThumbnail widget here
        onTap: () {
          if (song.videoId.isEmpty) {
            var query = '${song.artist} ${song.songName}';
            var uri = Uri(
              scheme: 'https',
              host: 'www.youtube.com',
              path: 'results',
              queryParameters: {'search_query': query},
            );
            launchUrl(uri);
          }
        },
      ),
    );
  }
}