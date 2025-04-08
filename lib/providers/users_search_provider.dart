import 'package:how_much_do_i_owe_you/models/index.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/providers/user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'users_search_provider.g.dart';

// State for the user search
class UsersSearchState {
  final List<UserModel> searchResults;
  final bool isLoading;
  final String? searchQuery;
  final String? error;

  UsersSearchState({
    this.searchResults = const [],
    this.isLoading = false,
    this.searchQuery,
    this.error,
  });

  UsersSearchState copyWith({
    List<UserModel>? searchResults,
    bool? isLoading,
    String? searchQuery,
    String? error,
  }) {
    return UsersSearchState(
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
    );
  }
}

@riverpod
class UsersSearch extends _$UsersSearch {
  @override
  UsersSearchState build() {
    return UsersSearchState();
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: [], searchQuery: query);
      return;
    }

    state = state.copyWith(isLoading: true, searchQuery: query);

    try {
      final userRepository = ref.read(userRepositoryProvider);
      final results = await userRepository.searchUsers(query);

      // Filter out the current user from the search results
      final currentUser = ref.read(currentUserProvider);
      final filteredResults =
          results.where((user) {
            return user.id != currentUser?.uid;
          }).toList();

      state = state.copyWith(searchResults: filteredResults, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to search users: $e');
    }
  }

  void resetSearch() {
    state = UsersSearchState();
  }
}
