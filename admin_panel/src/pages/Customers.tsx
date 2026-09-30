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

  const handleDeleteCustomer = async (id: string, name: string, e: React.MouseEvent) => {
    e.stopPropagation();
    if (window.confirm(`Are you sure you want to permanently delete customer "${name}"? This action cannot be undone.`)) {
      try {
        await api.delete(`/users/${id}`);
        setCustomers(prev => prev.filter(c => c.id !== id));
      } catch (err) {
        console.error('Failed to delete customer:', err);
        alert('Failed to delete customer. Please try again.');
      }
    }
  };

  return (
    <div className="space-y-6 sm:space-y-8 text-slate-900">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
           <h1 className="text-2xl sm:text-3xl font-bold text-slate-900 font-outfit">Audience Intelligence</h1>
           <p className="text-xs sm:text-sm text-slate-500 mt-1">Analyze customer purchasing patterns and manage account credentials.</p>
        </div>
      </div>

      {/* Search */}
      <div className="bg-white p-4 sm:p-6 rounded-3xl border border-slate-100 shadow-sm">
        <div className="relative group">
          <Search className="absolute left-4 sm:left-5 top-1/2 -translate-y-1/2 w-4 h-4 sm:w-5 sm:h-5 text-slate-400 group-focus-within:text-emerald-500 transition-colors" />
          <input 
            type="text" 
            placeholder="Search by name, email or mobile..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-11 sm:pl-14 pr-4 sm:pr-6 py-3 sm:py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:outline-none focus:ring-2 focus:ring-emerald-500 transition-all font-semibold text-xs sm:text-sm text-slate-900"
          />
        </div>
      </div>

      <div className="bg-white rounded-[2rem] sm:rounded-[2.5rem] border border-slate-100 shadow-sm overflow-hidden">
        {loading ? (
          <div className="p-16 sm:p-20 flex flex-col items-center justify-center gap-4 text-slate-400">
             <Loader2 className="w-10 h-10 animate-spin text-emerald-500" />
             <p className="font-bold uppercase tracking-widest text-xs">Syncing Directory...</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left min-w-[650px]">
              <thead className="bg-slate-50 border-b border-slate-50">
                 <tr>
                   <th className="px-6 sm:px-8 py-5 text-xs font-bold uppercase tracking-wider text-slate-400">Identity & Contact</th>
                   <th className="px-6 sm:px-8 py-5 text-xs font-bold uppercase tracking-wider text-slate-400">Mobile</th>
                   <th className="px-6 sm:px-8 py-5 text-xs font-bold uppercase tracking-wider text-slate-400 text-center">Orders</th>
                   <th className="px-6 sm:px-8 py-5 text-xs font-bold uppercase tracking-wider text-slate-400 text-right">Lifetime Spent</th>
                   <th className="px-6 sm:px-8 py-5 text-xs font-bold uppercase tracking-wider text-slate-400 text-center">Actions</th>
                 </tr>
              </thead>
              <tbody className="divide-y divide-slate-50">
                {filteredCustomers.map((customer) => (
                  <tr 
                    key={customer.id}
                    onClick={() => navigate(`/customers/${customer.id}`)}
                    className="hover:bg-slate-50/80 transition-colors cursor-pointer group"
                  >
                    <td className="px-6 sm:px-8 py-5">
                       <div className="flex items-center gap-4">
                          <div className="w-10 h-10 sm:w-12 sm:h-12 bg-emerald-50 text-emerald-600 rounded-2xl flex items-center justify-center font-bold text-xs sm:text-sm font-outfit shadow-sm flex-shrink-0">
                             {customer.name?.charAt(0) || 'U'}
                          </div>
                          <div>
                             <p className="font-bold text-slate-900 text-xs sm:text-sm group-hover:text-emerald-600 transition-colors">{customer.name}</p>
                             <p className="text-[10px] sm:text-xs text-slate-400">{customer.email}</p>
                          </div>
                       </div>
                    </td>
                    <td className="px-6 sm:px-8 py-5">
                       <div className="flex items-center gap-2 text-slate-600 text-xs sm:text-sm font-semibold">
                          <Phone className="w-3.5 h-3.5 text-slate-400 flex-shrink-0" />
                          <span>{customer.phone || 'N/A'}</span>
                       </div>
                    </td>
                    <td className="px-6 sm:px-8 py-5 text-center">
                       <span className="px-3 py-1 bg-emerald-50 text-emerald-600 rounded-full font-bold text-xs">
                          {customer.orderCount || 0} Orders
                       </span>
                    </td>
                    <td className="px-6 sm:px-8 py-5 text-right font-black text-slate-900 text-xs sm:text-sm">
                       ₹{customer.totalSpent?.toFixed(2) || '0.00'}
                    </td>
                    <td className="px-6 sm:px-8 py-5 text-center" onClick={(e) => e.stopPropagation()}>
                       <div className="flex items-center justify-center gap-2">
                          <button 
                             onClick={() => navigate(`/customers/${customer.id}`)}
                             className="p-2.5 bg-slate-50 text-slate-500 rounded-xl hover:bg-emerald-50 hover:text-emerald-600 transition-colors cursor-pointer"
                             title="View Profile"
                          >
                             <Eye className="w-4 h-4" />
                          </button>
                          <button 
                             onClick={(e) => handleDeleteCustomer(customer.id, customer.name, e)}
                             className="p-2.5 bg-slate-50 text-slate-400 rounded-xl hover:bg-red-50 hover:text-red-500 transition-colors cursor-pointer"
                             title="Delete Customer"
                          >
                             <Trash2 className="w-4 h-4" />
                          </button>
                       </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
