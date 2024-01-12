class TubeTrack {
  final String id;
  final String title;
  final String artist;
  final String? videoId;

  TubeTrack({required this.id, required this.title, this.videoId, required this.artist});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'videoId': videoId ?? '',
      };
}

class VideoPlaylist {
  final String title;
  final String description;
  final List<TubeTrack> tracks;

  VideoPlaylist(
      {required this.title, required this.description, required this.tracks});

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'tracks': tracks.map((track) => track.toJson()).toList(),
      };
}