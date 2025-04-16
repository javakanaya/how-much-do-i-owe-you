import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:how_much_do_i_owe_you/config/app_theme.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    // In a real app, this would fetch users from a repository
    // For this example, we'll use a mock list
    final mockUsers = [
      UserModel(
        id: 'user1',
        email: 'john@example.com',
        displayName: 'John Doe',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      ),
      UserModel(
        id: 'user2',
        email: 'jane@example.com',
        displayName: 'Jane Smith',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      ),
      UserModel(
        id: 'user3',
        email: 'mike@example.com',
        displayName: 'Mike Johnson',
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      ),
      // Add more mock users as needed
    ];

    // Filter users based on search query
    final filteredUsers =
        _searchController.text.isEmpty
            ? mockUsers
            : mockUsers
                .where(
                  (user) =>
                      user.displayName.toLowerCase().contains(
                        _searchController.text.toLowerCase(),
                      ) ||
                      user.email.toLowerCase().contains(
                        _searchController.text.toLowerCase(),
                      ),
                )
                .toList();

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
                  setState(() {
                    // This will trigger a rebuild with filtered users
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  final isSelected = _selectedUsers.any((u) => u.id == user.id);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryLightColor,
                      child: Text(
                        user.displayName[0].toUpperCase(),
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
                    onPressed: () {
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
