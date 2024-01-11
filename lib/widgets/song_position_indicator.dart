import 'package:flutter/material.dart';
import '../models/song.dart';

class SongPositionIndicator extends StatelessWidget {
  final Song song;
  final int position;

  const SongPositionIndicator(this.position, this.song, {super.key});

  @override
  Widget build(BuildContext context) {
    final IconData iconData = determineIconData(position, song);
    final Color iconColor = determineIconColor(position, song);

    return Column(
      children: <Widget>[
        Flexible(
          fit: FlexFit.tight,
          child: Text(
              '$position',
              style: Theme.of(context).textTheme.titleLarge,
            ),
        ),
        //const SizedBox(height: 2),
        Flexible(
          fit: FlexFit.tight,
          child: Icon(
              iconData,
              color: iconColor,
              size: Theme.of(context).textTheme.titleLarge?.fontSize,
            ),
        ),

      ],
    );
  }

  IconData determineIconData(int position, Song song) {
    if (song.isNew) {
      return Icons.fiber_new;
    } else if (song.isReentry) {
      return Icons.refresh;
    } else if (position < song.lw) {
      return Icons.arrow_upward;
    } else if (position > song.lw) {
      return Icons.arrow_downward;
    } else {
      return Icons.horizontal_rule;
    }
  }

  Color determineIconColor(int position, Song song) {
    if (song.isNew) {
      return Colors.green;
    } else if (song.isReentry) {
      return Colors.orange;
    } else if (position > song.lw) {
      return Colors.red;
    } else if (position < song.lw) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }
}
