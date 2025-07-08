import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _imageUrl;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _imageUrl = image.path);

      // Upload to Firebase Storage
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_profiles')
            .child('${_currentUser!.uid}.jpg');

        await ref.putFile(File(image.path));
        final downloadUrl = await ref.getDownloadURL();

        // Update user profile
        await _currentUser!.updatePhotoURL(downloadUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile picture: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade700,
              Colors.green.shade50,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.green.shade100,
                            backgroundImage: _imageUrl != null
                                ? FileImage(File(_imageUrl!))
                                : _currentUser?.photoURL != null
                                ? NetworkImage(_currentUser!.photoURL!)
                            as ImageProvider
                                : null,
                            child: _imageUrl == null && _currentUser?.photoURL == null
                                ? Icon(Icons.person,
                                size: 50, color: Colors.green.shade700)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.green.shade700,
                              radius: 18,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt,
                                    size: 18, color: Colors.white),
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentUser?.displayName ?? 'User',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _currentUser?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: Colors.green.shade700,
                      ),
                    ),
                    _buildSettingsTile(
                      icon: Icons.lock,
                      title: 'Change Password',
                      onTap: () => Navigator.pushNamed(context, '/forgot-password'),
                    ),
                    _buildSettingsTile(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: 'English',
                    ),
                    _buildSettingsTile(
                      icon: Icons.dark_mode,
                      title: 'Dark Mode',
                      trailing: Switch(
                        value: false,
                        onChanged: (value) {},
                        activeColor: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.help,
                      title: 'Help & Support',
                    ),
                    _buildSettingsTile(
                      icon: Icons.privacy_tip,
                      title: 'Privacy Policy',
                    ),
                    _buildSettingsTile(
                      icon: Icons.logout,
                      title: 'Logout',
                      textColor: Colors.red,
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
