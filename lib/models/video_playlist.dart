import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'song.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();

class TubeTrack {
  final String id;
  final String title;
  final String artist;
  final String? videoId;

  TubeTrack({required this.id, required this.title, this.videoId, required this.artist});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'videoId': videoId ?? '',
      };
}

class VideoPlaylist {
  final String title;
  final String description;
  final List<TubeTrack> tracks;

  VideoPlaylist(
      {required this.title, required this.description, required this.tracks});

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'tracks': tracks.map((track) => track.toJson()).toList(),
      };
}

Future<void> createPlaylist(
  String title, String description, List<Song> songs) async {

  final prefs = await SharedPreferences.getInstance();
  final serverName = prefs.getString('serverName');
  final port = prefs.getString('port');

  if (serverName == null || port == null) {
    throw ServerNotConfiguredException('Server is not configured');
  }

  final serverUrl = 'http://$serverName:$port/api/create_playlist';

  // Convert the list of songs to a list of TubeTracks
  List<TubeTrack> tracks = songs
      .asMap()
      .entries
      .map((entry) => TubeTrack(
          id: 'track${entry.key + 1}',
          title: entry.value.songName,
          artist: entry.value.artist,
          videoId: entry.value.videoId)
      )
      .toList();

  // Create a new Playlist object
  VideoPlaylist playlist =
      VideoPlaylist(title: title, description: description, tracks: tracks);

  // Convert the Playlist to a JSON string
  String jsonPlaylist = jsonEncode(playlist.toJson());

  // Send the playlist to the server

  var response = await http.post(
    Uri.parse(serverUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonPlaylist,
  );

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response, then parse the JSON.
    logger.i('Playlist created successfully');
  } else {
    // If the server returns an unsuccessful response code, throw an exception.
    throw Exception('Failed to create playlist: ${response.statusCode}');
  }
}
