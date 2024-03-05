import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:logger/logger.dart';
import 'song.dart';

final logger = Logger();

const String databaseURL =
    'https://raw.githubusercontent.com/mjdavy/toptastic-data/main/songs.db';

enum FetchSongsResult {
  success,
  serverNotConfigured,
  error,
}

class ServerNotConfiguredException implements Exception {
  final String message;

  ServerNotConfiguredException(this.message);
}

class FetchSongsException implements Exception {
  final String message;

  FetchSongsException(this.message);
}

Future<void> downloadDatabase(String dbPath) async {
  var response = await http.get(Uri.parse(databaseURL));
  if (response.statusCode == 200) {
    var bytes = response.bodyBytes;
    File file = File(dbPath);
    await file.writeAsBytes(bytes);
  } else {
    throw Exception('Failed to download database');
  }
}

Future<void> updateLastDownloaded({bool reset = false}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (reset) {
    prefs.remove('lastDownloaded');
    return;
  }
  prefs.setString('lastDownloaded', DateTime.now().toString());
}

Future<DateTime?> getLastDownloaded() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? lastDownloaded = prefs.getString('lastDownloaded');
  return lastDownloaded != null ? DateTime.parse(lastDownloaded) : null;
}

Future<bool> shouldDownloadDatabase(String path) async {
  DateTime? lastDownloaded = await getLastDownloaded();
  if (lastDownloaded != null) {
    if (DateTime.now().difference(lastDownloaded).inDays < 1) {
      return false;
    }
  }

  return true;
}

Future<List<Song>> fetchSongs(DateTime date) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool offlineMode = prefs.getBool('offlineMode') ?? true;
  return offlineMode ? fetchSongsOffline(date) : fetchSongsOnline(date);
}

Future<List<Song>> fetchSongsOffline(DateTime date) async {
  final String formattedDate = DateFormat('yyyyMMdd').format(date);

  // Fetch songs from local SQLite database
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'database.db');
  var songs = List<Song>.empty();

  try {
    if (await shouldDownloadDatabase(path)) {
      await downloadDatabase(path);
      await updateLastDownloaded();
    }
    songs = await getSongsFromDB(path, formattedDate);
  } catch (e) {
    throw FetchSongsException('Data error: $e');
  }

  return songs;
}

Future<List<Song>> getSongsFromDB(String dbPath, String formattedDate) async {
  String query = """
    SELECT 
      s.id,
      s.song_name, 
      s.artist, 
      s.video_id,
      ps.position, 
      ps.lw, 
      ps.peak, 
      ps.weeks, 
      ps.is_new, 
      ps.is_reentry
    FROM 
      playlists p 
      JOIN playlist_songs ps ON p.id = ps.playlist_id 
      JOIN songs s ON ps.song_id = s.id
    WHERE 
      p.date = '$formattedDate'""";

  Database database = await openDatabase(dbPath, version: 1);
  var result = await database.rawQuery(query);

  // Map each Map to a Song object
  List<Song> songs = result.map((item) => Song.fromJson(item)).toList();
  return songs;
}

Future<List<Song>> fetchSongsOnline(DateTime date) async {
  final String formattedDate = DateFormat('yyyyMMdd').format(date);

  try {
    final serverName = await getServerUrl();
    final serverUrl = '$serverName/api/songs';
    final url = '$serverUrl/$formattedDate';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      var songs = jsonResponse.map((item) => Song.fromJson(item)).toList();
      return songs;
    } else {
      throw FetchSongsException(
          'Error fetching songs. Status code: ${response.statusCode}');
    }
  } catch (e) {
    logger.i('Error fetching songs: $e');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('offlineMode', true);
    return await fetchSongsOffline(date);
  }
}

Future<String> getServerUrl() async {
  final prefs = await SharedPreferences.getInstance();
  final serverName = prefs.getString('serverName');
  final port = prefs.getString('port');

  if (serverName == null || port == null) {
    throw ServerNotConfiguredException('Server is not configured');
  }

  return 'http://$serverName:$port';
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
