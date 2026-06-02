import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/wallet_controller.dart';

class WalletView extends StatelessWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final WalletController walletController = Get.find<WalletController>();

    // Refresh profile and requests when view opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.refreshUserProfile();
      walletController.fetchWalletRequests();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text(
          "My Wallet",
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black87, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await authController.refreshUserProfile();
          await walletController.fetchWalletRequests();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Wallet Balance Card
              Obx(() {
                final balance = double.tryParse(authController.currentUser['walletBalance']?.toString() ?? '0') ?? 0.0;
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFF3F37C9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C5CE7).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "BALANCE",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white.withOpacity(0.8),
                            size: 28,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "₹${balance.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_outlined, color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text(
                              "100% Secured Digital Transactions",
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Load Wallet & Coupon Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Load Wallet Box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Obx(() {
                        if (walletController.hasPendingRequest) {
                          final pendingReq = walletController.requests.firstWhere(
                            (req) => req['status']?.toString() == 'Pending',
                            orElse: () => null,
                          );
                          final pendingAmount = pendingReq != null
                              ? (double.tryParse(pendingReq['amount']?.toString() ?? '0') ?? 0.0)
                              : 0.0;
                          final pendingId = pendingReq != null ? pendingReq['id']?.toString() ?? '' : '';

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Request Wallet Load",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "You have a pending load request",
                                style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.amber.shade200),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.hourglass_empty_rounded, color: Colors.amber.shade800, size: 24),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Pending Request: ₹${pendingAmount.toStringAsFixed(2)}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.amber.shade900,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                "Only one pending request is allowed. Cancel it to submit a new one.",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 45,
                                      child: OutlinedButton.icon(
                                        onPressed: walletController.isLoading.value
                                            ? null
                                            : () => walletController.cancelRequest(pendingId),
                                        icon: walletController.isLoading.value
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2),
                                              )
                                            : const Icon(Icons.cancel_outlined, size: 18),
                                        label: const Text(
                                          "Cancel Current Request",
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: BorderSide(color: Colors.red.shade200),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Request Wallet Load",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Funds will be added post admin approval",
                              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: walletController.amountController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText: "Enter Amount (₹)",
                                prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFF6C5CE7)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 1.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Preset Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [100, 500, 1000].map((val) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        walletController.amountController.text = val.toString();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        side: BorderSide(color: const Color(0xFF6C5CE7).withOpacity(0.3)),
                                        foregroundColor: const Color(0xFF6C5CE7),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: Text(
                                        "+₹$val",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: walletController.isLoading.value
                                    ? null
                                    : () => walletController.requestAddMoney(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C5CE7),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 2,
                                ),
                                child: walletController.isLoading.value
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text("Submit Request", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    // Redeem Coupon Box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Redeem Wallet Coupon",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Enter admin issued code to credit instant money",
                            style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: walletController.couponController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              labelText: "Coupon Code",
                              prefixIcon: const Icon(Icons.local_offer_outlined, color: Color(0xFF3F37C9)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFF3F37C9), width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(() => SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: walletController.isLoading.value
                                  ? null
                                  : () => walletController.redeemCoupon(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3F37C9),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 2,
                              ),
                              child: walletController.isLoading.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text("Redeem Coupon", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Load Requests History Section
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Wallet Load Requests",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (walletController.isLoading.value && walletController.requests.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (walletController.requests.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Column(
                              children: [
                                Icon(Icons.history_toggle_off_outlined, size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 8),
                                const Text(
                                  "No wallet load requests yet",
                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: walletController.requests.length,
                        separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1),
                        itemBuilder: (context, index) {
                          final req = walletController.requests[index];
                          final amount = double.tryParse(req['amount']?.toString() ?? '0') ?? 0.0;
                          final status = req['status']?.toString() ?? 'Pending';
                          final dateStr = req['createdAt'] != null 
                              ? DateTime.parse(req['createdAt'].toString()).toLocal().toString().substring(0, 16)
                              : '';

                          Color statusColor = Colors.amber;
                          if (status == 'Approved') statusColor = Colors.green;
                          if (status == 'Rejected') statusColor = Colors.red;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "₹${amount.toStringAsFixed(2)} Requested",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateStr,
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    if (status == 'Pending') ...[
                                      TextButton(
                                        onPressed: walletController.isLoading.value
                                            ? null
                                            : () => walletController.cancelRequest(req['id']?.toString() ?? ''),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 11),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status == 'Rejected' && req['rejectedBy'] != null
                                            ? 'Rejected (by ${req['rejectedBy']})'
                                            : status,
                                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
