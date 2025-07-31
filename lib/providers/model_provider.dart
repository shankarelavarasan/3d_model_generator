import 'package:flutter/foundation.dart';
import '../models/model_model.dart';

class ModelProvider extends ChangeNotifier {
  List<ModelModel> _models = [];
  bool _isLoading = false;
  
  List<ModelModel> get models => _models;
  bool get isLoading => _isLoading;
  
  Future<void> loadUserModels() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await Supabase.instance.client
          .from('models')
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser?.id)
          .order('created_at', ascending: false);
      
      _models = response.map((json) => ModelModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading models: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
}