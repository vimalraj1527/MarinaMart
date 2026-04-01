import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { 
  Users, 
  Search, 
  Layers, 
  Filter, 
  ShieldCheck, 
  Star, 
  Loader2,
  Trash2
} from 'lucide-react';
import { motion } from 'framer-motion';

const API_BASE_URL = 'http://localhost:5001';

export default function CustomersPage() {
  const [customers, setCustomers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchCustomers = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_BASE_URL}/users?role=Customer`);
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

  return (
    <div className="space-y-8 text-slate-900">
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
        <div>
           <h1 className="text-3xl font-bold text-slate-900 font-outfit">User Accounts</h1>
           <p className="text-slate-500 mt-2">Manage your platform customers and their account status.</p>
        </div>
      </div>

      {/* Modern Search & Filters */}
      <div className="flex flex-col md:flex-row gap-4 bg-white p-6 rounded-3xl border border-slate-100 shadow-sm">
        <div className="flex-1 relative group">
          <Search className="absolute left-5 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 group-focus-within:text-emerald-500 transition-colors" />
          <input 
            type="text" 
            placeholder="Search by name, email or ID..."
            className="w-full pl-14 pr-7 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-emerald-500 transition-all font-semibold"
          />
        </div>
        <div className="flex gap-4">
           <button className="px-6 py-4 bg-slate-50 border border-slate-100 rounded-2xl flex items-center gap-3 hover:bg-slate-100 transition-colors">
              <Filter className="w-5 h-5 text-slate-500" />
              <span className="font-bold text-slate-600 font-outfit">Filters</span>
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
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Customer Identity</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400 font-center">Role Badge</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Status</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400 text-center">Manage</th>
               </tr>
            </thead>
            <tbody className="divide-y divide-slate-50">
              {customers.map((user, idx) => (
                <motion.tr key={user.id} initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="hover:bg-slate-50/50 transition-all group">
                  <td className="px-8 py-6">
                    <div className="flex items-center gap-5">
                       <div className="w-12 h-12 bg-slate-100 rounded-xl flex items-center justify-center font-bold text-slate-400">
                         {user.name.charAt(0)}
                       </div>
                       <div>
                         <p className="font-bold text-slate-900 group-hover:text-emerald-700 transition-colors">{user.name}</p>
                         <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">{user.email}</p>
                       </div>
                    </div>
                  </td>
                  <td className="px-8 py-6">
                    <span className="px-3 py-1.5 bg-indigo-50 text-indigo-600 text-[10px] font-bold uppercase tracking-widest rounded-xl">
                       {user.role}
                    </span>
                  </td>
                  <td className="px-8 py-6">
                    <span className={`px-4 py-2 rounded-full text-[10px] font-bold uppercase tracking-widest ${
                       user.isActive ? 'bg-emerald-100 text-emerald-700' : 'bg-red-100 text-red-700'
                    }`}>
                       {user.isActive ? 'Active Member' : 'Deactivated'}
                    </span>
                  </td>
                  <td className="px-8 py-6">
                    <div className="flex justify-center gap-3">
                       <button className="p-3 bg-white border border-slate-100 hover:bg-slate-50 text-slate-300 hover:text-slate-900 rounded-2xl transition-all shadow-sm">
                          <Trash2 className="w-4 h-4" />
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
