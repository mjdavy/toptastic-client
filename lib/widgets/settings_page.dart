import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                  labelText: 'Server URL',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the server URL';
                  }
                  return null;
                },
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
