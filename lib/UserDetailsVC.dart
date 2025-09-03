import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/userModel.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'EditUserVC.dart';

class UserDetailsVC extends StatefulWidget {
  final int userId;
  final User userData;

  const UserDetailsVC({
    super.key,
        required this.userId,
        required this.userData,
      });

  @override
  State<UserDetailsVC> createState() => _UserDetailsVCState();
}

class _UserDetailsVCState extends State<UserDetailsVC> {
  User? user;
  Support? support;
  bool isLoading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final url = Uri.parse("https://reqres.in/api/users/${widget.userId}");
      print('user Id => ${widget.userId}');
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
        title:  Text(message),
        content: Text('Are you want to display the data from the list ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // go back
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showListData(); // load local user data
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  void _showListData() {
    setState(() {
      user = widget.userData; // fallback data from list
      support = null;          // no API support data
      isLoading = false;
    });
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'add':
        _saveUserToFirestore();
        break;
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EdituserVC(user: user!),
          ),
        ).then((updated) {
          if (updated == true) {
            // _fetchUserDetails(); // refresh after edit
          }
        });
        break;
      case 'delete':
       _deleteUserFromFirestore();
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
        child: Center(
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
      ),
    );
  }

  // MARK: - Save User
  Future<void> _saveUserToFirestore() async {
    if (user == null) return;

    setState(() => _saving = true);

    try {
      final userData = {
        "id": user!.id,
        "email": user!.email,
        "first_name": user!.firstName,
        "last_name": user!.lastName,
        "avatar": user!.avatar,
        "createdAt": FieldValue.serverTimestamp(),
        if (support != null) "support": {
          if (support!.url.isNotEmpty) "url": support!.url,
          if (support!.text.isNotEmpty) "text": support!.text,
        },
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.id.toString()) // use userId as doc id
          .set(userData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User added to Firestore")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add user: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // MARK: - Delete User
  Future<void> _deleteUserFromFirestore() async {
    if (user == null) return;

    setState(() => _saving = true);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.id.toString())
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User deleted from Firestore")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete user: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}