import 'package:flutter/material.dart';
import 'package:toptastic/models/song.dart';
import '../models/data.dart';
import '../models/utility.dart';
import 'song_list.dart';
import 'package:intl/intl.dart';

import 'youtube_playlist_screen.dart';

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
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  var _selectedDate = findPreviousFriday(DateTime.now());
  late Future<List<Song>> _songsFuture;
  bool _isFilteringFavorites = false;
  bool _isAscendingOrder = true;

  @override
  void initState() {
    super.initState();
    _songsFuture = _loadSongs(_selectedDate);
  }

  Future<List<Song>> _loadSongs(DateTime date) async {
    try {
      var songs = await fetchSongs(date);
      songs.sort((a, b) => _isAscendingOrder
          ? a.position.compareTo(b.position)
          : b.position.compareTo(a.position));
      return songs;
    } on FetchSongsException catch (e) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(e.message), // Display the error message
          duration: const Duration(seconds: 2),
        ),
      );
    }
    return <Song>[];
  }

  void _toggleFavoriteFilter() {
    setState(() {
      _isFilteringFavorites = !_isFilteringFavorites;
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscendingOrder = !_isAscendingOrder;
      _songsFuture = _loadSongs(_selectedDate);
    });
  }

  Future<void> _navigateToYoutubePlaylistScreen() async {
    List<Song> songs = await _songsFuture;
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              YoutubePlaylistScreen(songs: songs, date: _selectedDate, favoritesOnly: _isFilteringFavorites),
        ),
      );
    }
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

          title: const Text("TopTastic Videos"),

          actions: [
            IconButton(
              onPressed: _navigateToYoutubePlaylistScreen,
              icon: const Icon(Icons.play_arrow),
            ),
            // This is the button that will open the DatePicker to choose a playlist date
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
                    _songsFuture = _loadSongs(_selectedDate);
                  });
                }
              },
            ),
            IconButton(
              icon: Icon(
                _isFilteringFavorites ? Icons.star : Icons.star_border,
                color: _isFilteringFavorites ? Colors.amber : null,
              ),
              onPressed: _toggleFavoriteFilter,
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: _toggleSortOrder,
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white,
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
              SongList(
                  songsFuture: _songsFuture,
                  favoritesOnly: _isFilteringFavorites),
            ],
          ),
        ));
  }
}
