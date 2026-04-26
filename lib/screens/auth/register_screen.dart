import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms_rex/theme/app_theme.dart';
import 'package:sms_rex/screens/home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _passVisible = false;
  int _step = 0;

  final List<Map<String, dynamic>> _permissions = [
    {'icon': '📱', 'title': 'SMS', 'desc': 'SMS padhne aur bhejne ke liye', 'permission': Permission.sms, 'granted': false},
    {'icon': '🔔', 'title': 'Notifications', 'desc': 'Dusre apps ke notifications forward karne ke liye', 'permission': Permission.notification, 'granted': false},
    {'icon': '👥', 'title': 'Contacts', 'desc': 'Private list ke liye', 'permission': Permission.contacts, 'granted': false},
    {'icon': '📞', 'title': 'Phone', 'desc': 'Call notifications ke liye', 'permission': Permission.phone, 'granted': false},
  ];

  Future<void> _requestAll() async {
    for (int i = 0; i < _permissions.length; i++) {
      final status = await (_permissions[i]['permission'] as Permission).request();
      setState(() => _permissions[i]['granted'] = status.isGranted);
    }
  }

  Future<void> _register() async {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _showSnack('Sabhi fields bharein!');
      return;
    }
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'online': true,
        'showOnlineStatus': true,
        'autoMode': false,
        'globalMode': true,
        'whitelistedApps': [],
        'privateUsers': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      _showSnack('Error: ${e.toString()}');
    }
    setState(() => _loading = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppTheme.card,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _step == 0 ? _buildForm() : _buildPermissions(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Center(child: Text('🐍', style: TextStyle(fontSize: 60))),
          const SizedBox(height: 16),
          Center(
            child: Text('SMS REX', style: GoogleFonts.orbitron(
              fontSize: 28, fontWeight: FontWeight.w900,
              color: AppTheme.primary, letterSpacing: 3,
            )),
          ),
          Center(child: Text('Account Banao', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14))),
          const SizedBox(height: 40),
          _field('Aapka Naam', Icons.person_outline, _nameCtrl),
          const SizedBox(height: 16),
          _field('Phone Number', Icons.phone_outlined, _phoneCtrl, type: TextInputType.phone),
          const SizedBox(height: 16),
          _field('Email', Icons.email_outlined, _emailCtrl, type: TextInputType.emailAddress),
          const SizedBox(height: 16),
          TextField(
            controller: _passCtrl,
            obscureText: !_passVisible,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_passVisible ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary),
                onPressed: () => setState(() => _passVisible = !_passVisible),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _step = 1),
              child: const Text('Aage Badho →'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, IconData icon, TextEditingController ctrl, {TextInputType? type}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }

  Widget _buildPermissions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('Permissions Do', style: GoogleFonts.orbitron(
            fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primary,
          )),
          const SizedBox(height: 8),
          Text('App theek se kaam kare iske liye yeh permissions zaroori hain',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          ..._permissions.asMap().entries.map((e) {
            final p = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: p['granted'] ? AppTheme.primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Text(p['icon'], style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['title'], style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                        Text(p['desc'], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  p['granted']
                    ? const Icon(Icons.check_circle, color: AppTheme.primary)
                    : TextButton(
                        onPressed: () async {
                          final status = await (p['permission'] as Permission).request();
                          setState(() => p['granted'] = status.isGranted);
                        },
                        child: const Text('Allow', style: TextStyle(color: AppTheme.primary)),
                      ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _requestAll,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primary),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sab Allow Karo', style: TextStyle(color: AppTheme.primary)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _register,
              child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('Register Karo 🚀'),
            ),
          ),
        ],
      ),
    );
  }
}
