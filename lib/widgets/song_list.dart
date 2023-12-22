import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/song.dart';

class SongList extends StatelessWidget {
  final Function(Song) onTap;
  final Future<List<Song>> songsFuture;
  const SongList(this.songsFuture, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<dynamic>>(
        future: songsFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No data for this date'));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    leading: Text('${index + 1}',
                        style: Theme.of(context).textTheme.headlineSmall),
                    title: Text(snapshot.data[index].songName),
                    subtitle: Text(snapshot.data[index].artist),
                    trailing: snapshot.data[index].videoId == null ||
                            snapshot.data[index].videoId.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.video_library),
                            onPressed: () {
                              var uri = Uri(
                                scheme: 'https',
                                host: 'www.youtube.com',
                                path: 'watch',
                                queryParameters: {
                                  'v': snapshot.data[index].videoId
                                },
                              );
                              launchUrl(uri);
                            },
                          ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
