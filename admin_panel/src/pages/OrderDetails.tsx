import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { 
  ArrowLeft, 
  MapPin, 
  User, 
  Phone, 
  CreditCard, 
  Box,
  Truck,
  Loader2,
  CheckCircle2,
  Package,
  Clock,
  ExternalLink,
  Printer
} from 'lucide-react';
import api from '../services/api';
import { formatToIST, formatToISTTimeOnly } from '../services/dateUtils';
import { formatImageUrl } from '../services/imageUtils';

export default function OrderDetailsPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [order, setOrder] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  const fetchDetails = async () => {
    try {
      setLoading(true);
      const res = await api.get(`/orders/${id}`);
      setOrder(res.data);
    } catch (err) {
      console.error('Failed to fetch order details:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleStatusUpdate = async (newStatus: string) => {
    try {
      await api.patch(`/orders/${id}/status`, { status: newStatus });
      fetchDetails();
    } catch (err) {
      console.error('Failed to update status:', err);
    }
  };

  const handleApprovePayment = async () => {
    try {
      await api.patch(`/orders/${id}/approve-payment`);
      fetchDetails();
    } catch (err) {
      console.error('Failed to approve payment:', err);
    }
  };

  const handleRejectPayment = async () => {
    if (window.confirm('Reject payment and cancel this order?')) {
      try {
        await api.patch(`/orders/${id}/reject-payment`);
        fetchDetails();
      } catch (err) {
        console.error('Failed to reject payment:', err);
      }
    }
  };

  useEffect(() => {
    fetchDetails();
  }, [id]);

  if (loading) {
    return (
      <div className="h-[70vh] flex flex-col items-center justify-center gap-4 text-slate-400">
        <Loader2 className="w-10 h-10 animate-spin text-emerald-500" />
        <p className="font-bold uppercase tracking-widest text-xs font-outfit">Retrieving Order Payload...</p>
      </div>
    );
  }

  if (!order) return <div className="text-center py-20">Order not found.</div>;

  const StatusBadge = ({ status }: any) => {
    const configs: any = {
      'Pending': { icon: Clock, bg: 'bg-amber-50', text: 'text-amber-600', border: 'border-amber-100' },
      'Processing': { icon: Package, bg: 'bg-blue-50', text: 'text-blue-600', border: 'border-blue-100' },
      'Out for Delivery': { icon: Truck, bg: 'bg-purple-50', text: 'text-purple-600', border: 'border-purple-100' },
      'Delivered': { icon: CheckCircle2, bg: 'bg-emerald-50', text: 'text-emerald-600', border: 'border-emerald-100' },
      'Cancelled': { icon: ArrowLeft, bg: 'bg-red-50', text: 'text-red-500', border: 'border-red-100' }
    };
    const config = configs[status] || configs['Pending'];
    const Icon = config.icon;

    return (
      <div className={`flex items-center gap-2 px-3.5 py-1.5 sm:px-4 sm:py-2 rounded-full border ${config.bg} ${config.text} ${config.border} font-bold text-xs sm:text-sm`}>
        <Icon className="w-4 h-4 flex-shrink-0" />
        <span>{status}</span>
      </div>
    );
  };

  return (
    <div className="space-y-6 sm:space-y-8 max-w-6xl mx-auto">
      {/* Back Button & Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3 sm:gap-4">
          <button 
            onClick={() => navigate('/orders')}
            className="p-3 bg-white hover:bg-slate-50 border border-slate-100 rounded-2xl transition-colors shadow-sm cursor-pointer no-print flex-shrink-0"
          >
            <ArrowLeft className="w-5 h-5 text-slate-600" />
          </button>
          <div>
            <div className="flex items-center gap-2 flex-wrap">
              <h1 className="text-xl sm:text-3xl font-bold text-slate-900 font-outfit">Order #{order.orderNumber}</h1>
              <StatusBadge status={order.status} />
            </div>
            <p className="text-xs sm:text-sm text-slate-500 mt-1">Placed on {formatToIST(order.createdAt)}</p>
          </div>
        </div>

        <div className="flex items-center gap-3 no-print">
          <button 
            onClick={() => window.print()}
            className="flex-1 sm:flex-none flex items-center justify-center gap-2 px-4 py-3 bg-white border border-slate-100 text-slate-700 font-bold rounded-2xl hover:bg-slate-50 transition-all text-xs sm:text-sm shadow-sm cursor-pointer"
          >
             <Printer className="w-4 h-4" />
             <span>Print Receipt</span>
          </button>
          <select 
            className="flex-1 sm:flex-none px-4 py-3 bg-slate-900 text-white font-bold rounded-2xl text-xs sm:text-sm outline-none cursor-pointer"
            value={order.status}
            onChange={(e) => handleStatusUpdate(e.target.value)}
          >
            <option value="Pending">Pending</option>
            <option value="Processing">Processing</option>
            <option value="Out for Delivery">Out for Delivery</option>
            <option value="Delivered">Delivered</option>
            <option value="Cancelled">Cancelled</option>
          </select>
        </div>
      </div>

      {/* UPI Payment Verification Banner */}
      {order.paymentStatus === 'Payment In Progress' && (
        <div className="p-5 sm:p-6 bg-gradient-to-r from-amber-500 to-amber-600 rounded-[2rem] text-white shadow-xl flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <div className="p-3 bg-white/10 rounded-2xl backdrop-blur-md flex-shrink-0">
              <Clock className="w-6 h-6 text-white animate-pulse" />
            </div>
            <div>
              <p className="font-bold text-sm sm:text-base">UPI Payment Approval Pending</p>
              <p className="text-xs text-amber-100 mt-0.5">Verify customer payment in Bank / Admin QR ledger before approving dispatch.</p>
            </div>
          </div>
          <div className="flex items-center gap-3 w-full sm:w-auto">
            <button
              onClick={handleApprovePayment}
              className="flex-1 sm:flex-none px-5 py-3 bg-white text-emerald-700 font-bold rounded-2xl text-xs sm:text-sm shadow-lg hover:bg-emerald-50 transition-all cursor-pointer"
            >
              Approve Payment
            </button>
            <button
              onClick={handleRejectPayment}
              className="px-4 py-3 bg-black/20 hover:bg-black/30 text-white font-bold rounded-2xl text-xs sm:text-sm transition-all cursor-pointer"
            >
              Reject
            </button>
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 sm:gap-8">
        {/* Left Column: Line Items & Totals */}
        <div className="lg:col-span-2 space-y-6 sm:space-y-8">
           <div className="bg-white rounded-[2rem] sm:rounded-[2.5rem] border border-slate-100 shadow-sm overflow-hidden">
              <div className="px-6 sm:px-8 py-5 border-b border-slate-50 flex items-center justify-between">
                 <h2 className="text-base sm:text-lg font-bold text-slate-900 font-outfit">Line Items</h2>
                 <span className="text-xs font-bold text-slate-400 uppercase tracking-widest">{order.items?.length || 0} Products</span>
              </div>
              <div className="divide-y divide-slate-50">
                 {order.items?.map((item: any, idx: number) => {
                   const itemImg = formatImageUrl(item.productImage || item.image);
                   return (
                     <div key={idx} className="px-6 sm:px-8 py-5 flex items-center justify-between gap-4 group hover:bg-slate-50/50 transition-colors">
                        <div className="flex items-center gap-4">
                           <div className="w-12 h-12 sm:w-16 sm:h-16 bg-slate-50 rounded-2xl border border-slate-100 flex items-center justify-center overflow-hidden flex-shrink-0">
                              <img 
                                src={itemImg} 
                                alt={item.productName || 'Product'} 
                                className="w-full h-full object-cover"
                                onError={(e: any) => {
                                  e.target.onerror = null;
                                  e.target.src = 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400';
                                }}
                              />
                           </div>
                           <div>
                              <p className="font-bold text-slate-900 text-xs sm:text-sm">{item.productName || 'Catalog Product'}</p>
                              <p className="text-[10px] sm:text-xs font-bold text-slate-400 uppercase tracking-widest">Qty: {item.quantity} x ₹{item.price}</p>
                           </div>
                        </div>
                        <p className="font-black text-slate-900 text-xs sm:text-sm flex-shrink-0">₹{(item.price * item.quantity).toFixed(2)}</p>
                     </div>
                   );
                 })}
              </div>
              <div className="bg-slate-50/50 p-6 sm:p-8 space-y-3">
                 <div className="flex justify-between text-xs sm:text-sm font-bold text-slate-500 px-2">
                    <span>Subtotal</span>
                    <span>₹{(Number(order.totalAmount) + Number(order.walletAmountUsed || 0)).toFixed(2)}</span>
                  </div>
                  <div className="flex justify-between text-xs sm:text-sm font-bold text-emerald-500 px-2">
                    <span>Delivery Fee</span>
                    <span>Free</span>
                  </div>
                  {order.walletAmountUsed > 0 && (
                    <div className="flex justify-between text-xs sm:text-sm font-bold text-purple-600 px-2">
                      <span>Wallet Deduction</span>
                      <span>-₹{Number(order.walletAmountUsed).toFixed(2)}</span>
                    </div>
                  )}
                  <div className="pt-3 border-t border-slate-200 flex justify-between text-base sm:text-lg font-black text-slate-900 px-2">
                    <span>Total Amount</span>
                    <span className="text-emerald-600">₹{Number(order.totalAmount).toFixed(2)}</span>
                  </div>
              </div>
           </div>

           {/* Delivery Logistics Details */}
           <div className="p-6 sm:p-8 bg-slate-900 rounded-[2rem] sm:rounded-[2.5rem] text-white shadow-xl relative overflow-hidden">
              <div className="relative z-10 flex flex-col sm:flex-row justify-between gap-6 sm:gap-8">
                 <div className="space-y-4">
                    <div className="space-y-1">
                       <p className="text-xs font-bold text-emerald-400 uppercase tracking-widest flex items-center gap-2">
                          <MapPin className="w-3.5 h-3.5" /> Delivery Destination
                       </p>
                       <p className="text-sm sm:text-base font-bold font-outfit max-w-sm leading-relaxed">{order.deliveryAddress}</p>
                    </div>
                    <div className="flex items-center gap-4">
                       <div className="w-10 h-10 sm:w-12 sm:h-12 bg-white/10 rounded-2xl flex items-center justify-center flex-shrink-0">
                          <Clock className="w-5 h-5 sm:w-6 sm:h-6 text-emerald-400" />
                       </div>
                       <div>
                          <p className="text-[10px] sm:text-xs font-bold text-slate-400">Shipment Strategy</p>
                          <p className="font-bold text-sm sm:text-base">{order.deliveryType || 'Instant Delivery'}</p>
                          {order.deliveryType === 'Scheduled' && order.scheduledAt && (
                            <p className="text-[10px] text-emerald-400 font-bold uppercase tracking-widest mt-1">
                              Target: {formatToIST(order.scheduledAt)}
                            </p>
                          )}
                       </div>
                    </div>
                 </div>

                 <div className="bg-white/5 p-5 sm:p-6 rounded-2xl sm:rounded-3xl border border-white/10 backdrop-blur-md min-w-[240px]">
                    <div className="flex items-center justify-between mb-3">
                       <p className="text-[10px] sm:text-xs font-bold text-slate-400 uppercase tracking-widest">Courier Partner</p>
                       <ExternalLink className="w-3 h-3 text-emerald-400" />
                    </div>
                    {order.assignedRider ? (
                      <div className="flex items-center gap-3">
                         <div className="w-10 h-10 bg-emerald-500 rounded-xl flex items-center justify-center font-bold text-base flex-shrink-0">
                           {order.assignedRider.name.charAt(0)}
                         </div>
                         <div>
                            <p className="font-bold text-xs sm:text-sm">{order.assignedRider.name}</p>
                            <p className="text-[10px] font-bold text-emerald-400 uppercase tracking-widest">Active Partner</p>
                         </div>
                      </div>
                    ) : (
                      <div className="py-2 text-center border border-dashed border-white/10 rounded-xl">
                         <p className="text-xs font-bold text-slate-400 italic">No Pilot Assigned</p>
                      </div>
                    )}
                 </div>
              </div>
           </div>
        </div>

        {/* Right Column: Customer Info */}
        <div className="space-y-6 sm:space-y-8">
           <div className="p-6 sm:p-8 bg-white rounded-[2rem] sm:rounded-[2.5rem] border border-slate-100 shadow-sm">
              <h2 className="text-lg font-bold text-slate-900 font-outfit mb-6">Customer Signature</h2>
              <div className="space-y-5 sm:space-y-6">
                 <div className="flex items-center gap-4">
                    <div className="w-10 h-10 sm:w-12 sm:h-12 bg-slate-50 rounded-2xl flex items-center justify-center text-slate-400 flex-shrink-0">
                       <User className="w-5 h-5 sm:w-6 sm:h-6" />
                    </div>
                    <div>
                       <p className="text-[10px] sm:text-xs font-bold text-slate-400 uppercase">Name</p>
                       <p className="font-bold text-slate-900 text-xs sm:text-sm leading-tight">{order.customerName}</p>
                    </div>
                 </div>
                 <div className="flex items-center gap-4">
                    <div className="w-10 h-10 sm:w-12 sm:h-12 bg-slate-50 rounded-2xl flex items-center justify-center text-slate-400 flex-shrink-0">
                       <Phone className="w-5 h-5 sm:w-6 sm:h-6" />
                    </div>
                    <div>
                       <p className="text-[10px] sm:text-xs font-bold text-slate-400 uppercase">Phone</p>
                       <p className="font-bold text-slate-900 text-xs sm:text-sm leading-tight">{order.customerPhone}</p>
                    </div>
                 </div>
                 <div className="flex items-center gap-4">
                    <div className="w-10 h-10 sm:w-12 sm:h-12 bg-slate-50 rounded-2xl flex items-center justify-center text-slate-400 flex-shrink-0">
                       <CreditCard className="w-5 h-5 sm:w-6 sm:h-6" />
                    </div>
                    <div>
                       <p className="text-[10px] sm:text-xs font-bold text-slate-400 uppercase">Payment Method</p>
                       <p className="font-bold text-slate-900 text-xs sm:text-sm leading-tight">{order.paymentMethod || 'UPI Payment'}</p>
                    </div>
                 </div>
              </div>
              <button 
                onClick={() => navigate('/customers')}
                className="w-full mt-8 py-3.5 bg-slate-50 text-slate-600 font-bold rounded-2xl hover:bg-emerald-50 hover:text-emerald-600 transition-all text-xs sm:text-sm font-outfit border border-slate-100 no-print cursor-pointer"
              >
                View Customer Profile
              </button>
           </div>
        </div>
      </div>
    </div>
  );
}
