import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  ShoppingBag, 
  MapPin, 
  Truck,
  ChevronRight,
  Loader2,
  Eye,
  CheckCircle2,
  Clock,
  XCircle
} from 'lucide-react';
import { motion } from 'framer-motion';
import { Modal } from '../components/ui/LayoutComponents';
import api from '../services/api';
import { formatToIST } from '../services/dateUtils';

export default function OrdersPage() {
  const navigate = useNavigate();
  const [orders, setOrders] = useState<any[]>([]);
  const [riders, setRiders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [isAssignModalOpen, setIsAssignModalOpen] = useState(false);
  const [selectedOrder, setSelectedOrder] = useState<any>(null);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [ordRes, ridRes] = await Promise.all([
        api.get('/orders'),
        api.get('/riders?status=Available')
      ]);
      setOrders(ordRes.data);
      setRiders(ridRes.data);
    } catch (err) {
      console.error('Error fetching data:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleAssignRider = async (riderId: string) => {
    try {
      await api.patch(`/orders/${selectedOrder.id}/assign/${riderId}`);
      setIsAssignModalOpen(false);
      fetchData();
    } catch (err) {
      console.error('Error assigning rider:', err);
    }
  };

  const handleApprovePayment = async (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    try {
      await api.patch(`/orders/${id}/approve-payment`);
      fetchData();
    } catch (err) {
      console.error('Error approving payment:', err);
    }
  };

  const handleRejectPayment = async (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    if (window.confirm('Reject payment and cancel this order?')) {
      try {
        await api.patch(`/orders/${id}/reject-payment`);
        fetchData();
      } catch (err) {
        console.error('Error rejecting payment:', err);
      }
    }
  };

  const updateOrderStatus = async (id: string, status: string) => {
    try {
      await api.patch(`/orders/${id}/status`, { status });
      fetchData();
    } catch (err) {
      console.error('Error updating status:', err);
    }
  };

  return (
    <div className="space-y-6 sm:space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-2xl sm:text-3xl font-bold text-slate-900 font-outfit">Consignment Tracking</h1>
        <p className="text-xs sm:text-sm text-slate-500 mt-1">Real-time order processing, UPI payment verification & rider dispatch.</p>
      </div>

      {/* Orders Table */}
      <div className="bg-white rounded-[2rem] sm:rounded-[2.5rem] border border-slate-100 shadow-sm overflow-hidden">
        {loading ? (
          <div className="p-16 sm:p-20 flex flex-col items-center justify-center gap-4 text-slate-400">
             <Loader2 className="w-10 h-10 animate-spin text-emerald-500" />
             <p className="font-bold uppercase tracking-widest text-xs">Syncing Live Orders...</p>
          </div>
        ) : orders.length === 0 ? (
          <div className="p-16 sm:p-20 text-center text-slate-400">
             <ShoppingBag className="w-12 h-12 mx-auto mb-4 opacity-20" />
             <p className="font-bold text-sm">No orders recorded yet.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left min-w-[700px]">
              <thead className="bg-slate-50 border-b border-slate-50">
                 <tr>
                   <th className="px-6 sm:px-8 py-5 text-xs font-bold uppercase tracking-wider text-slate-400">Consignment ID</th>
                   <th className="px-6 sm:px-8 py-5 text-xs font-bold uppercase tracking-wider text-slate-400">Customer Details</th>
                   <th className="px-6 sm:px-8 py-5 text-xs font-bold uppercase tracking-wider text-slate-400">Amount & Status</th>
                   <th className="px-6 sm:px-8 py-5 text-xs font-bold uppercase tracking-wider text-slate-400">Dispatch Controls</th>
                   <th className="px-6 sm:px-8 py-5 text-xs font-bold uppercase tracking-wider text-slate-400">Slot Type</th>
                 </tr>
              </thead>
              <tbody className="divide-y divide-slate-50">
                {orders.map((order) => (
                  <motion.tr 
                    key={order.id}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    onClick={() => navigate(`/orders/${order.id}`)}
                    className="hover:bg-slate-50/80 transition-colors group cursor-pointer"
                  >
                    <td className="px-6 sm:px-8 py-5">
                       <div className="flex items-center gap-3">
                          <div className="w-10 h-10 sm:w-12 sm:h-12 bg-emerald-50 text-emerald-600 rounded-2xl flex items-center justify-center font-bold text-xs sm:text-sm flex-shrink-0">
                             #{order.orderNumber?.slice(-4) || 'ORD'}
                          </div>
                          <div>
                             <p className="font-bold text-slate-900 text-xs sm:text-sm">{order.orderNumber}</p>
                             <p className="text-[10px] text-slate-400 font-bold">{formatToIST(order.createdAt)}</p>
                          </div>
                       </div>
                    </td>
                    <td className="px-6 sm:px-8 py-5">
                       <div className="flex flex-col">
                          <span className="font-bold text-slate-900 text-xs sm:text-sm">{order.customerName}</span>
                          <span className="text-[10px] sm:text-xs text-slate-400 font-bold">{order.customerPhone}</span>
                          <span className="text-[10px] text-slate-400 truncate max-w-[180px]">{order.deliveryAddress}</span>
                       </div>
                    </td>
                    <td className="px-6 sm:px-8 py-5">
                       <div className="flex flex-col gap-1.5 items-start">
                          <span className="font-black text-slate-900 text-xs sm:text-sm">₹{order.totalAmount}</span>
                          <span className={`px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-widest ${
                             order.status === 'Delivered' ? 'bg-emerald-100 text-emerald-700' : order.status === 'Processing' ? 'bg-blue-100 text-blue-700' : 'bg-amber-100 text-amber-700'
                          }`}>
                             {order.status}
                          </span>
                          
                          {order.paymentStatus === 'Payment In Progress' ? (
                             <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[9px] sm:text-[10px] font-bold uppercase tracking-wider bg-amber-500 text-white shadow-sm animate-pulse">
                               <Clock className="w-3 h-3 flex-shrink-0" /> Payment In Progress
                             </span>
                          ) : order.paymentStatus === 'Paid' ? (
                             <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[9px] sm:text-[10px] font-bold uppercase tracking-wider bg-emerald-50 text-emerald-700 border border-emerald-200">
                               <CheckCircle2 className="w-3 h-3 text-emerald-600 flex-shrink-0" /> Paid
                             </span>
                          ) : (
                             <span className="px-2.5 py-1 rounded-full text-[9px] sm:text-[10px] font-bold uppercase tracking-wider bg-slate-100 text-slate-600">
                               Payment {order.paymentStatus || 'Pending'}
                             </span>
                          )}
                       </div>
                    </td>
                    <td className="px-6 sm:px-8 py-5" onClick={(e) => e.stopPropagation()}>
                      <div className="flex flex-col gap-2 w-40 sm:w-44">
                          <button 
                            onClick={() => navigate(`/orders/${order.id}`)}
                            className="flex items-center justify-center gap-1.5 px-3 py-2 bg-slate-100 rounded-xl text-[10px] font-bold text-slate-600 hover:bg-emerald-600 hover:text-white transition-all shadow-sm cursor-pointer"
                          >
                             <Eye className="w-3.5 h-3.5" /> View Consignment
                          </button>

                          {order.paymentStatus === 'Payment In Progress' && (
                            <div className="flex flex-col gap-1.5 p-2 bg-amber-50 rounded-xl border border-amber-200">
                               <p className="text-[9px] font-bold text-amber-800 uppercase text-center">UPI Payment Verification</p>
                               <div className="flex items-center gap-1">
                                 <button
                                   onClick={(e) => handleApprovePayment(order.id, e)}
                                   className="flex-1 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white text-[10px] font-bold rounded-lg shadow-sm flex items-center justify-center gap-1 cursor-pointer"
                                 >
                                   <CheckCircle2 className="w-3 h-3" /> Approve
                                 </button>
                                 <button
                                   onClick={(e) => handleRejectPayment(order.id, e)}
                                   className="px-2 py-1.5 bg-rose-100 hover:bg-rose-200 text-rose-700 text-[10px] font-bold rounded-lg cursor-pointer"
                                 >
                                   Reject
                                 </button>
                               </div>
                            </div>
                          )}

                          <select 
                            className="w-full px-3 py-2 bg-slate-50 border-none rounded-xl text-[10px] font-bold text-slate-600 outline-none focus:ring-2 focus:ring-emerald-500 cursor-pointer"
                            value={order.status}
                            onChange={(e) => updateOrderStatus(order.id, e.target.value)}
                          >
                            <option value="Pending">Pending</option>
                            <option value="Processing">Processing</option>
                            <option value="Out for Delivery">Out for Delivery</option>
                            <option value="Delivered">Delivered</option>
                            <option value="Cancelled">Cancelled</option>
                          </select>

                          {order.status === 'Pending' && !order.assignedRider && (
                             <button 
                               onClick={() => { setSelectedOrder(order); setIsAssignModalOpen(true); }}
                               className="px-3 py-2 bg-emerald-600 text-white text-[10px] font-bold rounded-xl shadow-lg shadow-emerald-50 w-full hover:bg-emerald-700 transition-all cursor-pointer"
                             >
                                Assign Rider
                             </button>
                          )}
                          
                          {order.assignedRider && (
                             <div className="flex items-center justify-center gap-1.5 text-[10px] font-bold text-slate-400">
                                <Truck className="w-3 h-3 text-emerald-500 flex-shrink-0" />
                                <span className="truncate">{order.assignedRider.name}</span>
                             </div>
                          )}
                      </div>
                    </td>
                    <td className="px-6 sm:px-8 py-5">
                      <div className="flex flex-col gap-1 items-start">
                         <span className={`px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-widest ${
                            order.deliveryType === 'Scheduled' ? 'bg-amber-100 text-amber-700' : 'bg-rose-100 text-rose-700'
                         }`}>
                            {order.deliveryType || 'Instant'}
                         </span>
                         {order.deliveryType === 'Scheduled' && order.scheduledAt && (
                           <span className="text-[10px] text-slate-500 font-bold tracking-tight mt-1">
                              {formatToIST(order.scheduledAt)}
                           </span>
                         )}
                      </div>
                    </td>
                  </motion.tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* RIDER ASSIGNMENT MODAL */}
      <Modal 
        isOpen={isAssignModalOpen} 
        onClose={() => setIsAssignModalOpen(false)} 
        title="Assign Logistics Courier"
      >
        <div className="space-y-4">
           <p className="text-xs sm:text-sm text-slate-500">Select an available fleet rider for consignment #{selectedOrder?.orderNumber}</p>
           <div className="space-y-2 max-h-60 overflow-y-auto">
              {riders.length > 0 ? riders.map((rider) => (
                 <div 
                   key={rider.id}
                   onClick={() => handleAssignRider(rider.id)}
                   className="p-4 bg-slate-50 hover:bg-emerald-50 hover:border-emerald-200 border border-slate-100 rounded-2xl flex items-center justify-between cursor-pointer transition-all group"
                 >
                    <div className="flex items-center gap-3">
                       <div className="w-10 h-10 bg-emerald-100 text-emerald-600 rounded-xl flex items-center justify-center font-bold text-sm">
                          <Truck className="w-5 h-5" />
                       </div>
                       <div>
                          <p className="font-bold text-slate-900 text-xs sm:text-sm group-hover:text-emerald-700">{rider.name}</p>
                          <p className="text-[10px] text-slate-400">{rider.phone}</p>
                       </div>
                    </div>
                    <span className="text-[10px] font-bold uppercase tracking-widest px-3 py-1 bg-emerald-100 text-emerald-700 rounded-lg">Available</span>
                 </div>
              )) : (
                 <p className="text-center py-6 text-xs text-slate-400">No available riders online at this moment.</p>
              )}
           </div>
        </div>
      </Modal>
    </div>
  );
}
