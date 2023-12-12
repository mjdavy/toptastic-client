import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class Song {
  final String artist;
  final String songName;
  final String lw;
  final String peak;
  final String reNew;
  final String weeks;

  Song(
      {required this.artist,
      required this.songName,
      required this.lw,
      required this.peak,
      required this.reNew,
      required this.weeks});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      artist: json['artist'],
      songName: json['song_name'],
      lw: json['lw'],
      peak: json['peak'],
      reNew: json['re_new'],
      weeks: json['weeks'],
    );
  }
}

Future<List<Song>> fetchSongs(DateTime date) async {
  final String formattedDate = DateFormat('yyyyMMdd').format(date);
  var uri = Uri.parse("http://10.0.2.2:5000/api/songs/$formattedDate");
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((item) => Song.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load songs');
  }
}
