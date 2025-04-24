import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/providers/user_provider.dart';
import 'package:how_much_do_i_owe_you/repositories/user_repository.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_input_field.dart';

class ParticipantSelectionScreen extends ConsumerStatefulWidget {
  const ParticipantSelectionScreen({super.key});

  @override
  ConsumerState<ParticipantSelectionScreen> createState() =>
      _ParticipantSelectionScreenState();
}

class _ParticipantSelectionScreenState extends ConsumerState<ParticipantSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<UserModel> _selectedUsers = [];
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Initial search with empty string to load some users
    _performSearch('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final repository = ref.read(userRepositoryProvider);
      final currentUser = ref.read(currentUserProvider);

      if (currentUser == null) {
        setState(() {
          _errorMessage = 'You must be logged in to search for users';
          _isLoading = false;
        });
        return;
      }

      // Get users from repository (now both empty query and search query are handled by repository)
      final users = await repository.getUsers(query, excludeUserId: currentUser.uid);

      setState(() {
        _searchResults = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error searching users: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleUserSelection(UserModel user) {
    setState(() {
      if (_selectedUsers.any((u) => u.id == user.id)) {
        _selectedUsers.removeWhere((u) => u.id == user.id);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Participants')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomInputField(
                controller: _searchController,
                labelText: 'Search',
                hintText: 'Search by name or email',
                prefixIcon: Icons.search,
                onChanged: (value) {
                  // Debounce search to avoid too many Firestore queries
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (value == _searchController.text) {
                      _performSearch(value);
                    }
                  });
                },
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _searchResults.isEmpty
                      ? const Center(
                        child: Text('No users found. Try a different search term.'),
                      )
                      : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          final isSelected = _selectedUsers.any((u) => u.id == user.id);

                          return ListTile(
                            leading:
                                user.photoURL != null
                                    ? CircleAvatar(
                                      backgroundImage: NetworkImage(user.photoURL!),
                                    )
                                    : CircleAvatar(
                                      backgroundColor: AppTheme.primaryLightColor,
                                      child: Text(
                                        user.displayName.isNotEmpty
                                            ? user.displayName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                            title: Text(user.displayName),
                            subtitle: Text(user.email),
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (_) => _toggleUserSelection(user),
                              activeColor: AppTheme.primaryColor,
                            ),
                            onTap: () => _toggleUserSelection(user),
                          );
                        },
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '${_selectedUsers.length} participants selected',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Add Selected Participants',
                    onPressed:
                        _selectedUsers.isEmpty
                            ? () {}
                            : () {
                              Navigator.pop(context, _selectedUsers);
                            },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
