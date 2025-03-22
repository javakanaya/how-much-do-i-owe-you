// ui/screens/transaction/user_search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/services/user_service.dart';
import 'package:how_much_do_i_owe_you/ui/widgets/custom_button.dart';

class UserSearchScreen extends StatefulWidget {
  final List<String> alreadySelectedUserIds;

  const UserSearchScreen({super.key, this.alreadySelectedUserIds = const []});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final _searchController = TextEditingController();
  final _userService = UserService();

  List<UserModel> _searchResults = [];
  Set<String> _selectedUserIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize already selected users
    _selectedUserIds = Set.from(widget.alreadySelectedUserIds);
    // Initial search with empty string to show all users
    _searchUsers('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current user ID to exclude from results
      final currentUserId =
          Provider.of<AuthProvider>(context, listen: false).user?.uid;

      final results = await _userService.searchUsers(query);

      // Filter out current user
      final filteredResults =
          results.where((user) => user.userId != currentUserId).toList();

      setState(() {
        _searchResults = filteredResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error searching users: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
    });
  }

  void _addSelectedUsers() {
    // Get the selected user models from search results
    final selectedUsers =
        _searchResults
            .where((user) => _selectedUserIds.contains(user.userId))
            .toList();

    // Return the selected users to the previous screen
    Navigator.of(context).pop(selectedUsers);
  }

  // Added leading button to navigate back
  Widget _buildLeadingButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add People'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildLeadingButton(),
      ),
      body: Column(
        children: [
          // Search field and results
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or email',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchUsers('');
                                },
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      // Debounce search
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (value == _searchController.text) {
                          _searchUsers(value);
                        }
                      });
                    },
                    autofocus: true,
                  ),

                  const SizedBox(height: 16),

                  // Selected count
                  if (_selectedUserIds.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '${_selectedUserIds.length} ${_selectedUserIds.length == 1 ? 'person' : 'people'} selected',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),

                  // Results or loading indicator
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppTheme.errorColor),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else if (_searchResults.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No users found. Try a different search term.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: _searchResults.length,
                        separatorBuilder:
                            (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          final isSelected = _selectedUserIds.contains(
                            user.userId,
                          );

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor
                                  .withOpacity(0.2),
                              child:
                                  user.photoURL != null
                                      ? CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          user.photoURL!,
                                        ),
                                      )
                                      : Text(
                                        _getInitials(user.displayName),
                                        style: const TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                            title: Text(
                              user.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(user.email),
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged:
                                  (_) => _toggleUserSelection(user.userId),
                              activeColor: AppTheme.primaryColor,
                            ),
                            onTap: () => _toggleUserSelection(user.userId),
                            selected: isSelected,
                            selectedTileColor: AppTheme.primaryColor
                                .withOpacity(0.05),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom button bar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: PrimaryButton(
              text: 'Add Selected',
              onPressed: _selectedUserIds.isEmpty ? () {} : _addSelectedUsers,
              icon: Icons.check,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get initials from name
  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length > 1 && names[1].isNotEmpty) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
