import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/favorites_songs_model.dart';
import '../models/data.dart';
import '../models/song.dart';
import 'song_item.dart';

class SongList extends StatelessWidget {
  final Future<List<Song>> songsFuture;
  final bool favoritesOnly;
  const SongList(
      {super.key, required this.songsFuture, this.favoritesOnly = false});

  @override
  Widget build(BuildContext context) {

     // Access FavoriteSongsModel from the widget tree
    final favoriteSongsModel = Provider.of<FavoriteSongsModel>(context);
    
    return Expanded(
      child: FutureBuilder<List<dynamic>>(
        future: songsFuture,
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
            var songs = snapshot.data! as List<Song>;
            var favoriteIds = favoriteSongsModel.favoriteIds; // get favoriteIds from FavoriteSongsModel

            if (favoritesOnly) {
              songs = songs.where((song) => favoriteIds.contains(song.id)).toList(); // check if song.id is in favoriteIds
            }

            return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: songs.length,
                itemBuilder: (BuildContext context, int index) => SongItem(
                    song: songs[index],
                     isFavorite: favoriteIds.contains(songs[index].id))); // check if song.id is in favoriteIds
          }
        },
      ),
    );
  }
}
