import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final logger = Logger();

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _portController = TextEditingController();

  String _serverUrl = '';
  String _serverStatus = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadServerUrl();
  }

  Future<String?> resolveHostname(String hostname) async {
    try {
      List<InternetAddress> addresses = await InternetAddress.lookup(hostname);
      return addresses.first.address;
    } catch (e) {
      logger.e('Error resolving hostname: $e');
      return null;
    }
  }

  Future<void> _loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverUrl = prefs.getString('serverName') ?? 'Ronald.local';
      _serverController.text = _serverUrl;
      _portController.text = prefs.getString('port') ?? '5001';
    });
  }

  Future<void> _saveServerUrl() async {
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('serverName', _serverController.text);
      prefs.setString('port', _portController.text);
      setState(() {
        _serverUrl = _serverController.text;
      });
      await getServerStatus();
    }
  }

  Future<String> getServerStatus() async {
    setState(() {
      _isLoading = true;
    });

    String? ipAddress = await resolveHostname(_serverUrl);
    if (ipAddress != null) {
      String url = 'http://$ipAddress:${_portController.text}/status';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _serverStatus = response.body;
          _isLoading = false;
        });
        return _serverStatus;
      }
    }

    setState(() {
      _serverStatus = 'Failed to get server status';
      _isLoading = false;
    });
    throw Exception(_serverStatus);
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
                  labelText: 'Server Hostname',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the server hostname';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: 'Server Port',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the server port';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _saveServerUrl,
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _serverStatus.isNotEmpty
                        ? Text('Server Status: $_serverStatus')
                        : const Text(''),
              ),
            ],
          ),
        ),
      ),
    );
  }
}