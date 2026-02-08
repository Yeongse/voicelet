import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/search_api_service.dart';

part 'username_check_provider.g.dart';

enum UsernameAvailability {
  unknown,
  checking,
  available,
  unavailable,
  invalid,
}

@riverpod
class UsernameCheck extends _$UsernameCheck {
  @override
  UsernameAvailability build() => UsernameAvailability.unknown;

  Future<void> check(String username) async {
    if (username.isEmpty) {
      state = UsernameAvailability.unknown;
      return;
    }

    if (username.length < 3) {
      state = UsernameAvailability.invalid;
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(username)) {
      state = UsernameAvailability.invalid;
      return;
    }

    state = UsernameAvailability.checking;

    try {
      final searchService = SearchApiService();
      final available = await searchService.checkUsernameAvailability(username);
      state = available
          ? UsernameAvailability.available
          : UsernameAvailability.unavailable;
    } catch (e) {
      state = UsernameAvailability.unknown;
    }
  }

  void reset() {
    state = UsernameAvailability.unknown;
  }
}
