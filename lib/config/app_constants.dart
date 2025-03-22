class AppConstants {
  // App info
  static const String appName = 'How Much Do I Owe You?';
  static const String appVersion = '1.0.0';

  // Routes
  static const String loginRoute = '/';
  static const String registerRoute = '/register';
  static const String passwordResetRoute = '/password-reset';
  static const String homeRoute = '/home';
  static const String transactionDetailRoute = '/transaction-detail';
  static const String newTransactionRoute = '/new-transaction';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';

  // Firebase collections
  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';
  static const String participantsCollection = 'participants';
  static const String balancesCollection = 'balances';
  static const String settlementsCollection = 'settlements';

  // Points system
  static const int pointsForNewTransaction = 10;
  static const int pointsForSettlement = 15;
  static const int pointsForAddingFriend = 5;

  // Date formats
  static const String dateFormatDisplay = 'dd MMMM yyyy';
  static const String dateTimeFormatDisplay = 'dd MMM yyyy, hh:mm a';

  // App settings
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 15.0;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Error messages
  static const String defaultErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String authErrorMessage =
      'Authentication failed. Please check your credentials.';

  // Success messages
  static const String transactionAddedMessage =
      'Transaction added successfully!';
  static const String settlementCompletedMessage =
      'Settlement completed successfully!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';
}
