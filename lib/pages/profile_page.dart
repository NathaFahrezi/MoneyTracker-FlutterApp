import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = UserService.getUser();
  }

  Future<void> _navigateToEditProfile() async {
    final updatedUser = await Navigator.push<UserModel>(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage(user: user)),
    );

    if (updatedUser != null) {
      setState(() {
        user = updatedUser;
        UserService.updateUser(user);
      });
    }
  }

  Widget _buildUserInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700]),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profil Saya'),
        elevation: 0,
        backgroundColor: Colors.green[600],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToEditProfile,
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.edit),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.green[200],
                  backgroundImage: user.profileImage != null
                      ? FileImage(File(user.profileImage!))
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                ),
                const SizedBox(height: 24),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Divider(color: Colors.green[200], thickness: 1.5),
                const SizedBox(height: 16),
                _buildUserInfo(Icons.email, 'Email', user.email),
                _buildUserInfo(Icons.home, 'Alamat', user.address),
                _buildUserInfo(Icons.work, 'Pekerjaan', user.job),
                _buildUserInfo(Icons.favorite, 'Status Perkawinan', user.maritalStatus),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
