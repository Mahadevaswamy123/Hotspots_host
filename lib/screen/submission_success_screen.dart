import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/media_answer_provider.dart';
import '../provider/onboarding_state.dart';
import '../provider/question_text_provider.dart';

class SubmissionSuccessScreen extends ConsumerWidget {
  const SubmissionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 96,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Submitted Successfully',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your responses have been recorded.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    // ✅ Reset all providers for next flow
                    ref.read(onboardingStateProvider.notifier).reset();
                    ref.read(mediaStateProvider.notifier).reset();
                    ref.read(answerTextProvider.notifier).state = '';

                    // ✅ Go back to very first screen
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text('Back to Start'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
