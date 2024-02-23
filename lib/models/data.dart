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
    'https://raw.githubusercontent.com/mjdavy/toptastic-client/main/songs.db';

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

Future<bool> shouldDownloadDatabase(String path) async {
  File databaseFile = File(path);

  if (!await databaseFile.exists()) {
    return true;
  } else {
    try {
      var response = await http.head(Uri.parse(databaseURL));
      if (response.headers.containsKey('content-length')) {
        int remoteFileLength = int.parse(response.headers['content-length']!);
        int localFileLength = await databaseFile.length();
        if (remoteFileLength != localFileLength) {
          return true;
        }
      }
    } catch (e) {
      logger.i('Error checking database update: $e');
      return false;
    }
  }
  return false;
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
  final prefs = await SharedPreferences.getInstance();
  final serverName = prefs.getString('serverName');
  final port = prefs.getString('port');

  if (serverName == null || port == null) {
    throw ServerNotConfiguredException('Server is not configured');
  }

  final serverUrl = 'http://$serverName:$port/api/songs';
  final url = '$serverUrl/$formattedDate';
  try {
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('offlineMode', true);
    return await fetchSongsOffline(date);
  }
}
