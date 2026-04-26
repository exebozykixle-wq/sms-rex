import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telephony/telephony.dart';
import 'package:sms_rex/theme/app_theme.dart';

class ComposeScreen extends StatefulWidget {
  final bool isGlobal;
  const ComposeScreen({super.key, required this.isGlobal});
  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final _msgCtrl = TextEditingController();
  bool _sending = false;

  final Map<String, bool> _channels = {
    'sms': false,
    'gmail': false,
    'app': true,
    'whatsapp': false,
  };

  final Map<String, Map<String, String>> _channelInfo = {
    'sms': {'icon': '💬', 'label': 'SMS', 'sub': 'SIM se direct bhejo'},
    'gmail': {'icon': '📧', 'label': 'Gmail', 'sub': 'Email notification'},
    'app': {'icon': '🔔', 'label': 'App Notification', 'sub': 'In-app alert'},
    'whatsapp': {'icon': '🟢', 'label': 'WhatsApp', 'sub': 'WhatsApp message'},
  };

  List<String> get _selectedChannels =>
    _channels.entries.where((e) => e.value).map((e) => e.key).toList();

  Future<void> _send() async {
    if (_msgCtrl.text.trim().isEmpty) {
      _showSnack('Message likho!');
      return;
    }
    if (_selectedChannels.isEmpty) {
      _showSnack('Kam se kam ek channel select karo!');
      return;
    }
    setState(() => _sending = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userData = userDoc.data()!;
    final senderName = userData['name'] ?? 'Unknown';

    final msgBody = _msgCtrl.text.trim();
    final List<String> targetPhones = [];

    if (widget.isGlobal) {
      // Get all registered users
      final allUsers = await FirebaseFirestore.instance.collection('users').get();
      for (final u in allUsers.docs) {
        if (u.id != uid) {
          final phone = u.data()['phone'];
          if (phone != null && phone.isNotEmpty) targetPhones.add(phone);
        }
      }
    } else {
      // Get private list
      final privateIds = List<String>.from(userData['privateUsers'] ?? []);
      for (final pid in privateIds) {
        final u = await FirebaseFirestore.instance.collection('users').doc(pid).get();
        if (u.exists) {
          final phone = u.data()?['phone'];
          if (phone != null && phone.isNotEmpty) targetPhones.add(phone);
        }
      }
    }

    // Send via selected channels
    if (_channels['sms'] == true && targetPhones.isNotEmpty) {
      try {
        await sendSMS(
          message: '[$senderName - SMS REX] $msgBody',
          recipients: targetPhones,
          sendDirect: true,
        );
      } catch (_) {}
    }

    // Save to Firestore
    await FirebaseFirestore.instance.collection('messages').add({
      'senderId': uid,
      'senderName': senderName,
      'body': msgBody,
      'type': widget.isGlobal ? 'global' : 'private',
      'channels': _selectedChannels,
      'timestamp': FieldValue.serverTimestamp(),
      'recipients': targetPhones.length,
    });

    setState(() => _sending = false);
    _showSnack('Message bhej diya! ✅');
    Navigator.pop(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: AppTheme.card,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text(
          widget.isGlobal ? '🌍 Global Message' : '🔒 Private Message',
          style: GoogleFonts.exo2(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: widget.isGlobal
                  ? AppTheme.primary.withOpacity(0.15)
                  : Colors.purple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.isGlobal
                  ? '🌍 Sabhi registered users ko jayega'
                  : '🔒 Sirf aapki private list ko jayega',
                style: TextStyle(
                  color: widget.isGlobal ? AppTheme.primary : Colors.purpleAccent,
                  fontSize: 12, fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Message input
            TextField(
              controller: _msgCtrl,
              maxLines: 5,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Yahan message likho...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Channel selector
            Text('Kahan bhejein?', style: GoogleFonts.exo2(
              color: AppTheme.textSecondary, fontSize: 13, letterSpacing: 1,
            )),
            const SizedBox(height: 12),
            ..._channelInfo.entries.map((entry) {
              final key = entry.key;
              final info = entry.value;
              final selected = _channels[key] ?? false;
              return GestureDetector(
                onTap: () => setState(() => _channels[key] = !selected),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primary.withOpacity(0.1) : AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppTheme.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(info['icon']!, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(info['label']!, style: TextStyle(
                              color: selected ? AppTheme.primary : AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            )),
                            Text(info['sub']!, style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12,
                            )),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: selected,
                        onChanged: (v) => setState(() => _channels[key] = v ?? false),
                        activeColor: AppTheme.primary,
                        checkColor: Colors.black,
                        side: const BorderSide(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _send,
                child: _sending
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text(_sending ? 'Bhej raha hoon...' : '🚀 Bhejo',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
