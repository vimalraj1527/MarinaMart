import { useState, useEffect } from 'react';
import { 
  Wallet, 
  Check, 
  X, 
  Clock, 
  IndianRupee, 
  Calendar,
  Search,
  CheckCircle,
  Loader2
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import api from '../services/api';

export default function WalletRequestsPage() {
  const [requests, setRequests] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('All'); // All, Pending, Approved, Rejected

  const fetchRequests = async () => {
    try {
      setLoading(true);
      const response = await api.get('/wallet/request/admin');
      setRequests(response.data);
    } catch (err) {
      console.error('Error fetching wallet requests:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRequests();
  }, []);

  const handleApprove = async (id: string) => {
    try {
      await api.post(`/wallet/request/${id}/approve`);
      // Update local state
      setRequests(prev => prev.map(req => req.id === id ? { ...req, status: 'Approved' } : req));
    } catch (err) {
      console.error('Error approving request:', err);
      alert('Failed to approve request. Please try again.');
    }
  };

  const handleReject = async (id: string) => {
    try {
      await api.post(`/wallet/request/${id}/reject`, { rejectedBy: 'Admin' });
      // Update local state
      setRequests(prev => prev.map(req => req.id === id ? { ...req, status: 'Rejected', rejectedBy: 'Admin' } : req));
    } catch (err) {
      console.error('Error rejecting request:', err);
      alert('Failed to reject request. Please try again.');
    }
  };

  const filteredRequests = requests.filter(req => {
    const matchesSearch = 
      (req.customer?.name || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
      (req.customer?.email || '').toLowerCase().includes(searchTerm.toLowerCase());
    
    if (statusFilter === 'All') return matchesSearch;
    return matchesSearch && req.status === statusFilter;
  });

  // Calculate summary metrics
  const pendingRequests = requests.filter(r => r.status === 'Pending');
  const totalPendingAmount = pendingRequests.reduce((sum, r) => sum + Number(r.amount), 0);
  const totalApprovedAmount = requests.filter(r => r.status === 'Approved').reduce((sum, r) => sum + Number(r.amount), 0);
  const approvedCount = requests.filter(r => r.status === 'Approved').length;

  return (
    <div className="space-y-8 text-slate-900">
      <div>
        <h1 className="text-3xl font-bold text-slate-900 font-outfit text-shadow-sm flex items-center gap-3">
          <Wallet className="w-8 h-8 text-emerald-600 animate-pulse" />
          Wallet Approvals
        </h1>
        <p className="text-slate-500 mt-2 font-medium">Verify and approve customer wallet load requests.</p>
      </div>

      {/* Metrics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white p-6 rounded-[2rem] border border-slate-100 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-1">Pending Amount</p>
            <p className="text-3xl font-black font-outfit text-amber-500">₹{totalPendingAmount.toLocaleString()}</p>
            <p className="text-[10px] text-slate-400 font-bold mt-1 uppercase tracking-tight">{pendingRequests.length} Requests Pending</p>
          </div>
          <div className="p-4 bg-amber-50 rounded-2xl text-amber-500">
            <Clock className="w-6 h-6" />
          </div>
        </div>

        <div className="bg-white p-6 rounded-[2rem] border border-slate-100 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-1">Approved Credits</p>
            <p className="text-3xl font-black font-outfit text-emerald-600">₹{totalApprovedAmount.toLocaleString()}</p>
            <p className="text-[10px] text-slate-400 font-bold mt-1 uppercase tracking-tight">{approvedCount} Requests Approved</p>
          </div>
          <div className="p-4 bg-emerald-50 rounded-2xl text-emerald-600">
            <CheckCircle className="w-6 h-6" />
          </div>
        </div>

        <div className="bg-white p-6 rounded-[2rem] border border-slate-100 shadow-sm flex items-center justify-between">
          <div>
            <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-1">Current Wallet Balance</p>
            <p className="text-3xl font-black font-outfit text-slate-900">Active Pipeline</p>
            <p className="text-[10px] text-slate-400 font-bold mt-1 uppercase tracking-tight">Manual Verification Active</p>
          </div>
          <div className="p-4 bg-slate-50 rounded-2xl text-slate-600">
            <Wallet className="w-6 h-6" />
          </div>
        </div>
      </div>

      {/* Filters & Search */}
      <div className="flex flex-col md:flex-row gap-4 bg-white p-6 rounded-3xl border border-slate-100 shadow-sm justify-between items-center">
        <div className="flex-1 relative group w-full md:w-auto">
          <Search className="absolute left-5 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 group-focus-within:text-emerald-500 transition-colors" />
          <input 
            type="text" 
            placeholder="Search by customer name or email..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-14 pr-7 py-3 bg-slate-50 border border-slate-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-emerald-500 transition-all font-semibold"
          />
        </div>

        <div className="flex gap-2 bg-slate-100 p-1.5 rounded-2xl w-full md:w-auto justify-around">
          {['All', 'Pending', 'Approved', 'Rejected'].map((tab) => (
            <button
              key={tab}
              onClick={() => setStatusFilter(tab)}
              className={`px-5 py-2.5 rounded-xl font-bold text-xs uppercase tracking-wider transition-all ${
                statusFilter === tab 
                  ? 'bg-white text-emerald-600 shadow-sm' 
                  : 'text-slate-500 hover:text-slate-900'
              }`}
            >
              {tab}
            </button>
          ))}
        </div>
      </div>

      {/* Main Table */}
      <div className="bg-white rounded-[2.5rem] border border-slate-100 shadow-sm overflow-hidden overflow-x-auto">
        {loading ? (
          <div className="p-20 flex flex-col items-center justify-center gap-4 text-slate-400">
             <Loader2 className="w-10 h-10 animate-spin text-emerald-500" />
             <p className="font-bold uppercase tracking-widest text-xs">Syncing Transactions...</p>
          </div>
        ) : filteredRequests.length === 0 ? (
          <div className="p-20 text-center text-slate-400">
            <Wallet className="w-16 h-16 mx-auto mb-4 opacity-20" />
            <p className="font-bold text-lg text-slate-800">No requests found</p>
            <p className="text-sm">There are no wallet credit requests matching your filter.</p>
          </div>
        ) : (
          <table className="w-full text-left">
            <thead className="bg-slate-50 border-b border-slate-50">
               <tr>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Customer Details</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Requested Amount</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Requested At</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Status</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400 text-center">Actions</th>
               </tr>
            </thead>
            <tbody className="divide-y divide-slate-50">
              <AnimatePresence mode="popLayout">
                {filteredRequests.map((req) => (
                  <motion.tr 
                    key={req.id} 
                    layout
                    initial={{ opacity: 0 }} 
                    animate={{ opacity: 1 }} 
                    exit={{ opacity: 0 }}
                    className="hover:bg-slate-50/30 transition-all group"
                  >
                    <td className="px-8 py-6">
                      <div className="flex items-center gap-4">
                         <div className="w-10 h-10 bg-slate-100 rounded-xl flex items-center justify-center font-bold text-slate-500">
                           {(req.customer?.name || 'U').charAt(0)}
                         </div>
                         <div>
                           <p className="font-bold text-slate-900 group-hover:text-emerald-700 transition-colors uppercase tracking-tight">{req.customer?.name || 'Unknown User'}</p>
                           <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mt-0.5">{req.customer?.email || 'N/A'}</p>
                         </div>
                      </div>
                    </td>
                    <td className="px-8 py-6">
                      <div className="flex items-center gap-1.5 text-emerald-600 font-outfit">
                        <IndianRupee className="w-3.5 h-3.5 font-bold" />
                        <span className="font-black text-slate-900 text-lg tracking-tighter">{Number(req.amount).toLocaleString()}</span>
                      </div>
                    </td>
                    <td className="px-8 py-6">
                      <div className="flex items-center gap-2 font-semibold text-slate-500 text-sm">
                        <Calendar className="w-4 h-4 text-slate-400" />
                        {new Date(req.createdAt).toLocaleString(undefined, {
                          dateStyle: 'medium',
                          timeStyle: 'short'
                        })}
                      </div>
                    </td>
                    <td className="px-8 py-6">
                      <span className={`px-4 py-1.5 rounded-full text-[10px] font-black uppercase tracking-widest border ${
                        req.status === 'Approved' 
                          ? 'bg-emerald-50 text-emerald-600 border-emerald-100' 
                          : req.status === 'Rejected' 
                          ? 'bg-red-50 text-red-600 border-red-100'
                          : 'bg-amber-50 text-amber-600 border-amber-100 animate-pulse'
                      }`}>
                        {req.status === 'Rejected' && req.rejectedBy 
                          ? `Rejected (by ${req.rejectedBy})` 
                          : req.status}
                      </span>
                    </td>
                    <td className="px-8 py-6">
                      {req.status === 'Pending' ? (
                        <div className="flex justify-center gap-3">
                          <button
                            onClick={() => handleApprove(req.id)}
                            className="flex items-center gap-1.5 px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs rounded-xl shadow-md shadow-emerald-100 transition-all active:scale-95"
                          >
                            <Check className="w-3.5 h-3.5" /> Approve
                          </button>
                          <button
                            onClick={() => handleReject(req.id)}
                            className="flex items-center gap-1.5 px-4 py-2 bg-red-600 hover:bg-red-700 text-white font-bold text-xs rounded-xl shadow-md shadow-red-100 transition-all active:scale-95"
                          >
                            <X className="w-3.5 h-3.5" /> Reject
                          </button>
                        </div>
                      ) : (
                        <p className="text-center text-xs font-bold text-slate-400 italic">
                          Action completed
                        </p>
                      )}
                    </td>
                  </motion.tr>
                ))}
              </AnimatePresence>
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
