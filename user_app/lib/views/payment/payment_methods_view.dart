import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class PaymentMethodsView extends StatelessWidget {
  const PaymentMethodsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Methods")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPaymentMethod(Icons.credit_card, "Credit/Debit Cards", "Add a new card"),
            _buildPaymentMethod(Icons.payment, "UPI (Google Pay, PhonePe, Paytm)", ""),
            _buildPaymentMethod(Icons.account_balance, "Net Banking", "Secure transactions"),
            _buildPaymentMethod(Icons.wallet, "Wallets", "Add money to wallet"),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 12)) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
        onTap: () {},
      ),
    );
  }
}
