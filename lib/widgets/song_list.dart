import 'package:flutter/material.dart';

import '../models/song.dart';
import 'settings_page.dart';
import 'song_item.dart';

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
            if (snapshot.error is ServerNotConfiguredException) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              });
              return const SizedBox.shrink();
            } else {
              return Text('Error: ${snapshot.error}');
            }
          } else if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No data for this date'));
          } else {
            var songs = snapshot.data as List<Song>;
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) => SongItem(index +1, songs[index])
            );
          }
        },
      ),
    );
  }
}
