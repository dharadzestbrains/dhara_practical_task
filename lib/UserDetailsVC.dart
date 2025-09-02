import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/userModel.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



class UserDetailsVC extends StatefulWidget {
  final int userId; // Required user id
  const UserDetailsVC({super.key, required this.userId});

  @override
  State<UserDetailsVC> createState() => _UserDetailsVCState();
}

class _UserDetailsVCState extends State<UserDetailsVC> {
  User? user;
  Support? support;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final url = Uri.parse("https://reqres.in/api/users/${widget.userId}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        setState(() {
          user = User.fromJson(jsonResponse["data"]);
          support = Support.fromJson(jsonResponse["support"]);
          isLoading = false;
        });
      } else {
        _showErrorDialog("Failed to load user details.");
      }
    } catch (e) {
      _showErrorDialog("Something went wrong!");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // close dialog
              Navigator.of(context).pop(); // go back
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'add':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Add User clicked")),
        );
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Edit User clicked")),
        );
        break;
      case 'delete':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Delete User clicked")),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Details"),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(value: 'add', child: Text('Add User')),
                const PopupMenuItem(value: 'edit', child: Text('Edit User')),
                const PopupMenuItem(value: 'delete', child: Text('Delete User')),
              ];
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(child: Text("No user data"))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: user!.avatar,
                placeholder: (context, url) =>
                const CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                const Icon(Icons.error),
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "${user!.firstName} ${user!.lastName}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user!.email,
              style:
              const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (support != null) ...[
              const Divider(),
              Text(
                "Support",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                support!.text,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                support!.url,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}