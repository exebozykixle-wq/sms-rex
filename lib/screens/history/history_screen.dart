import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sms_rex/theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text('📜 Message History', style: GoogleFonts.exo2(fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          final docs = snap.data!.docs;
          if (docs.isEmpty) return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('📭', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                Text('Koi message nahi abhi tak', style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          );
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final doc = docs[i];
              final d = doc.data() as Map<String, dynamic>;
              final isGlobal = d['type'] == 'global';
              final senderName = d['senderName'] ?? 'Unknown';
              final body = d['body'] ?? '';
              final channels = (d['channels'] as List?)?.join(', ') ?? '';
              final recipients = d['recipients'] ?? 0;
              final isOwn = d['senderId'] == uid;
              final ts = d['timestamp'] as Timestamp?;
              final timeStr = ts != null
                ? DateFormat('dd MMM, hh:mm a').format(ts.toDate())
                : '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: isOwn
                    ? Border.all(color: AppTheme.primary.withOpacity(0.3), width: 1)
                    : null,
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
                            style: TextStyle(
                              color: isGlobal ? AppTheme.primary : Colors.purpleAccent,
                              fontSize: 11, fontWeight: FontWeight.w700,
                            )),
                        ),
                        const SizedBox(width: 8),
                        if (isOwn)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Mera', style: TextStyle(color: Colors.lightBlue, fontSize: 10)),
                          ),
                        const Spacer(),
                        if (isOwn)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _delete(context, doc.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppTheme.primary.withOpacity(0.2),
                          child: Text(senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                            style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Text(senderName, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        const SizedBox(width: 4),
                        Text('→ $recipients log', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(body, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('📤 $channels', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                        const Spacer(),
                        Text(timeStr, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      ],
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

  Future<void> _delete(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Delete karein?', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Yeh message hamesha ke liye delete ho jayega.', style: TextStyle(color: AppTheme.textSecondary)),
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
