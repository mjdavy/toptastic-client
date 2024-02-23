import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data.dart';
import '../models/song.dart';
import 'song_item.dart';

class SongList extends StatelessWidget {
  final Future<List<Song>> songsFuture;
  final bool filterFavorites;
  const SongList({super.key, required this.songsFuture, this.filterFavorites = false});

  Future<Set<String>> _getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys().where((key) => key.startsWith('favorite_')).toSet();
  }

  bool _isFavorite(Song song, Set<String> favoriteIds) {
    return favoriteIds.contains('favorite_${song.id}');
  }
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<dynamic>>(
        future: Future.wait([songsFuture, _getFavoriteIds()]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            if (snapshot.error is ServerNotConfiguredException) {
              return const SizedBox.shrink();
            }
            if (snapshot.error is FetchSongsException) {
              return Text((snapshot.error as FetchSongsException).message);
            } else {
              return const Text('An unknown error occurred');
            }
          } else if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No data for this date'));
          } else {
            var songs = snapshot.data![0] as List<Song>;
            var favoriteIds = snapshot.data![1] as Set<String>;

            if (filterFavorites) {
              songs = songs.where((song) => _isFavorite(song, favoriteIds)).toList();
            }

            return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: songs.length,
                itemBuilder: (BuildContext context, int index) =>
                    SongItem(song: songs[index], isFavorite:  _isFavorite(songs[index], favoriteIds)));
          }
        },
      ),
    );
  }
}
