import 'package:flutter/material.dart';
import 'package:toptastic/models/song.dart';

class ChartInfo extends StatelessWidget {
  const ChartInfo({super.key, required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {

    // Extract the common style into a variable
    final textStyle = Theme.of(context).textTheme.titleMedium;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Artist: ${song.artist}',
              style: textStyle,
            ),
            Text(
              'Title: ${song.songName}',
              style: textStyle,
            ),
            Text(
              'Current Position: ${song.position}',
              style: textStyle,
            ),
            Text(
              'Last Week Position: ${song.lw}',
              style: textStyle,
            ),
      
            Text(
              'Peak Position: ${song.peak}',
              style: textStyle,
            ),
            Text(
              'Weeks in Chart: ${song.weeks}',
              style: textStyle,
            ),
          ],
      ),
    );
  }
}