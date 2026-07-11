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
              onPressed: () => ref.read(learnProvider.notifier).reset(),
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
                _ChatBubble(
                  text: 'Hey! The day is almost over. What did you do today?',
                  isUser: false,
                ),
                const SizedBox(height: 12),

                // User response
                if (learnState.chatStep >= 1) ...[
                  _ChatBubble(
                    text:
                        'Took cab to office, used AC 8 hours, ordered food online.',
                    isUser: true,
                  ),
                  const SizedBox(height: 12),
                ],

                // AI challenge
                if (learnState.showChallenge) ...[
                  _ChatBubble(
                    text:
                        'Got it. I\'ve converted that into activities. Entering Challenge Mode! 🎮',
                    isUser: false,
                  ),
                  const SizedBox(height: 24),

                  // Quiz Card
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
                      ),
                      onSubmitted: (_) {
                        ref.read(learnProvider.notifier).sendActivity();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      ref.read(learnProvider.notifier).sendActivity();
                    },
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, LearnState state) {
    final options = [
      {'text': 'A. Metro', 'isCorrect': false},
      {'text': 'B. Walk', 'isCorrect': false},
      {'text': 'C. Bicycle', 'isCorrect': true},
    ];

    return Card(
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
                  'Question 1/3',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'You travelled 4 km by cab. What alternative could have significantly reduced your emissions?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            ...List.generate(options.length, (idx) {
              final opt = options[idx];
              final isCorrect = opt['isCorrect'] as bool;
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
                        : () =>
                            ref.read(learnProvider.notifier).selectOption(idx),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      child: Text(
                        opt['text'] as String,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              );
            }),
            if (state.selectedOption != null) ...[
              const SizedBox(height: 12),
              if (state.selectedOption == 2)
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text('Correct! '),
                    Text(
                      '+20 XP Awarded!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                )
              else
                const Row(
                  children: [
                    Icon(Icons.close, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Incorrect. The correct answer was Bicycle.'),
                  ],
                ),
            ],
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
