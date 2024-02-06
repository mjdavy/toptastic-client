import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<void> downloadDatabase() async {
  var url = 'http://example.com/database.db'; // Replace with your database URL
  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    var bytes = response.bodyBytes;
    var dir = await getApplicationDocumentsDirectory();
    File file = File('${dir.path}/songs.db');
    await file.writeAsBytes(bytes);
  } else {
    throw Exception('Failed to download database');
  }
}