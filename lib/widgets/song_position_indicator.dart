import 'package:flutter/material.dart';
import '../models/song.dart';

class SongPositionIndicator extends StatelessWidget {
  final Song song;
  final int position;

  const SongPositionIndicator(this.position, this.song, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(child: Text('$position', style: Theme.of(context).textTheme.headlineLarge)),
        const Icon(Icons.arrow_upward), // for an upward arrow
        // Icon(Icons.arrow_downward), // for a downward arrow
      ],
    );
  }
}
