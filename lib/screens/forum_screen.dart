import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/forum_service.dart';
import '../services/language_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aureus_background.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isAdmin = false;
  String? _selectedThreadId;
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    _initRole();
  }

  Future<void> _initRole() async {
    final isAdmin = await UserService.instance.isCurrentUserAdmin();
    if (!mounted) return;
    setState(() {
      _isAdmin = isAdmin;
      _loadingRole = false;
      if (!isAdmin) {
        _selectedThreadId = FirebaseAuth.instance.currentUser?.uid;
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    if (_selectedThreadId == null) return;
    final text = _controller.text.trim();
    _controller.clear();
    await ForumService.instance.postMessage(text, threadId: _selectedThreadId!);
  }

  @override
  Widget build(BuildContext context) {
    return AureusBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(LanguageService().getText('forum_de_discussion')),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: _loadingRole
            ? const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor))
            : Column(
          children: [
            if (_isAdmin) _buildAdminThreads(),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _selectedThreadId == null
                    ? null
                    : ForumService.instance.watchMessages(_selectedThreadId!),
                builder: (context, snapshot) {
                  if (_selectedThreadId == null) {
                    return const Center(
                      child: Text(
                        'Selectionnez une discussion utilisateur.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      final isMe = (data['uid'] == currentUserUid);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: isMe ? const EdgeInsets.only(left: 40) : const EdgeInsets.only(right: 40),
                            padding: const EdgeInsets.all(12.0),
                            decoration: AppTheme.glassDecoration(borderRadiusVal: 16).copyWith(
                              color: isMe ? AppTheme.secondaryColor.withValues(alpha: 0.15) : AppTheme.surfaceColor.withValues(alpha: 0.6),
                              border: Border.all(color: isMe ? AppTheme.secondaryColor.withValues(alpha: 0.5) : AppTheme.surfaceColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (data['displayName'] as String?) ?? 'Investisseur',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isMe ? AppTheme.secondaryColor : Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 6.0),
                                if ((data['isAdmin'] as bool?) == true) ...[
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.secondaryColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: const Text(
                                      'ADMIN',
                                      style: TextStyle(
                                        color: AppTheme.secondaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                                Text(
                                  (data['text'] as String?) ?? '',
                                  style: const TextStyle(color: Colors.white, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1, color: AppTheme.surfaceColor),
            
            // Champ de saisie modernisé
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.8),
                border: const Border(top: BorderSide(color: AppTheme.surfaceColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: AppTheme.glassDecoration(borderRadiusVal: 30).copyWith(
                        color: AppTheme.surfaceColor,
                      ),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: LanguageService().getText('messages'),
                          hintStyle: const TextStyle(color: AppTheme.textSecondaryColor),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppTheme.secondaryColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send_rounded, color: AppTheme.primaryColor),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminThreads() {
    return SizedBox(
      height: 110,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ForumService.instance.watchSupportThreads(),
        builder: (context, snapshot) {
          final threads = snapshot.data?.docs ?? const [];
          if (threads.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Aucune conversation active.', style: TextStyle(color: Colors.white60)),
              ),
            );
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemBuilder: (context, index) {
              final data = threads[index].data();
              final threadId = (data['threadId'] as String?) ?? threads[index].id;
              final isSelected = _selectedThreadId == threadId;
              final lastMessage = (data['lastMessage'] as String?) ?? '';
              final userUid = (data['userUid'] as String?) ?? threadId;
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() => _selectedThreadId = threadId),
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(12),
                  decoration: AppTheme.glassDecoration(borderRadiusVal: 14).copyWith(
                    border: Border.all(
                      color: isSelected ? AppTheme.secondaryColor : Colors.white24,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Client: ${userUid.length > 8 ? '${userUid.substring(0, 8)}...' : userUid}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lastMessage,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemCount: threads.length,
          );
        },
      ),
    );
  }
}
