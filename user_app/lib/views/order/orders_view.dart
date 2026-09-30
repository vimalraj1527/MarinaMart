import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/orders_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final OrdersController controller = Get.put(OrdersController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.greyLight),
                const SizedBox(height: 16),
                const Text("No active orders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text("Your previous orders will appear here", style: TextStyle(color: AppColors.grey)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed('/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 3,
                    shadowColor: AppColors.primaryColor.withOpacity(0.35),
                  ),
                  child: const Text("Order Now"),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchOrders(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              return _buildOrderCard(order);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    // FIX: Convert to Local Time for accurate display
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt.toUtc().add(const Duration(hours: 5, minutes: 30)));

    // FIX: If totalAmount is 0 (old orders with wallet deduction), compute from items
    double displayTotal = order.totalAmount;
    if (displayTotal <= 0 && order.items.isNotEmpty) {
      double itemsTotal = 0;
      for (var item in order.items) {
        itemsTotal += (item.price * item.quantity);
      }
      displayTotal = itemsTotal;
    }

    final bool isPaymentPending = order.paymentStatus == 'Payment In Progress';
    final String displayStatus = isPaymentPending ? 'Payment Approval Pending' : order.status;
    final Color statusColor = isPaymentPending ? Colors.amber.shade800 : _getStatusColor(order.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(displayStatus, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          const Divider(height: 24),
          
          // Order Details Expansion
          Theme(
            data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text("View Order Details", style: TextStyle(fontSize: 12, color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
              children: [
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.productName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text("Qty: ${item.quantity} x ₹${item.price}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )).toList(),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text("DELIVERY DETAILS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey)),
                       const SizedBox(height: 4),
                       Row(
                         children: [
                            const Icon(Icons.person_outline, size: 14, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(order.customerName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                         ],
                       ),
                       const SizedBox(height: 4),
                       Row(
                         children: [
                            const Icon(Icons.phone_outlined, size: 14, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(order.customerPhone, style: const TextStyle(fontSize: 12)),
                         ],
                       ),
                    ],
                  ),
                ),
                const Divider(),
              ],
            ),
          ),

          Row(
             children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(order.deliveryAddress, style: const TextStyle(fontSize: 11, color: AppColors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
             ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${order.items.length} Items", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("₹${displayTotal.toStringAsFixed(0)}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primaryColor)),
            ],
          ),
          const SizedBox(height: 8),
          Text(dateStr, style: const TextStyle(fontSize: 10, color: AppColors.grey)),
          const SizedBox(height: 12),
          
          if (order.status == "Delivered")
             _buildActionBtn("REPORT PROBLEM", Colors.red, () => Get.toNamed('/direct-chat', arguments: order.orderNumber) )
          else if (isPaymentPending)
             _buildActionBtn("TRACK PAYMENT APPROVAL", Colors.amber.shade900, () => Get.toNamed('/track-order', arguments: order))
          else
             _buildActionBtn("TRACK ORDER", AppColors.primaryColor, () => Get.toNamed('/track-order', arguments: order)),
        ],
      ),
    );
  }

  Widget _buildActionBtn(String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(border: Border.all(color: color.withOpacity(0.5)), borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12))),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}
