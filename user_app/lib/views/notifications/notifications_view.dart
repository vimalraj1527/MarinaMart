import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../controllers/orders_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/order_model.dart';

class NotificationItem {
  final String title;
  final String message;
  final DateTime time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late OrdersController _ordersController;
  late WalletController _walletController;

  @override
  void initState() {
    super.initState();
    _ordersController = Get.find<OrdersController>();
    _walletController = Get.find<WalletController>();
    
    // Fetch latest data fresh when entering notifications screen
    _ordersController.fetchOrders();
    _walletController.fetchWalletRequests();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.isNegative) return "Just now";
    
    if (difference.inSeconds < 60) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Outfit"),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _ordersController.fetchOrders();
              _walletController.fetchWalletRequests();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_ordersController.isLoading.value || _walletController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          );
        }

        final List<NotificationItem> notifications = [];
        
        // 1. Generate dynamic notifications from live orders
        for (var order in _ordersController.orders) {
          // Placed
          notifications.add(NotificationItem(
            title: "Order Placed",
            message: "Your order #${order.orderNumber} has been placed successfully and is awaiting admin approval.",
            time: order.createdAt.toLocal(),
            icon: Icons.shopping_bag_outlined,
            iconColor: Colors.green.shade700,
            iconBgColor: Colors.green.shade50,
          ));

          // Confirmed (Processing, Out for Delivery, Delivered)
          if (order.status == 'Processing' || order.status == 'Out for Delivery' || order.status == 'Delivered') {
            notifications.add(NotificationItem(
              title: "Order Confirmed",
              message: "Order #${order.orderNumber} has been confirmed by admin and is now being prepared.",
              time: order.createdAt.add(const Duration(seconds: 40)).toLocal(),
              icon: Icons.check_circle_outline,
              iconColor: Colors.teal.shade700,
              iconBgColor: Colors.teal.shade50,
            ));
          }

          // Out for Delivery (Out for Delivery, Delivered)
          if (order.status == 'Out for Delivery' || order.status == 'Delivered') {
            notifications.add(NotificationItem(
              title: "Out for Delivery",
              message: "Order #${order.orderNumber} has been dispatched and is on its way to your address.",
              time: order.createdAt.add(const Duration(minutes: 2)).toLocal(),
              icon: Icons.delivery_dining_outlined,
              iconColor: Colors.indigo.shade700,
              iconBgColor: Colors.indigo.shade50,
            ));
          }

          // Delivered (Delivered)
          if (order.status == 'Delivered') {
            notifications.add(NotificationItem(
              title: "Order Delivered",
              message: "Order #${order.orderNumber} was delivered successfully. Enjoy your groceries!",
              time: order.createdAt.add(const Duration(minutes: 5)).toLocal(),
              icon: Icons.done_all_rounded,
              iconColor: Colors.blue.shade700,
              iconBgColor: Colors.blue.shade50,
            ));
          }

          // Cancelled (Cancelled)
          if (order.status == 'Cancelled') {
            notifications.add(NotificationItem(
              title: "Order Cancelled",
              message: "Order #${order.orderNumber} was cancelled. Wallet balances applied have been returned.",
              time: order.createdAt.toLocal(),
              icon: Icons.cancel_outlined,
              iconColor: Colors.red.shade700,
              iconBgColor: Colors.red.shade50,
            ));
          }
        }

        // 2. Generate notifications from Wallet Money Add requests
        for (var req in _walletController.requests) {
          final reqAmount = double.tryParse(req['amount']?.toString() ?? '0') ?? 0.0;
          final status = (req['status'] ?? '').toString();
          
          DateTime parsedDate;
          try {
            parsedDate = DateTime.parse(req['createdAt'] ?? '').toLocal();
          } catch (_) {
            parsedDate = DateTime.now();
          }

          if (status == 'Pending') {
            notifications.add(NotificationItem(
              title: "Wallet Load Requested",
              message: "Your request to add ₹${reqAmount.toStringAsFixed(2)} to your wallet is pending admin approval.",
              time: parsedDate,
              icon: Icons.account_balance_wallet_outlined,
              iconColor: Colors.orange.shade700,
              iconBgColor: Colors.orange.shade50,
            ));
          } else if (status == 'Approved') {
            DateTime approvedDate;
            try {
              approvedDate = DateTime.parse(req['updatedAt'] ?? req['createdAt'] ?? '').toLocal();
            } catch (_) {
              approvedDate = parsedDate;
            }
            notifications.add(NotificationItem(
              title: "Wallet Credited",
              message: "₹${reqAmount.toStringAsFixed(2)} has been added to your Bloomarina Wallet successfully.",
              time: approvedDate,
              icon: Icons.account_balance_wallet,
              iconColor: Colors.green.shade700,
              iconBgColor: Colors.green.shade50,
            ));
          } else if (status == 'Rejected') {
            DateTime rejectedDate;
            try {
              rejectedDate = DateTime.parse(req['updatedAt'] ?? req['createdAt'] ?? '').toLocal();
            } catch (_) {
              rejectedDate = parsedDate;
            }
            notifications.add(NotificationItem(
              title: "Wallet Request Cancelled",
              message: "Your request to add ₹${reqAmount.toStringAsFixed(2)} to your wallet was cancelled or rejected.",
              time: rejectedDate,
              icon: Icons.cancel_outlined,
              iconColor: Colors.red.shade700,
              iconBgColor: Colors.red.shade50,
            ));
          }
        }

        // Sort notifications: newest first
        notifications.sort((a, b) => b.time.compareTo(a.time));

        if (notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Stay tuned!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Place an order or add money to your wallet to start receiving real-time notifications here.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final item = notifications[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: item.iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.iconColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              _formatTime(item.time),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.message,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12.5,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
