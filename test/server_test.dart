import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:toptastic/main.dart';

void main() {
  runApp(const MyApp());

  test('Test connection to video server', () async {
    // Send a GET request to the server
    var response = await http.get(Uri.parse('http://10.0.2.2:3030/status'));

    // Check that the server returns a 200 OK response
    expect(response.statusCode, 200);
  });

  test('Send test playlist to video server', () async {
    // Read the JSON file
    String jsonPlaylist =
        await rootBundle.loadString('assets/testPlaylist.json');

    // Send the playlist to the server
    var response = await http.post(
      Uri.parse('http://10.0.2.2:3030/playlists'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonPlaylist,
    );

    // Check that the server returns a 200 OK response
    expect(response.statusCode, 200);
  });
}
