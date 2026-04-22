import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../services/openai_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aureus_background.dart';

class IaScreen extends StatefulWidget {
  const IaScreen({super.key});

  @override
  State<IaScreen> createState() => _IaScreenState();
}

class _IaScreenState extends State<IaScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text;
      setState(() {
        _messages.add({"role": "user", "content": userMessage});
        _isLoading = true;
      });
      _controller.clear();
      _scrollToBottom();

      try {
        final iaResponse = await OpenAIService.getIaResponse(userMessage);
        setState(() {
          _messages.add({"role": "assistant", "content": iaResponse});
          _isLoading = false;
        });
        _scrollToBottom();
      } catch (e) {
        String errorMessage = "Une erreur est survenue avec Aureus. Veuillez réessayer.";

        if (e.toString().contains('Clé API non configurée')) {
          errorMessage = "⚠️ Clé API non configurée. Veuillez configurer votre clé dans le système.";
        } else if (e.toString().contains('Clé API invalide')) {
          errorMessage = "❌ Service d'expertise indisponible (Clé OpenAI invalide).";
        } else if (e.toString().contains('Limite de requêtes')) {
          errorMessage = "⏰ Mes capacités d'analyse sont temporairement saturées. Veuillez patienter.";
        } else if (e.toString().contains('Erreur de connexion')) {
          errorMessage = "🌐 Communication interrompue. Veuillez vérifier votre connexion au réseau.";
        }

        setState(() {
          _messages.add({"role": "assistant", "content": errorMessage});
          _isLoading = false;
        });
        _scrollToBottom();
        debugPrint('Erreur IA: $e');
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AureusBackground(
      child: Column(
        children: [
          // En-tête de l'Assistant
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 10, left: 16, right: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.5)),
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: AppTheme.secondaryColor, size: 28),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assistant Aureus',
                      style: AppTheme.welcomeTitleStyle.copyWith(fontSize: 22),
                    ),
                    Text(
                      'Conseiller privé en investissement',
                      style: AppTheme.captionStyle.copyWith(color: AppTheme.secondaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Container(height: 1, color: AppTheme.surfaceColor),

          // Liste des messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildLoadingBubble();
                }

                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return _buildMessageBubble(message['content']!, isUser);
              },
            ),
          ),

          // Zone de saisie (TextField)
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final decoration = isUser
        ? AppTheme.glassDecoration(borderRadiusVal: 20).copyWith(
            color: AppTheme.secondaryColor.withValues(alpha: 0.15),
            border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.5)),
          )
        : AppTheme.glassDecoration(borderRadiusVal: 20).copyWith(
            color: AppTheme.surfaceColor.withValues(alpha: 0.6),
          );

    final margin = isUser 
        ? const EdgeInsets.only(left: 60, right: 8, bottom: 16)
        : const EdgeInsets.only(left: 8, right: 40, bottom: 16);

    return Align(
      alignment: alignment,
      child: Container(
        margin: margin,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: decoration,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 8, right: 60, bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: AppTheme.glassDecoration(borderRadiusVal: 20).copyWith(
          color: AppTheme.surfaceColor.withValues(alpha: 0.6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Aureus analyse...',
              style: TextStyle(color: AppTheme.textSecondaryColor, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
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
                  hintText: LanguageService().getText('poser_question_or'),
                  hintStyle: const TextStyle(color: AppTheme.textSecondaryColor),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
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
              onPressed: _isLoading ? null : _sendMessage,
              icon: const Icon(Icons.send_rounded, color: AppTheme.primaryColor),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
