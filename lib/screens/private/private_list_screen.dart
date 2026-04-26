import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms_rex/theme/app_theme.dart';

class PrivateListScreen extends StatefulWidget {
  const PrivateListScreen({super.key});
  @override
  State<PrivateListScreen> createState() => _PrivateListScreenState();
}

class _PrivateListScreenState extends State<PrivateListScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  List<String> _savedIds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _savedIds = List<String>.from(doc.data()?['privateUsers'] ?? []);
      _loading = false;
    });
  }

  Future<void> _toggle(String targetUid) async {
    setState(() {
      if (_savedIds.contains(targetUid)) {
        _savedIds.remove(targetUid);
      } else {
        _savedIds.add(targetUid);
      }
    });
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'privateUsers': _savedIds});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text('🔒 Private List', style: GoogleFonts.exo2(fontWeight: FontWeight.w700)),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
        : StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            final users = snap.data!.docs.where((d) => d.id != uid).toList();
            if (users.isEmpty) return Center(
              child: Text('Abhi koi user registered nahi', style: TextStyle(color: AppTheme.textSecondary)),
            );
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (_, i) {
                final u = users[i].data() as Map<String, dynamic>;
                final id = users[i].id;
                final name = u['name'] ?? 'Unknown';
                final phone = u['phone'] ?? '';
                final online = u['online'] ?? false;
                final showStatus = u['showOnlineStatus'] ?? true;
                final selected = _savedIds.contains(id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primary.withOpacity(0.1) : AppTheme.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppTheme.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppTheme.primary.withOpacity(0.2),
                            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                          ),
                          if (showStatus)
                            Positioned(bottom: 0, right: 0,
                              child: Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(
                                  color: online ? Colors.greenAccent : Colors.grey,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.card, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                            Text(phone, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            if (showStatus)
                              Text(online ? '🟢 Online' : '⚫ Offline',
                                style: TextStyle(color: online ? Colors.greenAccent : AppTheme.textSecondary, fontSize: 11)),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: selected,
                        onChanged: (_) => _toggle(id),
                        activeColor: AppTheme.primary,
                        checkColor: Colors.black,
                        side: const BorderSide(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
    );
  }
}
