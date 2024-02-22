import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/song.dart';

class SongInfo extends StatefulWidget {
  const SongInfo(this.song, {super.key});
  final Song song;

  @override
  createState() => _SongInfoState();
}

class _SongInfoState extends State<SongInfo> {
  late Future<String> songInfoFuture;

  @override
  void initState() {
    super.initState();
    songInfoFuture = _fetchSongInfo(widget.song);
  }

  Future<String> _fetchSongInfo(Song song) async {
    final searchQuery = song.artist;
    final defaultReponse = "No results found for ${song.artist}";

    try {
      // First, search for the query
      final searchResponse = await http.get(
        Uri.parse(
            'https://en.wikipedia.org/w/api.php?action=query&format=json&list=search&utf8=1&formatversion=2&srsearch=${Uri.encodeFull(searchQuery)}'),
      );

      if (searchResponse.statusCode == 200) {
        final searchData = jsonDecode(searchResponse.body);
        final searchResults = searchData['query']['search'] as List<dynamic>;

        if (searchResults.isNotEmpty) {
          // If there are search results, fetch the extract of the first result
          final title = searchResults[0]['title'];
          final extractResponse = await http.get(
            Uri.parse(
                'https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=${Uri.encodeFull(title)}'),
          );

          if (extractResponse.statusCode == 200) {
            final extractData = jsonDecode(extractResponse.body);
            final pages = extractData['query']['pages'] as Map<String, dynamic>;
            final page = pages.values
                .firstWhere((page) => page['pageid'] != null, orElse: () => {});
            return page.isNotEmpty
                ? page['extract'] ?? defaultReponse
                : defaultReponse;
          } else {
            return defaultReponse;
          }
        } else {
          return defaultReponse;
        }
      } else {
        return defaultReponse;
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
      return FutureBuilder<String>(
        future: songInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Text(snapshot.data ?? '');
          }
        },
      );
  }
}
