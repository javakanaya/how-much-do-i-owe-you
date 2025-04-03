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

// Add this new provider to fetch any user by ID
@riverpod
Future<UserModel?> userData(Ref ref, String userId) async {
  final repository = ref.read(userRepositoryProvider);

  try {
    return await repository.getUserById(userId);
  } catch (e) {
    // Handle error or return null
    return null;
  }
}

// For development/testing - returns dummy user data
@riverpod
Future<UserModel?> dummyUserData(DummyUserDataRef ref, String userId) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));

  // Return dummy user data based on userId
  switch (userId) {
    case 'user1':
      return UserModel(
        id: 'user1',
        email: 'user1@example.com',
        displayName: 'John Doe',
        photoURL: null,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
        totalPoints: 120,
      );
    case 'user2':
      return UserModel(
        id: 'user2',
        email: 'user2@example.com',
        displayName: 'Jane Smith',
        photoURL: null,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        lastActive: DateTime.now().subtract(const Duration(days: 1)),
        totalPoints: 85,
      );
    case 'user3':
      return UserModel(
        id: 'user3',
        email: 'user3@example.com',
        displayName: 'Michael Johnson',
        photoURL: null,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        lastActive: DateTime.now().subtract(const Duration(minutes: 30)),
        totalPoints: 210,
      );
    case 'user4':
      return UserModel(
        id: 'user4',
        email: 'user4@example.com',
        displayName: 'Emily Brown',
        photoURL: null,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastActive: DateTime.now().subtract(const Duration(hours: 5)),
        totalPoints: 45,
      );
    case 'user5':
      return UserModel(
        id: 'user5',
        email: 'user5@example.com',
        displayName: 'David Wilson',
        photoURL: null,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        lastActive: DateTime.now().subtract(const Duration(days: 3)),
        totalPoints: 150,
      );
    default:
      return UserModel(
        id: userId,
        email: '$userId@example.com',
        displayName: 'User $userId',
        photoURL: null,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        lastActive: DateTime.now(),
        totalPoints: 0,
      );
  }
}
