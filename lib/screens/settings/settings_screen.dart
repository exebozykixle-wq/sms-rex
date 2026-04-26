import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms_rex/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() { _data = doc.data(); _loading = false; });
  }

  Future<void> _update(String field, dynamic value) async {
    setState(() => _data?[field] = value);
    await FirebaseFirestore.instance.collection('users').doc(uid).update({field: value});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text('⚙️ Settings', style: GoogleFonts.exo2(fontWeight: FontWeight.w700)),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
        : ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primary.withOpacity(0.2),
                    child: Text(
                      (_data?['name'] ?? '?')[0].toUpperCase(),
                      style: const TextStyle(color: AppTheme.primary, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_data?['name'] ?? '', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
                  Text(_data?['email'] ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  Text(_data?['phone'] ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Privacy', style: GoogleFonts.exo2(color: AppTheme.textSecondary, fontSize: 13, letterSpacing: 1)),
            const SizedBox(height: 10),

            _settingTile(
              '🟢', 'Online Status Dikhao',
              'Doosre users aapka online/offline dekh sakein',
              _data?['showOnlineStatus'] ?? true,
              (v) => _update('showOnlineStatus', v),
            ),
            const SizedBox(height: 8),
            _settingTile(
              '🔔', 'App Notifications',
              'SMS REX ke notifications allow karein',
              _data?['appNotifications'] ?? true,
              (v) => _update('appNotifications', v),
            ),
            const SizedBox(height: 24),

            Text('Account', style: GoogleFonts.exo2(color: AppTheme.textSecondary, fontSize: 13, letterSpacing: 1)),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Text('🗑️', style: TextStyle(fontSize: 22)),
                title: const Text('Account Delete Karo', style: TextStyle(color: AppTheme.error)),
                subtitle: const Text('Yeh action permanent hai', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                onTap: () => _confirmDelete(context),
              ),
            ),
          ],
        ),
    );
  }

  Widget _settingTile(String icon, String title, String sub, bool val, Function(bool) onChanged) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 24)),
        title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(sub, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        trailing: Switch(value: val, onChanged: onChanged, activeColor: AppTheme.primary),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Account Delete?', style: TextStyle(color: AppTheme.error)),
        content: const Text('Aapka account hamesha ke liye delete ho jayega.', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      await FirebaseAuth.instance.currentUser?.delete();
    }
  }
}
