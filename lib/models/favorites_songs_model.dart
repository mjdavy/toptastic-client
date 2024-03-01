import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteSongsModel extends ChangeNotifier {
  Set<int> _favoriteIds = {};

  Set<int> get favoriteIds => _favoriteIds;

  FavoriteSongsModel() {
    loadFavoriteIds();
  }

  Future<void> loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final idsJson = prefs.getString('favorite_ids');
    if (idsJson != null) {
      final idsList = List<int>.from(jsonDecode(idsJson));
      _favoriteIds = idsList.toSet();
    }
    notifyListeners();
  }

  Future<void> addFavoriteId(int id) async {
    _favoriteIds.add(id);
    await saveFavoriteIds();
    notifyListeners();
  }

  Future<void> removeFavoriteId(int id) async {
    _favoriteIds.remove(id);
    await saveFavoriteIds();
    notifyListeners();
  }

  Future<void> saveFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final idsJson = jsonEncode(_favoriteIds.toList());
    prefs.setString('favorite_ids', idsJson);
  }
}