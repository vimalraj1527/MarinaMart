import { useState, useEffect } from 'react';
import { 
  Gift, 
  Plus, 
  Trash2, 
  IndianRupee, 
  User, 
  Loader2,
  X
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import api from '../services/api';

export default function WalletCouponsPage() {
  const [coupons, setCoupons] = useState<any[]>([]);
  const [customers, setCustomers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  
  // Form State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [code, setCode] = useState('');
  const [amount, setAmount] = useState('');
  const [targetType, setTargetType] = useState('All'); // All, Specific
  const [targetCustomerId, setTargetCustomerId] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [couponsRes, customersRes] = await Promise.all([
        api.get('/wallet/coupon'),
        api.get('/users?role=Customer')
      ]);
      setCoupons(couponsRes.data);
      setCustomers(customersRes.data);
    } catch (err) {
      console.error('Error fetching coupon data:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleDelete = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this coupon?')) return;
    try {
      await api.delete(`/wallet/coupon/${id}`);
      setCoupons(prev => prev.filter(c => c.id !== id));
    } catch (err) {
      console.error('Error deleting coupon:', err);
      alert('Failed to delete coupon.');
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!code || !amount) {
      alert('Please fill out code and amount fields.');
      return;
    }

    try {
      setSubmitting(true);
      const data: any = {
        code: code.toUpperCase().trim(),
        amount: parseFloat(amount),
        targetType
      };

      if (targetType === 'Specific') {
        if (!targetCustomerId) {
          alert('Please select a target customer.');
          setSubmitting(false);
          return;
        }
        data.targetCustomerId = targetCustomerId;
      }

      const res = await api.post('/wallet/coupon', data);
      setCoupons(prev => [res.data, ...prev]);
      
      // Reset Form
      setCode('');
      setAmount('');
      setTargetType('All');
      setTargetCustomerId('');
      setIsModalOpen(false);
    } catch (err: any) {
      console.error('Error creating coupon:', err);
      alert(err.response?.data?.message || 'Failed to create coupon.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="space-y-8 text-slate-900">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold text-slate-900 font-outfit text-shadow-sm flex items-center gap-3">
            <Gift className="w-8 h-8 text-indigo-600 animate-pulse" />
            Wallet Coupons
          </h1>
          <p className="text-slate-500 mt-2 font-medium">Create and manage promo codes for user wallets.</p>
        </div>
        <button
          onClick={() => setIsModalOpen(true)}
          className="flex items-center gap-2 px-6 py-4 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-2xl shadow-lg shadow-indigo-100 transition-all active:scale-95 cursor-pointer font-outfit"
        >
          <Plus className="w-5 h-5" /> Generate Coupon
        </button>
      </div>

      {/* Coupon List */}
      <div className="bg-white rounded-[2.5rem] border border-slate-100 shadow-sm overflow-hidden overflow-x-auto">
        {loading ? (
          <div className="p-20 flex flex-col items-center justify-center gap-4 text-slate-400">
             <Loader2 className="w-10 h-10 animate-spin text-indigo-500" />
             <p className="font-bold uppercase tracking-widest text-xs">Syncing Coupon Book...</p>
          </div>
        ) : coupons.length === 0 ? (
          <div className="p-20 text-center text-slate-400">
            <Gift className="w-16 h-16 mx-auto mb-4 opacity-20" />
            <p className="font-bold text-lg text-slate-800">No coupons active</p>
            <p className="text-sm">Generate a new wallet coupon code to credit money.</p>
          </div>
        ) : (
          <table className="w-full text-left">
            <thead className="bg-slate-50 border-b border-slate-50">
               <tr>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Coupon Code</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Wallet Value</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Applicability</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Target User</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400 text-center">Actions</th>
               </tr>
            </thead>
            <tbody className="divide-y divide-slate-50">
              <AnimatePresence mode="popLayout">
                {coupons.map((c) => (
                  <motion.tr 
                    key={c.id} 
                    layout
                    initial={{ opacity: 0 }} 
                    animate={{ opacity: 1 }} 
                    exit={{ opacity: 0 }}
                    className="hover:bg-slate-50/30 transition-all group"
                  >
                    <td className="px-8 py-6">
                      <div className="flex items-center gap-2">
                         <div className="px-3 py-1.5 bg-indigo-50 text-indigo-700 font-mono font-black rounded-lg border border-indigo-100 uppercase tracking-widest shadow-sm">
                           {c.code}
                         </div>
                      </div>
                    </td>
                    <td className="px-8 py-6">
                      <div className="flex items-center gap-1.5 text-indigo-600 font-outfit">
                        <IndianRupee className="w-3.5 h-3.5 font-bold" />
                        <span className="font-black text-slate-900 text-lg tracking-tighter">{Number(c.amount).toLocaleString()}</span>
                      </div>
                    </td>
                    <td className="px-8 py-6">
                      <span className={`px-4 py-1.5 rounded-full text-[10px] font-black uppercase tracking-widest border ${
                        c.targetType === 'All' 
                          ? 'bg-emerald-50 text-emerald-600 border-emerald-100' 
                          : 'bg-indigo-50 text-indigo-600 border-indigo-100'
                      }`}>
                        {c.targetType === 'All' ? 'All Customers' : 'Specific Customer'}
                      </span>
                    </td>
                    <td className="px-8 py-6">
                      {c.targetType === 'Specific' ? (
                        <div className="flex items-center gap-2">
                          <User className="w-4 h-4 text-slate-400" />
                          <span className="font-bold text-sm text-slate-700">{c.targetCustomer?.name || 'N/A'}</span>
                        </div>
                      ) : (
                        <span className="text-slate-400 font-bold text-xs">Public</span>
                      )}
                    </td>
                    <td className="px-8 py-6 text-center">
                      <button
                        onClick={() => handleDelete(c.id)}
                        className="p-3 bg-white border border-slate-100 hover:bg-red-600 hover:text-white text-slate-400 rounded-2xl transition-all shadow-sm group-hover:shadow-lg active:scale-95"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </motion.tr>
                ))}
              </AnimatePresence>
            </tbody>
          </table>
        )}
      </div>

      {/* Modal Form */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <motion.div 
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="bg-white rounded-[2.5rem] p-8 max-w-lg w-full border border-slate-100 shadow-2xl relative"
          >
            <button 
              onClick={() => setIsModalOpen(false)}
              className="absolute top-6 right-6 p-2 text-slate-400 hover:text-slate-900 rounded-full hover:bg-slate-50 transition-all"
            >
              <X className="w-5 h-5" />
            </button>

            <h3 className="text-xl font-bold font-outfit text-slate-900 mb-2">Create Wallet Coupon</h3>
            <p className="text-sm text-slate-400 mb-6">Enter coupon properties. Users can claim this in their wallet screen.</p>

            <form onSubmit={handleSubmit} className="space-y-5">
              <div>
                <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2">Coupon Code</label>
                <input 
                  type="text" 
                  placeholder="e.g. EXTRA500"
                  value={code}
                  onChange={(e) => setCode(e.target.value.toUpperCase())}
                  className="w-full px-5 py-3.5 bg-slate-50 border border-slate-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-indigo-500 font-mono uppercase tracking-widest font-bold"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2">Wallet Value (₹)</label>
                <input 
                  type="number" 
                  placeholder="e.g. 500"
                  value={amount}
                  onChange={(e) => setAmount(e.target.value)}
                  className="w-full px-5 py-3.5 bg-slate-50 border border-slate-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-indigo-500 font-bold"
                  required
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2">Target Customer Group</label>
                <div className="flex gap-4">
                  <label className="flex-1 flex items-center justify-center gap-2 p-3 border border-slate-100 rounded-2xl cursor-pointer hover:bg-slate-50 transition-all font-bold text-sm text-slate-700">
                    <input 
                      type="radio" 
                      name="targetType" 
                      value="All"
                      checked={targetType === 'All'}
                      onChange={() => setTargetType('All')}
                      className="accent-indigo-600"
                    />
                    All Users
                  </label>
                  <label className="flex-1 flex items-center justify-center gap-2 p-3 border border-slate-100 rounded-2xl cursor-pointer hover:bg-slate-50 transition-all font-bold text-sm text-slate-700">
                    <input 
                      type="radio" 
                      name="targetType" 
                      value="Specific"
                      checked={targetType === 'Specific'}
                      onChange={() => setTargetType('Specific')}
                      className="accent-indigo-600"
                    />
                    Specific User
                  </label>
                </div>
              </div>

              {targetType === 'Specific' && (
                <div>
                  <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2">Choose Customer</label>
                  <select 
                    value={targetCustomerId}
                    onChange={(e) => setTargetCustomerId(e.target.value)}
                    className="w-full px-5 py-3.5 bg-slate-50 border border-slate-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-indigo-500 font-bold"
                    required
                  >
                    <option value="">-- Select Customer --</option>
                    {customers.map(cust => (
                      <option key={cust.id} value={cust.id}>
                        {cust.name} ({cust.email})
                      </option>
                    ))}
                  </select>
                </div>
              )}

              <button
                type="submit"
                disabled={submitting}
                className="w-full py-4 bg-indigo-600 hover:bg-indigo-700 text-white font-bold rounded-2xl shadow-lg shadow-indigo-100 transition-all active:scale-95 flex items-center justify-center gap-2"
              >
                {submitting ? (
                  <Loader2 className="w-5 h-5 animate-spin" />
                ) : (
                  <>Create Coupon</>
                )}
              </button>
            </form>
          </motion.div>
        </div>
      )}
    </div>
  );
}
