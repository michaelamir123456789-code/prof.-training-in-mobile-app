import 'dart:convert';  // For converting data to/from JSON.
import 'package:crypto/crypto.dart'; // For hashing passwords.
import 'package:shared_preferences/shared_preferences.dart'; // Local database.
import '../models/media_item.dart'; // banadi el models el file media_item.dart

// A class containing static functions for saving and loading data. (bdl ma a create new object)
class Storage {
  static const _usersKey = 'users';
  static const _sessionKey = 'session';
// Keys used to store data in SharedPreferences.
  static String _itemsKey(String email) => 'items_$email';

 // be hash el passwords lel security
  static String hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

// be load list of all registered users from storage.
  static Future<Map<String, String>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  // Registers a new user be Returns an error message, or null if successful.
  // we lw fi email mawgod alreadt be2olo: This email is already registered.
  // we el password bet3et el email beta3 el user betkon hash
  static Future<String?> register(String email, String password) async {
    final users = await _loadUsers();
    if (users.containsKey(email)) return 'This email is already registered.';
    users[email] = hash(password);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.setString(_sessionKey, email);
    return null;
  }
// be5od el email w el password w password w lw mafish fel login account be2olo: No account found for this email. 
// w lw wrong pass: Wrong password. (by Checking hashes match.)
// we ya3melo session 3lshan yekon fakro
  static Future<String?> login(String email, String password) async {
    final users = await _loadUsers();
    if (users[email] == null) return 'No account found for this email.';
    if (users[email] != hash(password)) return 'Wrong password.';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);
    return null;
  }

// Checks if someone is already logged in.
  static Future<String?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  // Logs the user out by removing the session.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // Loads the specific user's list of movies/series.
  static Future<List<MediaItem>> loadItems(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_itemsKey(email));
    if (raw == null) return [];
    // Convert JSON string back into a List of MediaItem objects.
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => MediaItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // Saves the specific user's list of movies/series.
  static Future<void> saveItems(String email, List<MediaItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _itemsKey(email),
  // Convert the list of MediaItems into a JSON string.
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}