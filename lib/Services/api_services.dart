import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  final String baseUrl = "https://reqres.in/api";

  Future<List<User>> fetchUsers(int page) async {
    final response = await http.get(
      Uri.parse('https://reqres.in/api/users?page=$page'),
      headers: {"accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> usersJson = data['data'];
      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load users");
    }
  }
}
