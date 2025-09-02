import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ViewModel/UserViewModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'UserDetailsVC.dart';
import '../models/userModel.dart';

class HomeVC extends StatefulWidget {
  const HomeVC({super.key});

  @override
  State<HomeVC> createState() => _HomeVCState();
}

class _HomeVCState extends State<HomeVC> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<UserViewModel>(context, listen: false).getUsers(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Users")),
      body: Builder(
        builder: (context) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (viewModel.errorMessage != null) {
            return Center(
              child: Text(
                "Error: ${viewModel.errorMessage}",
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }
          if (viewModel.users.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          return ListView.builder(
            itemCount: viewModel.users.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final user = viewModel.users[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  leading: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Dialog(
                            backgroundColor: Colors.white.withOpacity(0.9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                imageUrl: user.avatar,
                                placeholder: (context, url) => const SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.error, size: 50),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(user.avatar),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  title: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailsVC(userId: user.id), // ✅ fix
                        ),
                      );
                    },
                    child: Text(
                      "${user.firstName} ${user.lastName}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  subtitle: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetailsVC(userId: user.id), // ✅ fix
                        ),
                      );
                    },
                    child: Text(user.email),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
