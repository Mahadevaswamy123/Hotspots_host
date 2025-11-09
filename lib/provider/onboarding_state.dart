import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final Set<int> selectedIds;
  final String note250;

  const OnboardingState({this.selectedIds = const {}, this.note250 = ''});

  OnboardingState copyWith({Set<int>? selectedIds, String? note250}) {
    return OnboardingState(
      selectedIds: selectedIds ?? this.selectedIds,
      note250: note250 ?? this.note250,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void toggleExperience(int id) {
    final ids = {...state.selectedIds};
    ids.contains(id) ? ids.remove(id) : ids.add(id);
    state = state.copyWith(selectedIds: ids);
  }

  void updateNote(String text) {
    state = state.copyWith(
      note250: text.length > 250 ? text.substring(0, 250) : text,
    );
  }

  void reset() => state = const OnboardingState();
}

final onboardingStateProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
      (ref) => OnboardingNotifier(),
    );
