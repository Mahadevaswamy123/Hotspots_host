import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/experience.dart';
import '../provider/experience_provider.dart';
import '../provider/onboarding_state.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/stamp_tile.dart';
import 'onboarding_question_screen.dart';

class ExperienceSelectionFigmaScreen extends ConsumerWidget {
  const ExperienceSelectionFigmaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncExperiences = ref.watch(experiencesProvider);
    final state = ref.watch(onboardingStateProvider);
    final notifier = ref.read(onboardingStateProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Select experiences you’ve hosted before",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),

            const SizedBox(height: 18),

            // ===== STAMP BAR (Horizontal) =====
            SizedBox(
              height: 65,
              child: asyncExperiences.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(child: Text('No experiences found'));
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final exp = list[i];
                      final selected = state.selectedIds.contains(exp.id);
                      return StampTile(
                        iconUrl: exp.iconUrl ?? '',
                        label: exp.name,
                        selected: selected,
                        onTap: () => notifier.toggleExperience(exp.id),
                        imageUrl: '',
                        title: '',
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text("Error: $e")),
              ),
            ),

            const SizedBox(height: 20),

            // ===== GRID of IMAGE CARDS =====
            Expanded(
              child: asyncExperiences.when(
                data: (list) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    itemCount: list.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.92,
                        ),
                    itemBuilder: (_, i) {
                      final exp = list[i];
                      return _ExperienceCard(
                        exp: exp,
                        selected: state.selectedIds.contains(exp.id),
                        onTap: () => notifier.toggleExperience(exp.id),
                      );
                    },
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text("Error: $e")),
              ),
            ),

            // ===== 250 CHAR NOTE FIELD =====
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: TextField(
                maxLength: 250,
                minLines: 2,
                maxLines: 3,
                onChanged: notifier.updateNote,
                decoration: const InputDecoration(
                  labelText: "Tell us more (optional, max 250 chars)",
                ),
              ),
            ),

            // ===== NEXT BUTTON =====
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: GradientButton(
                label: "Next",
                onPressed:
                    state.selectedIds.isNotEmpty ||
                        state.note250.trim().isNotEmpty
                    ? () {
                        print(
                          "Screen1 state => ${state.selectedIds} | NOTE: ${state.note250}",
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OnboardingQuestionScreen(),
                          ),
                        );
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final Experience exp;
  final bool selected;
  final VoidCallback onTap;

  const _ExperienceCard({
    required this.exp,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.white.withOpacity(0.75) : Colors.white10,
            width: selected ? 2 : 1,
          ),
          color: Colors.white.withOpacity(selected ? 0.14 : 0.06),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColorFiltered(
                  colorFilter: selected
                      ? const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.multiply,
                        )
                      : const ColorFilter.matrix([
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                  child: Image.network(exp.imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),

            // TITLE OVERLAY
            Positioned(
              left: 10,
              right: 10,
              bottom: 12,
              child: Text(
                exp.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),

            // CHECKMARK
            Positioned(
              top: 10,
              right: 10,
              child: AnimatedScale(
                scale: selected ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.check, size: 18, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
