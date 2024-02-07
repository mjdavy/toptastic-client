import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:settings_ui/settings_ui.dart';

import '../models/network.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _serverController = TextEditingController();
  final _portController = TextEditingController();
  bool _offlineMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings().then((_) {
      _validateSettings();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverController.text = prefs.getString('serverName') ?? 'Ronald.local';
      _portController.text = prefs.getString('port') ?? '5001';
      _offlineMode = prefs.getBool('offlineMode') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('serverName', _serverController.text);
    prefs.setString('port', _portController.text);
    prefs.setBool('offlineMode', _offlineMode);
  }

  String _serverStatus = 'Unknown';

  Future<void> _validateSettings() async {
    String? ipAddress = await resolveHostname(_serverController.text);
    if (ipAddress == null) {
      setState(() {
        _offlineMode = true;
        _serverStatus = 'Unable to resolve hostname';
      });
      return;
    }

    try {
      await getServerStatus(_serverController.text, _portController.text);
      setState(() {
        _serverStatus = 'Server is online';
      });
    } catch (e) {
      setState(() {
        _offlineMode = true;
        _serverStatus = 'Server is offline';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Server Settings'),
            tiles: [
              SettingsTile(
                leading: const Icon(Icons.dns),
                title: const Text('Host Name'),
                value: SizedBox(
                  width: 400, // Adjust this value as needed
                  child: TextField(
                    maxLength: 253,
                    controller: _serverController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9.-]')),
                    ],
                  ),
                ),
                onPressed: (BuildContext context) {
                  _serverController.text = _serverController.text;
                  _saveSettings();
                },
              ),
              SettingsTile(
                leading: const Icon(Icons.portrait),
                title: const Text('Port'),
                value: SizedBox(
                  width: 400, // Adjust this value as needed
                  child: TextField(
                    maxLength: 5,
                    controller: _portController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                onPressed: (BuildContext context) {
                  _portController.text = _portController.text;
                  _saveSettings();
                },
              ),
              SettingsTile.switchTile(
                title: const Text('Offline Mode'),
                leading: const Icon(Icons.offline_bolt),
                initialValue: _offlineMode,
                onToggle: (bool value) {
                  setState(() {
                    _offlineMode = value;
                    _saveSettings();
                  });
                },
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Server Status'),
            tiles: [
              SettingsTile(
                title: const Text('Check Server Status:'),
                trailing: ElevatedButton(
                  child: const Icon(Icons.check_circle),
                  onPressed: () async {
                    await _validateSettings();
                    _saveSettings();
                  },
                ),
              ),
              SettingsTile(
                title: const Text('Server Status'),
                value: Text(_serverStatus),
              ),
              SettingsTile(
                title: const Text('Server URL'),
                value: Text(
                    'http://${_serverController.text}:${_portController.text}'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
