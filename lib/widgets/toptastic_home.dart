import 'package:flutter/material.dart';
import 'package:toptastic/models/song.dart';
import '../models/utility.dart';
import 'settings_page.dart';
import 'song_list.dart';

import '../models/video_playlist.dart';
import 'package:intl/intl.dart';

class TopTasticHome extends StatefulWidget {
  const TopTasticHome({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  createState() => _TopTasticHomeState();
}

class _TopTasticHomeState extends State<TopTasticHome> {
  var _selectedDate = findPreviousFriday(DateTime.now());
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

          title: const Text("TopTastic"),

          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = findPreviousFriday(pickedDate);
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

                // Find the previous Friday from the selected date
                DateTime previousFriday = findPreviousFriday(_selectedDate);

                // Format the previous Friday
                String formattedPreviousFriday =
                    DateFormat('EEEE, MMMM d, yyyy').format(previousFriday);

                // Get the current date and format it
                String formattedCurrentDate =
                    DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

                // Call the function to create the playlist
                await createPlaylist(
                    'UK Singles Chart - $formattedPreviousFriday',
                    'Created by Toptastic on $formattedCurrentDate',
                    songs);
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
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
              Colors.white,
                Colors.grey,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'UK Singles Chart Top 100',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              SongList(_songsFuture, (Song song) {
                // Handle song tap
              }),
            ],
          ),
        ));
  }
}
