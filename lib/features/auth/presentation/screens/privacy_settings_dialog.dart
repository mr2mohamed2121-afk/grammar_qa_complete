import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySettingsDialog extends StatefulWidget {
  const PrivacySettingsDialog({super.key});

  @override
  State<PrivacySettingsDialog> createState() => _PrivacySettingsDialogState();
}

class _PrivacySettingsDialogState extends State<PrivacySettingsDialog> {
  bool _showName = true;
  bool _showPhoto = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showName = prefs.getBool('show_name_in_leaderboard') ?? true;
      _showPhoto = prefs.getBool('show_photo_in_leaderboard') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _saveName(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_name_in_leaderboard', value);
    setState(() => _showName = value);
  }

  Future<void> _savePhoto(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_photo_in_leaderboard', value);
    setState(() => _showPhoto = value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF16213E),
      title: const Text(
        'الخصوصية',
        style: TextStyle(
          fontFamily: 'Cairo',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE94560)),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text(
                    'إظهار اسمي في الليدربورد',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                    ),
                  ),
                  value: _showName,
                  onChanged: (value) => _saveName(value),
                  activeColor: const Color(0xFFE94560),
                  inactiveTrackColor: Colors.grey[700],
                ),
                SwitchListTile(
                  title: const Text(
                    'إظهار صورتي',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                    ),
                  ),
                  value: _showPhoto,
                  onChanged: (value) => _savePhoto(value),
                  activeColor: const Color(0xFFE94560),
                  inactiveTrackColor: Colors.grey[700],
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'إغلاق',
            style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
          ),
        ),
      ],
    );
  }
}