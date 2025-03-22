// ui/screens/settlement/settlement_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/widgets/cancel_setlement_button.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/widgets/settlement_details_header.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/widgets/settlement_details_transaction_list_card.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/widgets/settlement_details_user_details_card.dart';
import 'package:provider/provider.dart';
import 'package:how_much_do_i_owe_you/models/settlement_model.dart';
import 'package:how_much_do_i_owe_you/models/transaction_model.dart';
import 'package:how_much_do_i_owe_you/models/user_model.dart';
import 'package:how_much_do_i_owe_you/providers/auth_provider.dart';
import 'package:how_much_do_i_owe_you/services/settlement_service.dart';
import 'package:how_much_do_i_owe_you/services/transaction_service.dart';
import 'package:how_much_do_i_owe_you/services/user_service.dart';
import 'package:how_much_do_i_owe_you/ui/screens/settlement/widgets/settlement_error.dart';

class SettlementDetailScreen extends StatefulWidget {
  final String settlementId;

  const SettlementDetailScreen({super.key, required this.settlementId});

  @override
  State<SettlementDetailScreen> createState() => _SettlementDetailScreenState();
}

class _SettlementDetailScreenState extends State<SettlementDetailScreen> {
  final SettlementService _settlementService = SettlementService();
  final TransactionService _transactionService = TransactionService();
  final UserService _userService = UserService();

  bool _isLoading = true;
  String? _errorMessage;
  SettlementModel? _settlement;
  UserModel? _payer;
  UserModel? _receiver;
  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadSettlementDetails();
  }

  Future<void> _loadSettlementDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load settlement
      final settlement = await _settlementService.getSettlementById(
        widget.settlementId,
      );

      if (settlement == null) {
        throw Exception('Settlement not found');
      }

      // Load users
      final payer = await _userService.getUserById(settlement.payerId);
      final receiver = await _userService.getUserById(settlement.receiverId);

      // Load transactions
      final List<TransactionModel> transactions = [];
      for (var transactionId in settlement.transactionIds) {
        final transaction = await _transactionService.getTransactionById(
          transactionId,
        );
        if (transaction != null) {
          transactions.add(transaction);
        }
      }

      setState(() {
        _settlement = settlement;
        _payer = payer;
        _receiver = receiver;
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading settlement details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<AuthProvider>(context).user?.uid;
    final isUserPayer = _settlement?.payerId == currentUserId;
    final isUserReceiver = _settlement?.receiverId == currentUserId;

    // Calculate time difference for cancellation eligibility
    final DateTime now = DateTime.now();
    final bool isRecentSettlement =
        _settlement != null && now.difference(_settlement!.date).inHours < 24;
    final bool canCancel =
        _settlement != null &&
        _settlement!.status != 'canceled' &&
        (isUserPayer || isUserReceiver) &&
        isRecentSettlement;

    return Scaffold(
      appBar: AppBar(title: const Text('Settlement Details')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? SettlementError(
                errorMessage: _errorMessage!,
                onRetry: _loadSettlementDetails,
              )
              : _settlement == null
              ? const Center(child: Text('Settlement not found'))
              : SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Details content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SettlementDetailsHeader(settlement: _settlement!),
                            const SizedBox(height: 24),
                            SettlementDetailsUserDetailsCard(
                              payer: _payer,
                              receiver: _receiver,
                              isUserPayer: isUserPayer,
                            ),
                            const SizedBox(height: 24),
                            SettlementDetailsTransactionsListCard(
                              transactions: _transactions,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Cancel button (only for recent settlements)
                    if (canCancel)
                      CancelSettlementButton(
                        settlementId: widget.settlementId,
                        onCancelled: _loadSettlementDetails,
                      ),
                  ],
                ),
              ),
    );
  }
}
