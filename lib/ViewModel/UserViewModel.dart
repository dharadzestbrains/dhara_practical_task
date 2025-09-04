import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_services.dart';

class UserViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<User> users = [];
  bool isLoading = false;
  String? errorMessage;

  Future<bool> getUsers(int page) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _apiService.fetchUsers(page);

      if (result.isNotEmpty) {
        users = result;
        notifyListeners();
        return true; // ✅ data found
      } else {
        return false; // ❌ no data
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
      errorMessage = e.toString();
      users = [];
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}


class Support {
  final String url;
  final String text;

  Support({required this.url, required this.text});

  factory Support.fromJson(Map<String, dynamic> json) {
    return Support(
      url: json["url"],
      text: json["text"],
    );
  }
}