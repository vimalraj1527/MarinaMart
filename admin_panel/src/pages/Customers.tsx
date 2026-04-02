import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Users, 
  Search, 
  Filter, 
  Loader2,
  Trash2,
  Phone,
  ShoppingBag,
  IndianRupee,
  Eye,
  ChevronRight
} from 'lucide-react';
import { motion } from 'framer-motion';
import api from '../services/api';

export default function CustomersPage() {
  const navigate = useNavigate();
  const [customers, setCustomers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  const fetchCustomers = async () => {
    try {
      setLoading(true);
      const response = await api.get('/users?role=Customer');
      setCustomers(response.data);
    } catch (err) {
      console.error('Error fetching customers:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCustomers();
  }, []);

  const filteredCustomers = customers.filter(c => 
    c.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
    c.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    (c.phone && c.phone.includes(searchTerm))
  );

  return (
    <div className="space-y-8 text-slate-900">
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
        <div>
           <h1 className="text-3xl font-bold text-slate-900 font-outfit text-shadow-sm">Audience Intelligence</h1>
           <p className="text-slate-500 mt-2 font-medium">Analyze customer purchasing patterns and manage account credentials.</p>
        </div>
      </div>

      {/* Modern Search & Filters */}
      <div className="flex flex-col md:flex-row gap-4 bg-white p-6 rounded-3xl border border-slate-100 shadow-sm transition-all focus-within:shadow-xl focus-within:shadow-slate-100">
        <div className="flex-1 relative group">
          <Search className="absolute left-5 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 group-focus-within:text-emerald-500 transition-colors" />
          <input 
            type="text" 
            placeholder="Search by name, email or mobile..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-14 pr-7 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-emerald-500 transition-all font-semibold"
          />
        </div>
        <div className="flex gap-4">
           <button className="px-6 py-4 bg-slate-50 border border-slate-100 rounded-2xl flex items-center gap-3 hover:bg-slate-100 transition-colors">
              <Filter className="w-5 h-5 text-slate-500" />
              <span className="font-bold text-slate-600 font-outfit">Advanced Filters</span>
           </button>
        </div>
      </div>

      <div className="bg-white rounded-[2.5rem] border border-slate-100 shadow-sm overflow-hidden overflow-x-auto">
        {loading ? (
          <div className="p-20 flex flex-col items-center justify-center gap-4 text-slate-400">
             <Loader2 className="w-10 h-10 animate-spin text-emerald-500" />
             <p className="font-bold uppercase tracking-widest text-xs">Syncing Directory...</p>
          </div>
        ) : (
          <table className="w-full text-left">
            <thead className="bg-slate-50 border-b border-slate-50">
               <tr>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Identity & Contact</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Mobile</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400 text-center">Orders</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Total Order Value</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400 text-center">Actions</th>
               </tr>
            </thead>
            <tbody className="divide-y divide-slate-50">
              {filteredCustomers.map((user, idx) => (
                <motion.tr 
                  key={user.id} 
                  initial={{ opacity: 0 }} 
                  animate={{ opacity: 1 }} 
                  onClick={() => navigate(`/customers/${user.id}`)}
                  className="hover:bg-slate-50/50 transition-all group cursor-pointer relative"
                >
                  <td className="px-8 py-6">
                    <div className="flex items-center gap-5">
                       <div className="w-12 h-12 bg-slate-100 rounded-xl flex items-center justify-center font-bold text-slate-400 group-hover:bg-emerald-600 group-hover:text-white transition-all shadow-sm">
                         {user.name.charAt(0)}
                       </div>
                       <div>
                         <p className="font-bold text-slate-900 group-hover:text-emerald-700 transition-colors uppercase tracking-tight">{user.name}</p>
                         <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mt-0.5">{user.email}</p>
                       </div>
                    </div>
                  </td>
                  <td className="px-8 py-6">
                    <div className="flex items-center gap-2 font-outfit">
                      <Phone className="w-3.5 h-3.5 text-slate-400" />
                      <span className="text-sm text-slate-600 font-bold tracking-tighter">{user.phone || 'Not Shared'}</span>
                    </div>
                  </td>
                  <td className="px-8 py-6 text-center">
                    <span className="px-4 py-1.5 bg-blue-50 text-blue-600 text-[10px] font-black rounded-lg uppercase tracking-widest shadow-sm shadow-blue-50">
                       {user.orderCount || 0} Events
                    </span>
                  </td>
                  <td className="px-8 py-6">
                    <div className="flex items-center gap-1.5 text-emerald-600 font-outfit">
                      <IndianRupee className="w-3.5 h-3.5 font-bold" />
                      <span className="font-black text-slate-900 text-lg tracking-tighter">{(user.totalValue || 0).toLocaleString()}</span>
                    </div>
                  </td>
                  <td className="px-8 py-6" onClick={(e) => e.stopPropagation()}>
                    <div className="flex justify-center gap-3">
                       <button 
                         onClick={() => navigate(`/customers/${user.id}`)}
                         className="p-3 bg-white border border-slate-100 hover:bg-emerald-600 hover:text-white text-slate-400 rounded-2xl transition-all shadow-sm group-hover:shadow-lg group-hover:shadow-emerald-100"
                       >
                          <Eye className="w-4 h-4" />
                       </button>
                    </div>
                  </td>
                </motion.tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
