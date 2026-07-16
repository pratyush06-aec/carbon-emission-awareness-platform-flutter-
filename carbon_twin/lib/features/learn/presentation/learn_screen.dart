import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/learn_provider.dart';

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _inputController.text;
    if (text.trim().isNotEmpty) {
      ref.read(learnProvider.notifier).sendActivity(text);
      _inputController.clear();
      // Unfocus keyboard
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final learnState = ref.watch(learnProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Check-in'),
        centerTitle: true,
        actions: [
          if (learnState.chatStep > 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _inputController.clear();
                ref.read(learnProvider.notifier).reset();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // AI greeting
                const _ChatBubble(
                  text: 'Hey! The day is almost over. What did you do today?',
                  isUser: false,
                ),
                const SizedBox(height: 12),

                // User response
                if (learnState.chatStep >= 1) ...[
                  _ChatBubble(
                    text: learnState.userActivityInput,
                    isUser: true,
                  ),
                  const SizedBox(height: 12),
                ],

                // Loading Indicator (Typing effect)
                if (learnState.isLoading) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text('Carbon Twin is thinking...', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Error message
                if (learnState.error != null) ...[
                  Center(
                    child: Text(
                      learnState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // AI challenge / Analysis
                if (learnState.chatStep == 2 && learnState.questions.isNotEmpty) ...[
                  _ChatBubble(
                    text: learnState.analysisMessage,
                    isUser: false,
                  ),
                  const SizedBox(height: 24),

                  // Quiz Card or Completion Message
                  if (learnState.challengeComplete)
                    _buildCompletionCard(context, learnState)
                  else
                    _buildQuizCard(context, learnState),
                ],
              ],
            ),
          ),

          // Chat Input
          if (learnState.chatStep == 0)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(
                        hintText: 'Type your activities...',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        )
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: _handleSend,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, LearnState state) {
    final currentQ = state.questions[state.currentQuestionIndex];
    final options = currentQ.options;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '⚡ Challenge Mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Question ${state.currentQuestionIndex + 1}/${state.questions.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              currentQ.questionText,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            
            // Options list
            ...List.generate(options.length, (idx) {
              final isCorrect = currentQ.correctAnswerIndex == idx;
              final isSelected = state.selectedOption == idx;
              final hasAnswered = state.selectedOption != null;

              Color? cardColor;
              if (hasAnswered) {
                if (isSelected && isCorrect) {
                  cardColor = Colors.green.withOpacity(0.2);
                } else if (isSelected && !isCorrect) {
                  cardColor = Colors.red.withOpacity(0.2);
                } else if (isCorrect) {
                  cardColor = Colors.green.withOpacity(0.1);
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: cardColor ?? Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: hasAnswered
                        ? null
                        : () => ref.read(learnProvider.notifier).selectOption(idx),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      child: Text(
                        options[idx],
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              );
            }),
            
            // Explanation
            if (state.selectedOption != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: state.selectedOption == currentQ.correctAnswerIndex 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      state.selectedOption == currentQ.correctAnswerIndex ? Icons.check_circle : Icons.info,
                      color: state.selectedOption == currentQ.correctAnswerIndex ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(currentQ.explanation),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('Next question loading...', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey)),
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard(BuildContext context, LearnState state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.stars, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Challenge Complete!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You successfully completed today\'s Gemini challenge!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            if (state.isAwarding)
              const CircularProgressIndicator()
            else
              Text(
                '+${state.xpEarned} XP Awarded',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text),
      ),
    );
  }
}
