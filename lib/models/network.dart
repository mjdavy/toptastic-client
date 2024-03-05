//
// network.dart
//
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';

final logger = Logger();

Future<String?> resolveHostname(String hostname) async {
  try {
    List<InternetAddress> addresses = await InternetAddress.lookup(hostname);
    return addresses.first.address;
  } catch (e) {
    logger.e('Error resolving hostname: $e');
    return null;
  }
}

Future<String> getServerUrl() async {
  final prefs = await SharedPreferences.getInstance();
  final serverName = prefs.getString('serverName');
  final port = prefs.getString('port');

  if (serverName == null || port == null) {
    throw ServerNotConfiguredException('Server is not configured');
  }

  return 'http://$serverName:$port';
}

Future<String> getServerStatus(String serverUrl, String port) async {
  String? ipAddress = await resolveHostname(serverUrl);
  if (ipAddress != null) {
    // Check if the IP address is IPv6. If it is, wrap it in square brackets.
    if (ipAddress.contains(':')) {
      ipAddress = '[$ipAddress]';
    }

    final serverUrl = await getServerUrl();
    String url = '$serverUrl/api/status';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.body;
    }
  }

  throw Exception('Failed to get server status');
}