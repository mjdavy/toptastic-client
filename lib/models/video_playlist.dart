import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data.dart';
import 'tube_track.dart';
import 'song.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();

Future<String> getServerUrl() async {
  final prefs = await SharedPreferences.getInstance();
  final serverName = prefs.getString('serverName');
  final port = prefs.getString('port');

  if (serverName == null || port == null) {
    throw ServerNotConfiguredException('Server is not configured');
  }

  return 'http://$serverName:$port';
}

Future<void> createPlaylist(
    String title, String description, List<Song> songs) async {
  final serverUrl = await getServerUrl();
  final createPlaylistUrl = '$serverUrl/api/create_playlist';

  // Convert the list of songs to a list of TubeTracks
  List<TubeTrack> tracks = songs
      .asMap()
      .entries
      .map((entry) => TubeTrack(
          id: 'track${entry.key + 1}',
          title: entry.value.songName,
          artist: entry.value.artist,
          videoId: entry.value.videoId))
      .toList();

  // Create a new Playlist object
  VideoPlaylist playlist =
      VideoPlaylist(title: title, description: description, tracks: tracks);

  // Convert the Playlist to a JSON string
  String jsonPlaylist = jsonEncode(playlist.toJson());

  // Send the playlist to the server

  var response = await http.post(
    Uri.parse(createPlaylistUrl),
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

Future<int> updateVideos(List<Song> songs) async {
  final serverUrl = await getServerUrl();
  final updateVideosUrl = '$serverUrl/api/update_videos';

  // Convert the list of songs to a list of tracks
  List<Map<String, dynamic>> tracks = songs
      .where((song) => song.hasChanges)
      .map((song) => {
            'title': song.songName,
            'artist': song.artist,
            'videoId': song.videoId,
          })
      .toList();

  // Prepare the request body
  final Map<String, dynamic> requestBody = {'tracks': tracks};

  // Make a POST request to update the videos
  final response = await http.post(
    Uri.parse(updateVideosUrl),
    body: json.encode(requestBody),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final int updatedCount = responseData['updated'];
    logger.i('Videos updated successfully. Updated $updatedCount songs.');
    return updatedCount;
  } else {
    // Handle error case
    logger.i('Failed to update videos: ${response.statusCode}');
  }
  return 0;
}
