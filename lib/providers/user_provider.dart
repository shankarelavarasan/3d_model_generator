import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  
  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final authUser = AuthService.currentUser;
      if (authUser != null) {
        _user = UserModel(
          id: authUser.id,
          email: authUser.email ?? '',
          name: authUser.userMetadata?['name'],
          avatar: authUser.userMetadata?['avatar'],
          createdAt: authUser.createdAt,
        );
      }
    } catch (e) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> signOut() async {
    await AuthService.signOut();
    _user = null;
    notifyListeners();
  }
}