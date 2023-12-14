import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:toptastic/models/song.dart';
import 'settings_page.dart';
import 'song_list.dart';
import 'package:http/http.dart' as http;
import '../models/video_playlist.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _selectedDate = DateTime.now();
  late Future<List<Song>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _songsFuture = fetchSongs(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                  _songsFuture = fetchSongs(_selectedDate);
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add),
            onPressed: () async {
              // Assuming _songsFuture is a Future<List<Song>> of YouTube video IDs
              List<Song> songs = await _songsFuture;

              // Call the function to create the playlist
              await createPlaylist(
                  'Christmas', 'A collection of top songs for December', songs);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SongList(_songsFuture, (Song song) {
            // Handle song tap
          }),
        ],
      ),
    );
  }

  Future<void> createPlaylist(
    String title, String description, List<Song> songs) async {
    
    // Convert the list of songs to a list of TubeTracks
    List<TubeTrack> tracks = songs
    .asMap()
    .entries
    .map((entry) => TubeTrack(
        id: 'track${entry.key + 1}', 
        title: entry.value.songName, 
        artist: entry.value.artist))
    .toList();

    // Create a new Playlist object
    VideoPlaylist playlist =
        VideoPlaylist(title: title, description: description, tracks: tracks);

    // Convert the Playlist to a JSON string
    String jsonPlaylist = jsonEncode(playlist.toJson());

     // Print the JSON string to the console
    print('Sending the following JSON to the server:');
    print(jsonPlaylist);

    String jsonText = jsonEncode("This is a test");

    /*
    var response = await http.post(
      Uri.parse('http://10.0.2.2:3030/log'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonText,
    );
    */

    // Send the playlist to the server
    
    var response = await http.post(
      Uri.parse('http://10.0.2.2:3030/playlists'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonPlaylist,
    );
    

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, then parse the JSON.
      print('Playlist created successfully');
    } else {
      // If the server returns an unsuccessful response code, throw an exception.
      throw Exception('Failed to create playlist: ${response.statusCode}');
    }
  }
}
