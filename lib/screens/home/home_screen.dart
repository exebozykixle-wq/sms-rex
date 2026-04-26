import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms_rex/theme/app_theme.dart';
import 'package:sms_rex/screens/auth/login_screen.dart';
import 'package:sms_rex/screens/compose/compose_screen.dart';
import 'package:sms_rex/screens/history/history_screen.dart';
import 'package:sms_rex/screens/settings/settings_screen.dart';
import 'package:sms_rex/screens/settings/whitelist_screen.dart';
import 'package:sms_rex/screens/private/private_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  bool _autoMode = false;
  bool _globalMode = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _userData = doc.data();
      _autoMode = doc.data()?['autoMode'] ?? false;
      _globalMode = doc.data()?['globalMode'] ?? true;
    });
  }

  Future<void> _toggleAutoMode(bool val) async {
    setState(() => _autoMode = val);
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'autoMode': val});
  }

  Future<void> _toggleMode(bool isGlobal) async {
    setState(() => _globalMode = isGlobal);
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'globalMode': isGlobal});
  }

  Future<void> _logout() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'online': false});
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Row(
          children: [
            Text('🐍', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text('SMS REX', style: GoogleFonts.orbitron(
              color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 18,
            )),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.history, color: AppTheme.textSecondary),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()))),
          IconButton(icon: const Icon(Icons.settings, color: AppTheme.textSecondary),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
          IconButton(icon: const Icon(Icons.logout, color: AppTheme.textSecondary), onPressed: _logout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            if (_userData != null) _buildUserCard(),
            const SizedBox(height: 20),

            // AUTO MODE toggle
            _buildAutoModeCard(),
            const SizedBox(height: 20),

            // Global / Private selector
            _buildModeSelector(),
            const SizedBox(height: 20),

            // Recent Messages
            _buildRecentMessages(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => ComposeScreen(isGlobal: _globalMode),
        )),
        icon: const Icon(Icons.send, color: Colors.black),
        label: Text(_globalMode ? 'Global Message' : 'Private Message',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildUserCard() {
    final name = _userData!['name'] ?? '';
    final phone = _userData!['phone'] ?? '';
    final online = _userData!['online'] ?? false;
    final showStatus = _userData!['showOnlineStatus'] ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primary.withOpacity(0.2),
                child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              if (showStatus)
                Positioned(bottom: 0, right: 0,
                  child: Container(
                    width: 14, height: 14,
                    decoration: BoxDecoration(
                      color: online ? Colors.greenAccent : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.card, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
              Text(phone, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutoModeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _autoMode ? AppTheme.primary.withOpacity(0.12) : AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _autoMode ? AppTheme.primary : Colors.transparent, width: 1.5),
      ),
      child: Row(
        children: [
          Text(_autoMode ? '⚡' : '💤', style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Auto Mode', style: TextStyle(
                  color: _autoMode ? AppTheme.primary : AppTheme.textPrimary,
                  fontWeight: FontWeight.w700, fontSize: 16,
                )),
                Text(
                  _autoMode
                    ? 'Phone ke notifications auto forward ho rahe hain'
                    : 'Manually message bhejo',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _autoMode,
            onChanged: _toggleAutoMode,
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Message Mode', style: GoogleFonts.exo2(
          color: AppTheme.textSecondary, fontSize: 13, letterSpacing: 1,
        )),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _modeBtn('🌍', 'Global', 'Sabko bhejo', true)),
            const SizedBox(width: 12),
            Expanded(child: _modeBtn('🔒', 'Private', 'Select karo', false)),
          ],
        ),
        if (!_globalMode) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivateListScreen())),
            icon: const Icon(Icons.group, color: AppTheme.primary, size: 18),
            label: const Text('Private List Manage Karo', style: TextStyle(color: AppTheme.primary)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WhitelistScreen())),
          icon: const Icon(Icons.apps, color: AppTheme.textSecondary, size: 18),
          label: const Text('Apps Whitelist Set Karo', style: TextStyle(color: AppTheme.textSecondary)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.surface),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _modeBtn(String emoji, String title, String sub, bool isGlobal) {
    final selected = _globalMode == isGlobal;
    return GestureDetector(
      onTap: () => _toggleMode(isGlobal),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.15) : AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppTheme.primary : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(
              color: selected ? AppTheme.primary : AppTheme.textPrimary,
              fontWeight: FontWeight.w700, fontSize: 15,
            )),
            Text(sub, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMessages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Messages', style: GoogleFonts.exo2(
          color: AppTheme.textSecondary, fontSize: 13, letterSpacing: 1,
        )),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(5)
            .snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            final docs = snap.data!.docs;
            if (docs.isEmpty) return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Abhi koi message nahi', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            );
            return Column(
              children: docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return _messageCard(doc.id, d);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _messageCard(String id, Map<String, dynamic> d) {
    final isGlobal = d['type'] == 'global';
    final senderName = d['senderName'] ?? 'Unknown';
    final body = d['body'] ?? '';
    final channels = (d['channels'] as List?)?.join(', ') ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isGlobal ? AppTheme.primary.withOpacity(0.15) : Colors.purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(isGlobal ? '🌍 Global' : '🔒 Private',
                  style: TextStyle(color: isGlobal ? AppTheme.primary : Colors.purpleAccent, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Text('📤 $senderName', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              const Spacer(),
              if (d['senderId'] == uid)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _deleteMessage(id),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
          const SizedBox(height: 6),
          Text('Via: $channels', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Future<void> _deleteMessage(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Delete karein?', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Yeh message delete ho jayega.', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('messages').doc(id).delete();
    }
  }
}
