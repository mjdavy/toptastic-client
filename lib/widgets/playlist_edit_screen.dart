// playlist_edit_screen.dart
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/video_playlist.dart';
import 'song_details_screen.dart';
import 'youtube_thumbnail.dart';

class PlaylistEditScreen extends StatefulWidget {
  final String playlistTitle;
  final String playlistDescription;
  final Future<List<Song>> songsFuture;

  const PlaylistEditScreen({
    super.key,
    required this.playlistTitle,
    required this.playlistDescription,
    required this.songsFuture,
  });

  @override
  createState() => _PlaylistEditScreenState();
}

class _PlaylistEditScreenState extends State<PlaylistEditScreen> {
  String _editedPlaylistTitle = '';
  String _editedPlaylistDescription = '';
  List<Song> _selectedSongs = [];
  List<Song> _selectedSongsList = [];

  @override
  void initState() {
    super.initState();
    _editedPlaylistTitle = widget.playlistTitle;
    _editedPlaylistDescription = widget.playlistDescription;
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    List<Song> songs = await widget.songsFuture;
    setState(() {
      _selectedSongs = songs;
      _selectedSongsList = List.from(_selectedSongs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Playlist'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            initialValue: _editedPlaylistTitle,
            onChanged: (value) {
              setState(() {
                _editedPlaylistTitle = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Playlist Title',
            ),
          ),
          TextFormField(
            initialValue: _editedPlaylistDescription,
            onChanged: (value) {
              setState(() {
                _editedPlaylistDescription = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Playlist Description',
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Selected Songs:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedSongs.length,
            itemBuilder: (context, index) {
              final song = _selectedSongs[index];
              final isSelected = _selectedSongsList.contains(song);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongDetailScreen(song: song),
                    ),
                  );
                },
                child: Column(
                  children: [
                    ListTile(
                      leading: YoutubeThumbnail(song.videoId),
                      title: Text(song.songName,
                          style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text(song.artist),
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedSongsList.add(song);
                            } else {
                              _selectedSongsList.remove(song);
                            }
                          });
                        },
                      ),
                    ),
                    const Divider(), // Add a divider between each ListTile
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.red,
        onPressed: () {
          // Call the function to create the playlist with the edited details
          createPlaylist(
            _editedPlaylistTitle,
            _editedPlaylistDescription,
            _selectedSongsList,
          );
          Navigator.pop(context);
        },
        child: const Icon(Icons.video_library_sharp),
      ),
    );
  }
}
