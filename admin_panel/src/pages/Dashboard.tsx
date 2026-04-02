import { useState, useEffect } from 'react';
import { 
  ShoppingBag, 
  Users, 
  TrendingUp, 
  Package, 
  MapPin,
  Loader2,
  ChevronRight
} from 'lucide-react';
import { 
  LineChart, 
  Line, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer 
} from 'recharts';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import api from '../services/api';

const StatCard = ({ title, value, icon: Icon, trend, onClick }: any) => (
  <motion.div 
    onClick={onClick}
    initial={{ opacity: 0, y: 20 }}
    whileInView={{ opacity: 1, y: 0 }}
    whileHover={{ y: -5, scale: 1.01 }}
    className="p-6 bg-white rounded-3xl border border-slate-100 shadow-sm hover:shadow-xl hover:shadow-emerald-500/5 transition-all cursor-pointer group"
  >
    <div className="flex items-center justify-between">
      <div className="p-3 bg-emerald-50 rounded-2xl group-hover:bg-emerald-600 group-hover:text-white transition-colors">
        <Icon className="w-6 h-6 text-emerald-600 group-hover:text-white" />
      </div>
      <span className={`text-sm font-medium ${trend.startsWith('+') ? 'text-emerald-500' : 'text-red-500'}`}>
        {trend}
      </span>
    </div>
    <div className="mt-4">
      <h3 className="text-sm font-medium text-slate-500">{title}</h3>
      <p className="text-2xl font-bold text-slate-900 mt-1">{value}</p>
    </div>
  </motion.div>
);

export default function Dashboard() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  const fetchStats = async () => {
    try {
      setLoading(true);
      const response = await api.get('/dashboard/stats');
      setData(response.data);
    } catch (err) {
      console.error('Failed to fetch dashboard stats:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchStats();
  }, []);

  if (loading) {
    return (
      <div className="h-[60vh] flex flex-col items-center justify-center gap-4 text-slate-400">
        <Loader2 className="w-10 h-10 animate-spin text-emerald-500" />
        <p className="font-bold uppercase tracking-widest text-xs">Syncing Performance Data...</p>
      </div>
    );
  }

  const { stats, salesTrends, liveDeliveries } = data;

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-slate-900 font-outfit">Performance Insights</h1>
        <p className="text-slate-500 mt-2">Track your business growth and delivery performance.</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard title="Total Revenue" value={`₹${stats.totalSales.toLocaleString()}`} icon={TrendingUp} trend="+100%" onClick={() => navigate('/revenue')} />
        <StatCard title="All Time Orders" value={stats.totalOrders} icon={ShoppingBag} trend="+New" onClick={() => navigate('/orders')} />
        <StatCard title="Active Customers" value={stats.activeUsers} icon={Users} trend="+3.1%" onClick={() => navigate('/customers')} />
        <StatCard title="In Logistics" value={stats.pendingDeliveries} icon={Package} trend="-2.4%" onClick={() => navigate('/orders')} />
      </div>

      {/* Packing Purpose Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="p-8 bg-slate-900 rounded-[2.5rem] text-white shadow-2xl shadow-emerald-900/20 overflow-hidden relative group transition-all hover:shadow-emerald-500/10">
           <div className="absolute -top-10 -right-10 opacity-10 group-hover:scale-110 transition-transform duration-700">
              <Package className="w-64 h-64" />
           </div>
           <div className="relative z-10 flex items-center justify-between gap-6">
              <div>
                 <div className="flex items-center gap-2 mb-3">
                    <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                    <p className="text-xs font-black text-emerald-400 uppercase tracking-[0.2em] font-outfit">Priority Packing</p>
                 </div>
                 <h2 className="text-4xl font-black font-outfit tracking-tighter leading-none mb-2">Today's Total</h2>
                 <p className="text-slate-400 font-bold text-sm max-w-[240px]">Immediate dispatch required for instant and slot deliveries.</p>
              </div>
              <div className="text-center bg-white/10 px-8 py-6 rounded-3xl border border-white/20 backdrop-blur-xl shadow-2xl">
                 <p className="text-6xl font-black font-outfit text-emerald-400 leading-none">{stats.logistics?.today || 0}</p>
                 <p className="text-[10px] font-black uppercase tracking-widest text-slate-500 mt-3">Live Orders</p>
              </div>
           </div>
        </div>

        <div className="p-8 bg-white rounded-[2.5rem] border-2 border-indigo-50 shadow-xl shadow-indigo-100/20 overflow-hidden relative group hover:border-indigo-100 transition-all">
           <div className="absolute -top-10 -right-10 opacity-[0.03] group-hover:scale-110 transition-transform duration-700 text-indigo-600">
              <ShoppingBag className="w-64 h-64" />
           </div>
           <div className="relative z-10 flex items-center justify-between gap-6">
              <div>
                 <div className="flex items-center gap-2 mb-3">
                    <span className="w-2 h-2 rounded-full bg-indigo-500" />
                    <p className="text-xs font-black text-indigo-500 uppercase tracking-[0.2em] font-outfit">Fulfillment Buffer</p>
                 </div>
                 <h2 className="text-4xl font-black font-outfit tracking-tighter leading-none mb-2 text-slate-900">Tomorrow's Load</h2>
                 <p className="text-slate-500 font-bold text-sm max-w-[240px]">Scheduled inventory requirements for upcoming slots.</p>
              </div>
              <div className="text-center bg-indigo-50/50 px-8 py-6 rounded-3xl border border-indigo-100 shadow-sm">
                 <p className="text-6xl font-black font-outfit text-indigo-600 leading-none">{stats.logistics?.tomorrow || 0}</p>
                 <p className="text-[10px] font-black uppercase tracking-widest text-indigo-400 mt-3">Pre-orders</p>
              </div>
           </div>
        </div>
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 p-8 bg-white rounded-3xl border border-slate-100 shadow-sm">
          <div className="flex justify-between items-center mb-8">
            <h2 className="text-xl font-bold text-slate-900 font-outfit">Sales Trends (Last 7 Days)</h2>
          </div>
          <div className="h-[300px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={salesTrends}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E2E8F0" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#64748B', fontSize: 12}} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{fill: '#64748B', fontSize: 12}} />
                <Tooltip 
                  contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgba(0,0,0,0.1)' }}
                  formatter={(value: any) => [`₹${value}`, 'Sales']}
                />
                <Line 
                  type="monotone" 
                  dataKey="sales" 
                  stroke="#10B981" 
                  strokeWidth={4} 
                  dot={{ r: 4, stroke: '#10B981', strokeWidth: 2, fill: '#fff' }}
                  activeDot={{ r: 8, stroke: '#10B981', strokeWidth: 2, fill: '#fff' }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Live Delivery Status (List) */}
        <div className="p-8 bg-white rounded-3xl border border-slate-100 shadow-sm">
          <h2 className="text-xl font-bold text-slate-900 mb-6 font-outfit">Live Deliveries</h2>
          <div className="space-y-6">
            {liveDeliveries.length > 0 ? liveDeliveries.map((item: any) => (
              <div 
                key={item.id} 
                onClick={() => navigate('/orders')}
                className="flex gap-4 items-center cursor-pointer hover:bg-slate-50 p-3 -m-3 rounded-2xl transition-colors group"
              >
                <div className="w-12 h-12 bg-slate-50 rounded-2xl flex items-center justify-center group-hover:bg-emerald-50 transition-colors">
                  <MapPin className="w-6 h-6 text-slate-400 group-hover:text-emerald-500 transition-colors" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-bold text-slate-900 truncate group-hover:text-emerald-700 transition-colors">{item.id}</p>
                  <p className={`text-xs font-medium ${item.status === 'Delivered' ? 'text-emerald-500' : 'text-blue-500'}`}>
                    {item.rider !== 'Unassigned' ? `Assigned: ${item.rider}` : item.status}
                  </p>
                </div>
                <ChevronRight className="w-4 h-4 text-slate-300 opacity-0 group-hover:opacity-100 transition-all" />
              </div>
            )) : <p className="text-sm text-slate-400 font-bold p-10 text-center">No active deliveries.</p>}
          </div>
        </div>
      </div>
    </div>
  );
}
