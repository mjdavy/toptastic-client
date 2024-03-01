import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/song.dart';
import 'youtube_thumbnail.dart';

class VideoChooserScreen extends StatefulWidget {
  final Song song;
  final Function(String) onVideoIdUpdated; // Callback function

  const VideoChooserScreen({super.key, required this.song, required this.onVideoIdUpdated});

  @override
  createState() => _VideoChooserScreenState();
}

class _VideoChooserScreenState extends State<VideoChooserScreen> {
  late TextEditingController _videoIdController;
  List<Video> _matchingVideos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _videoIdController = TextEditingController(text: widget.song.videoId);
  }

  @override
  void dispose() {
    _videoIdController.dispose();
    super.dispose();
  }

  Future<void> searchVideos() async {
    setState(() {
      _isLoading = true;
    });

    final yt = YoutubeHttpClient();
    final query = '${widget.song.songName} ${widget.song.artist}';

    try {
      final searchResult = await SearchClient(yt).search(query);
      _matchingVideos = searchResult.take(5).toList();
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void updateVideoId(String videoId) {
    setState(() {
      widget.song.updateVideoId(videoId);
      widget.onVideoIdUpdated(videoId);
    });
    
  }

  void selectVideo(Video video) {
    setState(() {
      _videoIdController.text = video.id.value;
      _matchingVideos = [];
      updateVideoId(video.id.value);
    });
  }

  void openYoutube() async {
    final artist = widget.song.artist;
    final title = widget.song.songName;
    final query = '$artist $title';

    final url = Uri.parse('https://www.youtube.com/results?search_query=$query');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${widget.song.songName}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Artist: ${widget.song.artist}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _videoIdController,
              onChanged: (value) {
                updateVideoId(value);
              },
              decoration: const InputDecoration(
                labelText: 'Video ID',
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: searchVideos,
                  child: const Text('Search Videos'),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  onPressed: openYoutube,
                  icon: const Icon(Icons.video_library, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_matchingVideos.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _matchingVideos.length,
                  itemBuilder: (context, index) {
                    final video = _matchingVideos[index];
                    return ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Image.network(video.thumbnails.mediumResUrl),
                      ),
                      title: Text(video.title),
                      onTap: () {
                        selectVideo(video);
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16.0),
            YoutubeThumbnail(song: widget.song),
          ],
        ),
      ),
    );
  }
}
