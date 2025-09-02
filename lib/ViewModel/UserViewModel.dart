import 'package:flutter/foundation.dart';
import '../models/userModel.dart';
import '../services/ApiService.dart';

class UserViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<User> users = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> getUsers(int page) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      users = await _apiService.fetchUsers(page);
    } catch (e) {
      debugPrint("Error fetching users: $e");
      errorMessage = e.toString();
      users = [];
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