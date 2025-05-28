import 'package:flutter/material.dart';
import '../colors/colors.dart';
// import your user-model / api client here
// import '../models/user.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // dummy user data — replace with your API call
  String _userName = 'Loading…';
  String _avatarUrl =
      'https://via.placeholder.com/150'; // load from your API
  bool _loadingUser = true;

  // notification toggles
  bool _notifReceived = true;
  bool _notifNewsletter = false;
  bool _notifOffer = true;
  bool _notifUpdates = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    // TODO: call your backend / Firebase to get current user
    await Future.delayed(Duration(seconds: 1)); // simulate network
    setState(() {
      _userName = 'John Doe';
      _avatarUrl =
      'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg';
      _loadingUser = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColor.kPrimary;
    final accent = AppColor.kLightAccentColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Profile card ─────────────────────────
            _loadingUser
                ? Center(child: CircularProgressIndicator())
                : Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: primary,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(_avatarUrl),
                ),
                title: Text(
                  _userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    // TODO: navigate to edit-profile screen
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Account actions ───────────────────────
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.lock, color: accent),
                    title: Text('Change Password'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: navigator to change-password
                    },
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.translate, color: accent),
                    title: Text('Change Language'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.location_on, color: accent),
                    title: Text('Change Location'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notification Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ),
            const SizedBox(height: 8),

            SwitchListTile(
              title: Text('Received notification'),
              value: _notifReceived,
              onChanged: (v) => setState(() => _notifReceived = v),
              activeColor: accent,
            ),
            SwitchListTile(
              title: Text('Received newsletter'),
              value: _notifNewsletter,
              onChanged: (v) => setState(() => _notifNewsletter = v),
              activeColor: accent,
            ),
            SwitchListTile(
              title: Text('Received offer notification'),
              value: _notifOffer,
              onChanged: (v) => setState(() => _notifOffer = v),
              activeColor: accent,
            ),
            SwitchListTile(
              title: Text('Received app updates'),
              value: _notifUpdates,
              onChanged: (v) => setState(() => _notifUpdates = v),
              activeColor: accent,
            ),
          ],
        ),
      ),

      // ── Logout FAB ─────────────────────────────
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () {
          // TODO: your logout logic here
          Navigator.pushReplacementNamed(context, '/login');
        },
        child: Icon(Icons.power_settings_new, color: Colors.white),
      ),
    );
  }
}
