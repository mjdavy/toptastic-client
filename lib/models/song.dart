import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Song {
  final String artist;
  final String songName;
  final String lw;
  final String peak;
  final String reNew;
  final String weeks;
  final String videoId;

  Song(
      {required this.artist,
      required this.songName,
      required this.lw,
      required this.peak,
      required this.reNew,
      required this.weeks,
      required this.videoId});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      artist: json['artist'],
      songName: json['song_name'],
      lw: json['lw'],
      peak: json['peak'],
      reNew: json['re_new'],
      weeks: json['weeks'],
      videoId: json.containsKey('video_id') &&
              json['video_id'] != null &&
              json['video_id'] != ''
          ? json['video_id']
          : '',
    );
  }
}

Future<List<Song>> fetchSongs(DateTime date) async {
  final String formattedDate = DateFormat('yyyyMMdd').format(date);
  final prefs = await SharedPreferences.getInstance();
  final serverUrl =
      prefs.getString('serverUrl') ?? 'http://10.0.2.2:5000/api/songs';
  var uri = Uri.parse("$serverUrl/$formattedDate");
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    var songs = jsonResponse.map((item) => Song.fromJson(item)).toList();
    return songs;
  } else {
    return []; // Return an empty list if the server returns a non-200 status code
  }
}
