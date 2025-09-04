import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';


class EdituserVC extends StatefulWidget {
  final User user;

  const EdituserVC({super.key, required this.user});

  @override
  State<EdituserVC> createState() => _EditUserVCState();
}

class _EditUserVCState extends State<EdituserVC> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  File? _selectedImage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

// Show options to user
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }



  Future<void> _saveOrUpdateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection("users")
          .doc(widget.user.id.toString());

      // start with old avatar
      String avatarUrl = widget.user.avatar;

      final userData = {
        "id": widget.user.id,
        "first_name": _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "email": _emailController.text.trim(),
         "avatar": _selectedImage != null ? _selectedImage?.path : avatarUrl,
        "updatedAt": FieldValue.serverTimestamp(),
      };

      await docRef.set(userData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User saved successfully")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save user: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit User"),
        actions: [
          IconButton(
            icon: _saving
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : const Icon(Icons.save),
            onPressed: _saving ? null : _saveOrUpdateUser,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () => _showImageSourceActionSheet(context),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : NetworkImage(widget.user.avatar) as ImageProvider,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: "First Name"),
                validator: (val) => val!.isEmpty ? "Enter first name" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: "Last Name"),
                validator: (val) => val!.isEmpty ? "Enter last name" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (val) =>
                val!.isEmpty || !val.contains("@") ? "Enter valid email" : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _saving ? null : _saveOrUpdateUser,
                label: const Text("Update"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
