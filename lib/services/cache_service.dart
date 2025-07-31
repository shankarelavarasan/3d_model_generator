import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  static const String _modelsKey = 'cached_models';
  static const Duration _cacheDuration = Duration(hours: 1);
  
  Future<void> cacheModels(List<ModelModel> models) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'models': models.map((m) => json.encode(m.toJson())).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_modelsKey, json.encode(data));
  }
  
  Future<List<ModelModel>?> getCachedModels() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_modelsKey);
    
    if (cached == null) return null;
    
    final data = json.decode(cached);
    final timestamp = DateTime.parse(data['timestamp']);
    
    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      return null;
    }
    
    return (data['models'] as List)
        .map((m) => ModelModel.fromJson(json.decode(m)))
        .toList();
  }
}