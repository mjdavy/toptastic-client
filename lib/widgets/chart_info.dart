import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toptastic/models/song.dart';

class ChartInfo extends StatefulWidget {
  const ChartInfo({super.key, required this.song});

  final Song song;

  @override
  createState() => _ChartInfoState();
}

class _ChartInfoState extends State<ChartInfo> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  void _loadFavoriteState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorite = (prefs.getBool('favorite_${widget.song.id}') ?? false);
    });
  }

  void _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    isFavorite = !isFavorite;
    await prefs.setBool('favorite_${widget.song.id}', isFavorite);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Extract the common style into a variable
    final textStyle = Theme.of(context).textTheme.titleMedium;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(
              'Title: ${widget.song.songName}',
              style: textStyle,
            ),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.amber : null,
              ),
              onPressed: _toggleFavorite,
            ),
          ]),
          Text(
            'Artist: ${widget.song.artist}',
            style: textStyle,
          ),
          Text(
            'Current Position: ${widget.song.position}',
            style: textStyle,
          ),
          Text(
            'Last Week Position: ${widget.song.lw}',
            style: textStyle,
          ),
          Text(
            'Peak Position: ${widget.song.peak}',
            style: textStyle,
          ),
          Text(
            'Weeks in Chart: ${widget.song.weeks}',
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
