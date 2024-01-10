
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Song {
  final String artist;
  final String songName;
  final int lw;
  final int peak;
  final bool isNew;
  final bool isReentry;
  final int weeks;
  String videoId;

  Song(
      {required this.artist,
      required this.songName,
      required this.lw,
      required this.peak,
      required this.isNew,
      required this.isReentry,
      required this.weeks,
      required this.videoId});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      artist: json['artist'],
      songName: json['song_name'],
      lw: json['lw'],
      peak: json['peak'],
      isNew: json['is_new'],
      isReentry: json['is_reentry'],
      weeks: json['weeks'],
      videoId: json.containsKey('video_id') &&
              json['video_id'] != null &&
              json['video_id'] != ''
          ? json['video_id']
          : '',
    );
  }

  void updateVideoId(String newVideoId) {
    videoId = newVideoId;
  }
}

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

Future<List<Song>> fetchSongs(DateTime date) async {
  final String formattedDate = DateFormat('yyyyMMdd').format(date);
  final prefs = await SharedPreferences.getInstance();
  final serverName = prefs.getString('serverName');
  final port = prefs.getString('port');

  if (serverName == null || port == null) {
    throw ServerNotConfiguredException('Server is not configured');
  }

  final serverUrl = 'http://$serverName:$port/api/songs';
  final url = '$serverUrl/$formattedDate';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    var songs = jsonResponse.map((item) => Song.fromJson(item)).toList();
    return songs;
  } else {
    throw FetchSongsException('Error fetching songs');
  }
}