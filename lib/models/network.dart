//
// network.dart
//
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

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

Future<String> getServerStatus(String serverUrl, String port) async {
  String? ipAddress = await resolveHostname(serverUrl);
  if (ipAddress != null) {
    // Check if the IP address is IPv6. If it is, wrap it in square brackets.
    if (ipAddress.contains(':')) {
      ipAddress = '[$ipAddress]';
    }

    String url = 'http://$ipAddress:$port/api/status';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return response.body;
    }
  }

  throw Exception('Failed to get server status');
}