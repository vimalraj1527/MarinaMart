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
  ExternalLink
} from 'lucide-react';
import api from '../services/api';
import { formatToIST, formatToISTTimeOnly } from '../services/dateUtils';

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
      <div className={`flex items-center gap-2 px-4 py-2 rounded-full border ${config.bg} ${config.text} ${config.border} font-bold text-sm`}>
        <Icon className="w-4 h-4" />
        {status}
      </div>
    );
  };

  return (
    <div className="space-y-8 max-w-6xl mx-auto pb-20">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div className="flex items-center gap-4">
          <button 
            onClick={() => navigate('/orders')}
            className="p-4 bg-white border border-slate-100 rounded-2xl hover:bg-slate-50 transition-all text-slate-400 hover:text-slate-900 shadow-sm no-print"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <div className="flex items-center gap-3">
               <h1 className="text-3xl font-black text-slate-900 font-outfit tracking-tight">{order.orderNumber}</h1>
               <StatusBadge status={order.status} />
            </div>
            <p className="text-slate-400 font-bold uppercase tracking-widest text-[10px] mt-1 ml-1">Placed on {formatToIST(order.createdAt)}</p>
          </div>
        </div>
        <div className="flex flex-wrap gap-4 no-print">
           {order.status === 'Pending' && (
             <>
               <button 
                 onClick={() => handleStatusUpdate('Processing')}
                 className="px-6 py-4 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-2xl transition-all shadow-lg shadow-emerald-100/50"
               >
                 Confirm Order
               </button>
               <button 
                 onClick={() => handleStatusUpdate('Cancelled')}
                 className="px-6 py-4 bg-white border border-rose-200 text-rose-600 hover:bg-rose-50 font-bold rounded-2xl transition-all"
               >
                 Cancel Order
               </button>
             </>
           )}
           {order.status === 'Processing' && (
             <button 
               onClick={() => handleStatusUpdate('Out for Delivery')}
               className="px-6 py-4 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-2xl transition-all shadow-lg shadow-indigo-100/50"
             >
               Dispatch Order
             </button>
           )}
           {order.status === 'Out for Delivery' && (
             <button 
               onClick={() => handleStatusUpdate('Delivered')}
               className="px-6 py-4 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-2xl transition-all shadow-lg shadow-emerald-100/50"
             >
               Mark as Delivered
             </button>
           )}
           <button 
             onClick={() => window.print()}
             className="px-6 py-4 bg-slate-900 text-white font-bold rounded-2xl hover:bg-slate-800 transition-all shadow-xl shadow-slate-200"
           >
              Print Invoice
           </button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Left Column: Line Items & Totals */}
        <div className="lg:col-span-2 space-y-8">
           <div className="bg-white rounded-[2.5rem] border border-slate-100 shadow-sm overflow-hidden">
              <div className="px-8 py-6 border-b border-slate-50 flex items-center justify-between">
                 <h2 className="text-lg font-bold text-slate-900 font-outfit">Line Items</h2>
                 <span className="text-xs font-bold text-slate-400 uppercase tracking-widest">{order.items.length} Products</span>
              </div>
              <div className="divide-y divide-slate-50">
                 {order.items.map((item: any, idx: number) => (
                   <div key={idx} className="px-8 py-6 flex items-center justify-between group hover:bg-slate-50/50 transition-colors">
                      <div className="flex items-center gap-5">
                         <div className="w-16 h-16 bg-slate-50 rounded-2xl border border-slate-100 flex items-center justify-center text-slate-400 group-hover:bg-white transition-colors">
                            <Box className="w-6 h-6" />
                         </div>
                         <div>
                            <p className="font-bold text-slate-900">{item.productName || 'Catalog Product'}</p>
                            <p className="text-xs font-bold text-slate-400 uppercase tracking-widest">Qty: {item.quantity} x ₹{item.price}</p>
                         </div>
                      </div>
                      <p className="font-black text-slate-900">₹{(item.price * item.quantity).toFixed(2)}</p>
                   </div>
                 ))}
              </div>
              <div className="bg-slate-50/50 p-8 space-y-4">
                 <div className="flex justify-between text-sm font-bold text-slate-500 px-2">
                    <span>Subtotal</span>
                    <span>₹{(Number(order.totalAmount) + Number(order.walletAmountUsed || 0)).toFixed(2)}</span>
                  </div>
                  <div className="flex justify-between text-sm font-bold text-emerald-500 px-2">
                    <span>Delivery Fee</span>
                    <span>₹0.00</span>
                  </div>
                  {Number(order.walletAmountUsed || 0) > 0 && (
                    <div className="flex justify-between text-sm font-bold text-amber-600 px-2">
                      <span>Wallet Balance Applied</span>
                      <span>-₹{Number(order.walletAmountUsed).toFixed(2)}</span>
                    </div>
                  )}
                  <div className="pt-4 mt-4 border-t border-slate-200 flex justify-between items-center px-2">
                    <span className="text-lg font-bold text-slate-900 font-outfit">Total Payable</span>
                    <span className="text-3xl font-black text-slate-900 font-outfit">₹{Number(order.totalAmount).toFixed(2)}</span>
                  </div>
              </div>
           </div>

           {/* Delivery Details Section */}
           <div className="p-8 bg-slate-900 rounded-[2.5rem] text-white shadow-2xl shadow-slate-200 relative overflow-hidden">
              <div className="absolute top-0 right-0 p-8 opacity-10">
                 <Truck className="w-32 h-32" />
              </div>
              <div className="relative z-10 flex flex-col md:flex-row justify-between gap-8">
                 <div className="space-y-6">
                    <div className="space-y-1">
                       <p className="text-xs font-bold text-emerald-400 uppercase tracking-widest flex items-center gap-2">
                          <MapPin className="w-3 h-3" /> Delivery Destination
                       </p>
                       <p className="text-lg font-bold font-outfit max-w-sm">{order.deliveryAddress}</p>
                    </div>
                    <div className="flex items-center gap-4">
                       <div className="w-12 h-12 bg-white/10 rounded-2xl flex items-center justify-center">
                          <Clock className="w-6 h-6 text-emerald-400" />
                       </div>
                       <div>
                          <p className="text-xs font-bold text-slate-400">Shipment Strategy</p>
                          <p className="font-bold text-lg">{order.deliveryType || 'Instant Delivery'}</p>
                          {order.deliveryType === 'Scheduled' && order.scheduledAt && (
                            <div className="mt-2 space-y-1">
                              <p className="text-[10px] text-emerald-400 font-bold uppercase tracking-widest">
                                Target: {formatToIST(order.scheduledAt)}
                              </p>
                              <div className="inline-flex items-center gap-2 px-3 py-1 bg-emerald-500/10 border border-emerald-500/20 rounded-lg">
                                <Clock className="w-3 h-3 text-emerald-400" />
                                <span className="text-[10px] font-black uppercase tracking-tighter text-emerald-400">
                                  {parseInt(new Date(order.scheduledAt.endsWith('Z') || order.scheduledAt.includes('+') || order.scheduledAt.includes('-') ? order.scheduledAt : order.scheduledAt + 'Z').toLocaleTimeString('en-US', { timeZone: 'Asia/Kolkata', hour: '2-digit', hour12: false })) < 12 ? 'MORNING SLOT (8AM-12PM)' : 'EVENING SLOT (4PM-8PM)'}
                                </span>
                              </div>
                            </div>
                          )}
                          {(!order.deliveryType || order.deliveryType === 'Instant') && (
                            <p className="text-[10px] text-slate-500 font-bold uppercase tracking-widest mt-0.5">Lightning Fast (15-20 mins)</p>
                          )}
                       </div>
                    </div>
                 </div>
                 <div className="bg-white/5 p-6 rounded-3xl border border-white/10 backdrop-blur-md min-w-[280px]">
                    <div className="flex items-center justify-between mb-4">
                       <p className="text-xs font-bold text-slate-400 uppercase tracking-widest">Courier Partner</p>
                       <ExternalLink className="w-3 h-3 text-emerald-400" />
                    </div>
                    {order.assignedRider ? (
                      <div className="flex items-center gap-4">
                         <div className="w-12 h-12 bg-emerald-500 rounded-xl flex items-center justify-center font-bold text-lg">
                           {order.assignedRider.name.charAt(0)}
                         </div>
                         <div>
                            <p className="font-bold">{order.assignedRider.name}</p>
                            <p className="text-[10px] font-bold text-emerald-400 uppercase tracking-widest">Active Partner</p>
                         </div>
                      </div>
                    ) : (
                      <div className="py-2 text-center border-2 border-dashed border-white/10 rounded-2xl">
                         <p className="text-sm font-bold text-slate-500 italic">No Pilot Assigned</p>
                      </div>
                    )}
                 </div>
              </div>
           </div>
        </div>

        {/* Right Column: Customer Info & Timeline */}
        <div className="space-y-8">
           <div className="p-8 bg-white rounded-[2.5rem] border border-slate-100 shadow-sm">
              <h2 className="text-xl font-bold text-slate-900 font-outfit mb-6">Customer Signature</h2>
              <div className="space-y-6">
                 <div className="flex items-center gap-4">
                    <div className="w-12 h-12 bg-slate-50 rounded-2xl flex items-center justify-center text-slate-400">
                       <User className="w-6 h-6" />
                    </div>
                    <div>
                       <p className="text-xs font-bold text-slate-400 uppercase">Name</p>
                       <p className="font-bold text-slate-900 leading-tight">{order.customerName}</p>
                    </div>
                 </div>
                 <div className="flex items-center gap-4">
                    <div className="w-12 h-12 bg-slate-50 rounded-2xl flex items-center justify-center text-slate-400">
                       <Phone className="w-6 h-6" />
                    </div>
                    <div>
                       <p className="text-xs font-bold text-slate-400 uppercase">Phone</p>
                       <p className="font-bold text-slate-900 leading-tight">{order.customerPhone}</p>
                    </div>
                 </div>
                 <div className="flex items-center gap-4">
                    <div className="w-12 h-12 bg-slate-50 rounded-2xl flex items-center justify-center text-slate-400">
                       <CreditCard className="w-6 h-6" />
                    </div>
                    <div>
                       <p className="text-xs font-bold text-slate-400 uppercase underline decoration-emerald-500 decoration-2">Payment Method</p>
                       <p className="font-bold text-slate-900 leading-tight">{order.paymentMethod}</p>
                    </div>
                 </div>
              </div>
              <button 
                onClick={() => navigate('/customers')}
                className="w-full mt-10 py-4 bg-slate-50 text-slate-600 font-bold rounded-2xl hover:bg-emerald-50 hover:text-emerald-600 transition-all text-sm font-outfit border border-slate-100 no-print"
              >
                View Customer Profile
              </button>
           </div>

           <div className="p-8 bg-white rounded-[2.5rem] border border-slate-100 shadow-sm">
              <h2 className="text-xl font-bold text-slate-900 font-outfit mb-8 flex items-center gap-3">
                 <Clock className="w-5 h-5 text-emerald-500" /> Lifecycle
              </h2>
              <div className="space-y-8 relative before:absolute before:left-[11px] before:top-2 before:bottom-0 before:w-0.5 before:bg-slate-100">
                 {[
                   { label: 'Order Confirmed', time: formatToISTTimeOnly(order.createdAt), active: true },
                   { label: 'Merchant Acknowledged', time: 'Syncing...', active: order.status !== 'Pending' },
                   { label: 'Courier Dispatched', time: 'Processing', active: ['Out for Delivery', 'Delivered'].includes(order.status) },
                   { label: 'Consignment Handover', time: '--:--', active: order.status === 'Delivered' }
                 ].map((step, idx) => (
                   <div key={idx} className="flex gap-6 relative">
                      <div className={`w-6 h-6 rounded-full border-4 border-white shadow-sm z-10 ${step.active ? 'bg-emerald-500' : 'bg-slate-200'}`} />
                      <div>
                         <p className={`text-sm font-bold ${step.active ? 'text-slate-900' : 'text-slate-400'}`}>{step.label}</p>
                         <p className="text-[10px] font-bold text-slate-300 uppercase tracking-widest">{step.time}</p>
                      </div>
                   </div>
                 ))}
              </div>
           </div>
        </div>
      </div>
    </div>
  );
}
