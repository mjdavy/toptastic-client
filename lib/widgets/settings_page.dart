import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadServerUrl();
  }

  Future<void> _loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _serverController.text = prefs.getString('serverUrl') ?? '';
  }

  Future<void> _saveServerUrl() async {
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('serverUrl', _serverController.text);
    }
  }

  Future<String> getServerStatus() async {
    var response = await http.get(Uri.parse('http://10.0.2.2:3030/status'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, return the response body.
      return response.body;
    } else {
      // If the server returns an unsuccessful response code, throw an exception.
      throw Exception('Failed to get server status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _serverController,
                decoration: const InputDecoration(
                  labelText: 'Song Server URL',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the server URL';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _serverController,
                decoration: const InputDecoration(
                  labelText: 'Video Playlist Server URL',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the server URL';
                  }
                  return null;
                },
              ),
              Expanded(
                child: FutureBuilder<String>(
                  future: getServerStatus(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Text('Video Server Status: ${snapshot.data}');
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    // By default, show a loading spinner.
                    return CircularProgressIndicator();
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _saveServerUrl,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
