
class Song {
  final String artist;
  final String songName;
  final int lw;
  final int peak;
  final bool isNew;
  final bool isReentry;
  final int weeks;
  String videoId;
  bool hasChanges = false;

  Song(
      {required this.artist,
      required this.songName,
      required this.lw,
      required this.peak,
      required this.isNew,
      required this.isReentry,
      required this.weeks,
      required this.videoId});

  factory Song.fromJson(Map<String, dynamic> json) {
  return Song(
    artist: json['artist'],
    songName: json['song_name'],
    lw: json['lw'],
    peak: json['peak'],
    isNew: json['is_new'] is int ? json['is_new'] == 1 : json['is_new'],
    isReentry: json['is_reentry'] is int ? json['is_reentry'] == 1 : json['is_reentry'],
    weeks: json['weeks'],
    videoId: json.containsKey('video_id') &&
            json['video_id'] != null &&
            json['video_id'] != ''
        ? json['video_id']
        : '',
  );
}

  void updateVideoId(String newVideoId) {
    videoId = newVideoId;
    hasChanges = true;
  }
}