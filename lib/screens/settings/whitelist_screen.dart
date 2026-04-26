import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms_rex/theme/app_theme.dart';

class WhitelistScreen extends StatefulWidget {
  const WhitelistScreen({super.key});
  @override
  State<WhitelistScreen> createState() => _WhitelistScreenState();
}

class _WhitelistScreenState extends State<WhitelistScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  List<String> _whitelisted = [];
  bool _loading = true;

  // Common apps
  final List<Map<String, String>> _commonApps = [
    {'pkg': 'com.whatsapp', 'name': 'WhatsApp', 'icon': '🟢'},
    {'pkg': 'com.google.android.gm', 'name': 'Gmail', 'icon': '📧'},
    {'pkg': 'com.instagram.android', 'name': 'Instagram', 'icon': '📸'},
    {'pkg': 'com.facebook.katana', 'name': 'Facebook', 'icon': '📘'},
    {'pkg': 'com.twitter.android', 'name': 'Twitter / X', 'icon': '🐦'},
    {'pkg': 'com.google.android.youtube', 'name': 'YouTube', 'icon': '▶️'},
    {'pkg': 'com.snapchat.android', 'name': 'Snapchat', 'icon': '👻'},
    {'pkg': 'org.telegram.messenger', 'name': 'Telegram', 'icon': '✈️'},
    {'pkg': 'com.google.android.apps.messaging', 'name': 'Messages', 'icon': '💬'},
    {'pkg': 'com.android.dialer', 'name': 'Phone / Calls', 'icon': '📞'},
    {'pkg': 'com.amazon.mShop.android.shopping', 'name': 'Amazon', 'icon': '🛒'},
    {'pkg': 'com.phonepe.app', 'name': 'PhonePe', 'icon': '💸'},
    {'pkg': 'net.one97.paytm', 'name': 'Paytm', 'icon': '💳'},
    {'pkg': 'com.google.android.apps.tachyon', 'name': 'Google Meet', 'icon': '📹'},
    {'pkg': 'com.microsoft.teams', 'name': 'Microsoft Teams', 'icon': '💼'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _whitelisted = List<String>.from(doc.data()?['whitelistedApps'] ?? []);
      _loading = false;
    });
  }

  Future<void> _toggle(String pkg) async {
    setState(() {
      if (_whitelisted.contains(pkg)) {
        _whitelisted.remove(pkg);
      } else {
        _whitelisted.add(pkg);
      }
    });
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'whitelistedApps': _whitelisted});
  }

  Future<void> _selectAll() async {
    setState(() => _whitelisted = _commonApps.map((a) => a['pkg']!).toList());
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'whitelistedApps': _whitelisted});
  }

  Future<void> _clearAll() async {
    setState(() => _whitelisted = []);
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'whitelistedApps': []});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text('📱 Apps Whitelist', style: GoogleFonts.exo2(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(onPressed: _selectAll, child: const Text('Sab', style: TextStyle(color: AppTheme.primary))),
          TextButton(onPressed: _clearAll, child: const Text('Clear', style: TextStyle(color: AppTheme.error))),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
        : Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'In apps ka notification Auto Mode mein forward hoga',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${_whitelisted.length} selected',
                      style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _commonApps.length,
                itemBuilder: (_, i) {
                  final app = _commonApps[i];
                  final pkg = app['pkg']!;
                  final selected = _whitelisted.contains(pkg);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primary.withOpacity(0.1) : AppTheme.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? AppTheme.primary : Colors.transparent, width: 1.5),
                    ),
                    child: ListTile(
                      leading: Text(app['icon']!, style: const TextStyle(fontSize: 26)),
                      title: Text(app['name']!, style: TextStyle(
                        color: selected ? AppTheme.primary : AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      )),
                      subtitle: Text(pkg, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                      trailing: Checkbox(
                        value: selected,
                        onChanged: (_) => _toggle(pkg),
                        activeColor: AppTheme.primary,
                        checkColor: Colors.black,
                        side: const BorderSide(color: AppTheme.textSecondary),
                      ),
                      onTap: () => _toggle(pkg),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}
