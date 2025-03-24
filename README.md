# How Much Do I Owe You?

A Flutter mobile application for tracking shared expenses and settling debts between friends, roommates, and colleagues.

## Overview

"How Much Do I Owe You?" simplifies the process of tracking shared expenses and settling debts. When someone pays for a group expense, the app keeps track of who owes whom, making it easy to settle up later. The app features a clean, intuitive interface designed to make expense tracking hassle-free.

## Features

- **User Authentication**: Secure login and registration with email/password
- **Create Transactions**: Add expenses and split them among friends
- **Track Balances**: See at a glance who owes you money and whom you owe
- **Settle Debts**: Record payments to settle debts
- **Transaction History**: View a history of all shared expenses and settlements

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider

## Demo 



https://github.com/user-attachments/assets/b8691c23-f7ae-42d8-b773-b39631013672


## Project Structure

```txt
lib/
├── config/                # App configuration, constants, themes
├── models/                # Data models for Firebase collections
├── providers/             # State management with Provider
├── services/              # Firebase service classes 
├── ui/                    # UI components
│   ├── screens/           # App screens
│   │   ├── auth/          # Authentication screens
│   │   ├── home/          # Home dashboard
│   │   ├── activity/      # Activity/transaction history
│   │   ├── transaction/   # Transaction creation/details
│   │   ├── settlement/    # Settlement screens
│   │   └── profile/       # User profile
│   └── widgets/           # Reusable widgets
└── main.dart              # App entry point
```

## Firebase Collection Structure

![image](https://github.com/user-attachments/assets/5b430ded-1c67-4fc1-a93b-3ddc87ac4ad6)


## Business Flow

1. **Transaction Creation**
   - A user creates a transaction, paying for something that others will share
   - Each participant is assigned their portion of the total amount
   - The app records who owes money to whom

2. **Viewing Balances**
   - On the home screen, users see their balances with each person
   - Positive balances show money owed to the user (in blue)
   - Negative balances show money the user owes to others (in red)

3. **Settlement Process**
   - When a user wants to pay off their debt:
     1. They tap "Settle Up" on a person's balance card
     2. The app shows all unsettled transactions with that person
     3. The user can select which transactions to include in the settlement
     4. A settlement amount is calculated automatically
     5. The user confirms the settlement

4. **Settlement Confirmation**
   - When a settlement is created:
     1. The transactions are marked as settled
     2. The balance between users is updated
     3. A settlement record is created
     4. Both users get points for completing a settlement

5. **Settlement History**
   - Users can view their settlement history
   - Settlements are grouped by date
   - Each settlement shows who paid whom, the amount, when it occurred, and the status

## Getting Started

### Prerequisites

- Flutter (latest stable version)
- Dart SDK
- Firebase account
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository:

   ```sh
   git clone https://github.com/javakanaya/how-much-do-i-owe-you.git
   ```

2. Navigate to the project directory:

   ```sh
   cd how-much-do-i-owe-you
   ```

3. Install dependencies:

   ```sh
   flutter pub get
   ```

4. Configure Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and add the `google-services.json` and `GoogleService-Info.plist` files
   - Enable Authentication (Email/Password)
   - Create Firestore database with appropriate security rules

5. Run the app:

   ```sh
   flutter run
   ```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Notes  

I made the MVP of this app in 3 days just with Claude
