import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { 
  ArrowLeft,
  Phone,
  Mail,
  ShoppingBag,
  IndianRupee,
  Calendar,
  CreditCard,
  ShieldCheck,
  Ban,
  MessageSquare,
  Loader2,
  Package,
  Cake,
  Wallet
} from 'lucide-react';
import { motion } from 'framer-motion';
import api from '../services/api';
import { formatToISTDateOnly } from '../services/dateUtils';

export default function CustomerDetailsPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [customer, setCustomer] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchCustomer = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await api.get(`/users/${id}`);
      setCustomer(response.data);
    } catch (err: any) {
      console.error('Error fetching customer:', err);
      setError(err.response?.data?.message || 'Failed to load customer profile.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCustomer();
  }, [id]);

  if (loading) {
    return (
      <div className="h-[70vh] flex flex-col items-center justify-center gap-4 text-slate-400">
        <Loader2 className="w-10 h-10 animate-spin text-emerald-500" />
        <p className="font-bold uppercase tracking-widest text-xs font-outfit text-shadow-sm">Analyzing Customer Data...</p>
      </div>
    );
  }

  if (error || !customer) {
    return (
      <div className="h-[70vh] flex flex-col items-center justify-center gap-4 text-slate-400 text-center">
        <ShieldCheck className="w-12 h-12 opacity-20" />
        <h2 className="text-xl font-bold text-slate-900 font-outfit">{error || 'Identity Blocked or Not Found'}</h2>
        <p className="max-w-sm text-sm">We couldn't locate this user account. It may have been archived or the ID is invalid.</p>
        <button 
          onClick={() => navigate('/customers')}
          className="mt-4 px-6 py-3 bg-slate-900 text-white font-bold rounded-2xl hover:bg-slate-800 transition-all text-sm shadow-xl shadow-slate-200"
        >
          Return to Directory
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-8 max-w-7xl mx-auto pb-20">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
        <div className="flex items-center gap-5">
           <button 
             onClick={() => navigate('/customers')}
             className="p-4 bg-white border border-slate-100 rounded-[1.25rem] hover:bg-slate-50 transition-all text-slate-400 hover:text-slate-900 shadow-sm no-print"
           >
             <ArrowLeft className="w-5 h-5" />
           </button>
           <div>
              <div className="flex items-center gap-3">
                 <h1 className="text-3xl font-black text-slate-900 font-outfit tracking-tight">{customer.name}</h1>
                 <span className="px-4 py-1.5 bg-emerald-50 text-emerald-600 text-[10px] font-black uppercase tracking-widest rounded-full border border-emerald-100 shadow-sm shadow-emerald-50">
                    Trusted Member
                 </span>
              </div>
              <p className="text-slate-400 font-bold uppercase tracking-widest text-[10px] mt-1 ml-1 flex items-center gap-2">
                 <ShieldCheck className="w-3 h-3 text-emerald-500" /> Platform UID: {customer.id?.substring(0, 8) || 'N/A'}
              </p>
           </div>
        </div>
        <div className="flex gap-4 no-print">
           <button className="flex items-center gap-2 px-6 py-4 bg-white border border-slate-100 text-slate-600 font-bold rounded-2xl hover:bg-slate-50 transition-all shadow-sm">
              <MessageSquare className="w-4 h-4 text-emerald-500" /> Chat Support
           </button>
           <button className="flex items-center gap-2 px-6 py-4 bg-red-50 text-red-600 font-bold rounded-2xl hover:bg-red-600 hover:text-white transition-all shadow-sm shadow-red-50">
              <Ban className="w-4 h-4" /> Terminate Access
           </button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="space-y-8">
           <div className="bg-white p-8 rounded-[2.5rem] border border-slate-100 shadow-sm">
              <div className="w-24 h-24 bg-emerald-600 rounded-[2rem] mx-auto flex items-center justify-center text-white text-4xl font-black mb-6 shadow-xl shadow-emerald-100">
                 {customer.name?.charAt(0) || '?'}
              </div>
              <div className="space-y-6">
                 <div className="flex items-center gap-4 p-4 bg-slate-50 rounded-3xl border border-slate-100">
                    <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center text-slate-400">
                       <Mail className="w-5 h-5 text-emerald-500" />
                    </div>
                    <div className="min-w-0">
                       <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest leading-loose">Email Sync</p>
                       <p className="font-bold text-slate-900 truncate tracking-tight">{customer.email || 'None'}</p>
                    </div>
                 </div>
                 <div className="flex items-center gap-4 p-4 bg-slate-50 rounded-3xl border border-slate-100">
                    <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center text-slate-400">
                       <Phone className="w-5 h-5 text-emerald-500" />
                    </div>
                    <div>
                       <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest leading-loose">Mobile Contact</p>
                       <p className="font-bold text-slate-900 tracking-tight">{customer.phone || 'Not Linked'}</p>
                    </div>
                 </div>
                 <div className="flex items-center gap-4 p-4 bg-slate-50 rounded-3xl border border-slate-100">
                    <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center text-slate-400">
                       <Wallet className="w-5 h-5 text-emerald-500" />
                    </div>
                    <div>
                       <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest leading-loose">Wallet Balance</p>
                       <p className="font-bold text-slate-900 tracking-tight">₹{Number(customer.walletBalance || 0).toLocaleString()}</p>
                    </div>
                 </div>
                 <div className="flex items-center gap-4 p-4 bg-slate-50 rounded-3xl border border-slate-100">
                    <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center text-slate-400">
                       <Cake className="w-5 h-5 text-emerald-500" />
                    </div>
                    <div>
                       <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest leading-loose">Birthday Details</p>
                       <p className="font-bold text-slate-900 tracking-tight">
                         {customer.birthday 
                           ? formatToISTDateOnly(customer.birthday) 
                           : 'Not Provided'}
                       </p>
                    </div>
                 </div>
                 <div className="flex items-center gap-4 p-4 bg-slate-50 rounded-3xl border border-slate-100">
                    <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center text-slate-400">
                       <Calendar className="w-5 h-5 text-emerald-500" />
                    </div>
                    <div>
                       <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest leading-loose">Onboarded Since</p>
                       <p className="font-bold text-slate-900 tracking-tight">{customer.createdAt ? formatToISTDateOnly(customer.createdAt, { month: 'long', year: 'numeric' }) : 'Unknown'}</p>
                    </div>
                 </div>
              </div>
           </div>

           <div className="p-8 bg-slate-900 rounded-[2.5rem] text-white shadow-2xl shadow-slate-200 overflow-hidden relative group">
              <div className="absolute top-0 right-0 p-8 opacity-5 group-hover:scale-110 transition-transform duration-500">
                 <ShoppingBag className="w-40 h-40" />
              </div>
              <h3 className="text-lg font-bold font-outfit mb-6 relative z-10 text-shadow-sm uppercase tracking-tight">Intelligence Dashboard</h3>
              <div className="space-y-6 relative z-10">
                 <div className="flex items-end justify-between">
                    <div>
                       <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-1">Total Orders</p>
                       <p className="text-4xl font-black font-outfit">{customer.orderCount || 0}</p>
                    </div>
                    <div className="p-3 bg-white/10 rounded-2xl">
                       <ShoppingBag className="w-6 h-6 text-emerald-400" />
                    </div>
                 </div>
                 <div className="h-2 bg-white/5 rounded-full overflow-hidden border border-white/5">
                    <motion.div 
                      initial={{ width: 0 }}
                      animate={{ width: customer.orderCount > 0 ? '65%' : '0%' }}
                      className="h-full bg-emerald-500 shadow-[0_0_10px_rgba(16,185,129,0.5)]"
                    />
                 </div>
                 <div className="flex items-end justify-between pt-4 border-t border-white/5">
                    <div>
                       <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-1 underline decoration-emerald-500 decoration-2">Total Order Value</p>
                       <p className="text-4xl font-black font-outfit text-white">₹{(customer.totalValue || 0).toLocaleString()}</p>
                    </div>
                    <div className="p-3 bg-white/10 rounded-2xl ring-1 ring-white/10">
                       <IndianRupee className="w-6 h-6 text-emerald-400" />
                    </div>
                 </div>
              </div>
           </div>
        </div>

        <div className="lg:col-span-2 space-y-8">
           <div className="bg-white rounded-[2.5rem] border border-slate-100 shadow-sm overflow-hidden">
              <div className="px-8 py-6 border-b border-slate-50 flex items-center justify-between bg-slate-50/20">
                 <div>
                    <h2 className="text-lg font-bold text-slate-900 font-outfit uppercase tracking-tighter">Timeline of Commerce</h2>
                    <p className="text-xs text-slate-400 font-bold uppercase mt-1 tracking-widest font-inter">Transaction History Summary</p>
                 </div>
                 <span className="px-4 py-2 bg-white border border-slate-100 rounded-2xl text-[10px] font-black text-slate-400 uppercase tracking-widest shadow-sm">
                    {customer.orderCount || 0} Transactions Found
                 </span>
              </div>
              <div className="divide-y divide-slate-50">
                 {customer.orders?.length > 0 ? customer.orders.map((order: any) => (
                    <motion.div 
                      key={order.id} 
                      whileHover={{ x: 10, backgroundColor: 'rgba(248, 250, 252, 0.8)' }}
                      onClick={() => navigate(`/orders/${order.id}`)}
                      className="px-8 py-6 group cursor-pointer transition-all flex items-center justify-between"
                    >
                       <div className="flex items-center gap-6">
                          <div className="w-14 h-14 bg-slate-50 border border-slate-100 rounded-2xl flex items-center justify-center text-slate-300 group-hover:bg-emerald-600 group-hover:text-white transition-all shadow-sm group-hover:shadow-lg group-hover:shadow-emerald-100">
                             <Package className="w-6 h-6" />
                          </div>
                          <div>
                             <p className="font-black text-slate-900 text-lg uppercase tracking-tight group-hover:text-emerald-700 transition-colors">{order.orderNumber}</p>
                             <div className="flex items-center gap-3 mt-1">
                                <div className="flex items-center gap-1.5 text-[10px] font-bold text-slate-400 uppercase tracking-widest">
                                   <Calendar className="w-3 h-3 text-emerald-500" /> {formatToISTDateOnly(order.createdAt)}
                                </div>
                                <div className="flex items-center gap-1.5 text-[10px] font-bold text-slate-400 uppercase tracking-widest">
                                   <CreditCard className="w-3 h-3 text-emerald-500" /> {order.paymentMethod}
                                </div>
                             </div>
                          </div>
                       </div>
                       <div className="flex flex-col items-end gap-3">
                          <span className={`px-4 py-1.5 rounded-full text-[10px] font-bold uppercase tracking-widest border ${
                             order.status === 'Delivered' ? 'bg-emerald-50 text-emerald-600 border-emerald-100 shadow-sm shadow-emerald-50' : 'bg-blue-50 text-blue-600 border-blue-100 shadow-sm shadow-blue-50'
                          }`}>
                             {order.status}
                          </span>
                          <p className="text-xl font-black text-slate-900 font-outfit group-hover:text-emerald-600 transition-colors tracking-tighter">
                             ₹{Number(order.totalAmount).toLocaleString()}
                          </p>
                       </div>
                    </motion.div>
                 )) : (
                    <div className="p-24 text-center text-slate-400 bg-slate-50/10">
                       <ShoppingBag className="w-20 h-20 mx-auto mb-6 opacity-5" />
                       <p className="font-black text-slate-900 font-outfit text-xl uppercase tracking-tighter">Zero Operational Footprint</p>
                       <p className="text-[10px] uppercase font-bold tracking-widest mt-2 max-w-xs mx-auto text-slate-400 leading-relaxed">This identity has not participated in any transactional checkout events on the platform yet.</p>
                    </div>
                 )}
              </div>
           </div>
        </div>
      </div>
    </div>
  );
}
