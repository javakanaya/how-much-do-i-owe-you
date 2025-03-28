import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/repositories/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_provider.g.dart';

@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepository();
}

@riverpod
class CurrentUserData extends _$CurrentUserData {
  @override
  FutureOr<UserModel?> build() async {
    // watch for auth changes
    final authUser = ref.watch(currentUserProvider);
    if (authUser == null) {
      return null;
    }

    return _fetchUserData(authUser.uid);
  }

  // Fetch user data from firestore
  Future<UserModel?> _fetchUserData(String userId) async {
    final repository = ref.read(userRepositoryProvider);

    try {
      // Try to get existing user
      UserModel? user = await repository.getUserById(userId);

      // If user doesn't exist in Firestore yet, create it
      if (user == null) {
        final authUser = ref.read(currentUserProvider);
        if (authUser == null) return null;

        user = UserModel(
          id: authUser.uid,
          email: authUser.email ?? '',
          displayName: authUser.displayName ?? 'User',
          photoURL: authUser.photoURL,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
          totalPoints: 0,
        );

        await repository.createUser(user);
      }

      return user;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    final user = state.valueOrNull;
    if (user == null) return;

    final repository = ref.read(userRepositoryProvider);
    final updatedUser = UserModel(
      id: user.id,
      email: user.email,
      displayName: displayName ?? user.displayName,
      photoURL: photoURL ?? user.photoURL,
      createdAt: user.createdAt,
      lastActive: DateTime.now(),
      totalPoints: user.totalPoints,
    );

    await repository.updateUser(updatedUser);

    // Update auth profile
    final authUser = ref.read(currentUserProvider);
    if (authUser != null && displayName != null) {
      await authUser.updateDisplayName(displayName);
    }

    // Refresh state
    state = AsyncValue.data(updatedUser);
  }
}
