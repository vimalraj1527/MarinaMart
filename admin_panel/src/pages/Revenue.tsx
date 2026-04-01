import { useState, useEffect } from 'react';
import { 
  TrendingUp, 
  ArrowUpRight, 
  ArrowDownRight, 
  DollarSign, 
  Calendar,
  Layers,
  ArrowRight,
  Loader2
} from 'lucide-react';
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  AreaChart,
  Area
} from 'recharts';
import { motion } from 'framer-motion';
import api from '../services/api';

const RevenueStat = ({ title, value, change, isPositive }: any) => (
  <div className="p-8 bg-white rounded-[2.5rem] border border-slate-100 shadow-sm transition-all hover:shadow-xl hover:shadow-emerald-500/5 group">
    <div className="flex items-center justify-between mb-4">
      <div className="p-3 bg-emerald-50 rounded-2xl group-hover:bg-emerald-600 group-hover:text-white transition-all">
        <DollarSign className="w-6 h-6 text-emerald-600 group-hover:text-white" />
      </div>
      <div className={`flex items-center gap-1 px-3 py-1 rounded-full text-xs font-bold ${isPositive ? 'bg-emerald-50 text-emerald-600' : 'bg-red-50 text-red-500'}`}>
        {isPositive ? <ArrowUpRight className="w-3 h-3" /> : <ArrowDownRight className="w-3 h-3" />}
        {change}
      </div>
    </div>
    <h3 className="text-sm font-bold text-slate-400 uppercase tracking-widest">{title}</h3>
    <p className="text-3xl font-bold text-slate-900 mt-2">₹{value.toLocaleString()}</p>
  </div>
);

export default function RevenuePage() {
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState<any>(null);

  const fetchRevenueData = async () => {
    try {
      setLoading(true);
      // We'll reuse the stats endpoint or a more detailed one if we expand the backend.
      // For now, let's fetch the same stats which has totalSales and trends.
      const response = await api.get('/dashboard/stats');
      setData(response.data);
    } catch (err) {
      console.error('Failed to fetch revenue data:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRevenueData();
  }, []);

  if (loading) {
    return (
      <div className="h-[60vh] flex flex-col items-center justify-center gap-4 text-slate-400">
        <Loader2 className="w-10 h-10 animate-spin text-emerald-500" />
        <p className="font-bold uppercase tracking-widest text-xs font-outfit">Recalculating Earnings...</p>
      </div>
    );
  }

  const { stats, salesTrends } = data;

  // Mocking some monthly data for the Bar Chart as the current backend provides 7 days.
  // In a real scenario, the backend would provide this.
  const monthlyData = [
    { name: 'Jan', revenue: stats.totalSales * 0.8 },
    { name: 'Feb', revenue: stats.totalSales * 0.9 },
    { name: 'Mar', revenue: stats.totalSales },
    { name: 'Apr', revenue: stats.totalSales * 1.2 },
    { name: 'May', revenue: stats.totalSales * 1.1 },
    { name: 'Jun', revenue: stats.totalSales * 1.4 },
  ];

  return (
    <div className="space-y-10">
      {/* Header */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
        <div>
           <h1 className="text-4xl font-black text-slate-900 font-outfit tracking-tight">Revenue Analytics</h1>
           <p className="text-slate-500 mt-2 font-medium">Financial health and growth trajectory of your platform.</p>
        </div>
        <div className="flex items-center gap-4">
           <div className="px-6 py-3 bg-white border border-slate-100 rounded-2xl flex items-center gap-3 shadow-sm">
              <Calendar className="w-5 h-5 text-emerald-500" />
              <span className="font-bold text-slate-900 font-outfit italic">FY 2025-26</span>
           </div>
        </div>
      </div>

      {/* Primary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        <RevenueStat title="Total Earnings" value={stats.totalSales} change="+12.5%" isPositive={true} />
        <RevenueStat title="Average Order Value" value={stats.totalSales / (stats.totalOrders || 1)} change="+3.2%" isPositive={true} />
        <RevenueStat title="Projected Revenue" value={stats.totalSales * 1.5} change="+45% Target" isPositive={true} />
      </div>

      {/* Main Revenue Chart */}
      <div className="p-10 bg-white rounded-[3rem] border border-slate-100 shadow-sm relative overflow-hidden">
        <div className="absolute top-0 right-0 w-64 h-64 bg-emerald-50 rounded-full blur-[100px] -translate-y-1/2 translate-x-1/2 opacity-50" />
        
        <div className="relative z-10">
          <div className="flex flex-col md:flex-row md:items-center justify-between mb-12 gap-4">
            <div>
              <h2 className="text-2xl font-bold text-slate-900 font-outfit">Revenue Velocity</h2>
              <p className="text-slate-400 font-bold uppercase tracking-widest text-xs mt-1">Daily trend comparison (Last 7 Days)</p>
            </div>
            <div className="flex p-1 bg-slate-100 rounded-2xl">
               <button className="px-6 py-2 bg-white rounded-xl shadow-sm font-bold text-emerald-600 text-sm">7D</button>
               <button className="px-6 py-2 text-slate-400 font-bold text-sm">30D</button>
               <button className="px-6 py-2 text-slate-400 font-bold text-sm">90D</button>
            </div>
          </div>

          <div className="h-[400px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={salesTrends}>
                <defs>
                  <linearGradient id="colorSales" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#10B981" stopOpacity={0.1}/>
                    <stop offset="95%" stopColor="#10B981" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#F1F5F9" />
                <XAxis 
                  dataKey="name" 
                  axisLine={false} 
                  tickLine={false} 
                  tick={{fill: '#94A3B8', fontSize: 13, fontWeight: 700}} 
                  dy={15}
                />
                <YAxis 
                  axisLine={false} 
                  tickLine={false} 
                  tick={{fill: '#94A3B8', fontSize: 13, fontWeight: 700}}
                  tickFormatter={(val) => `₹${val/1000}k`}
                />
                <Tooltip 
                  contentStyle={{ borderRadius: '24px', border: 'none', boxShadow: '0 20px 25px -5px rgba(0,0,0,0.1)', padding: '20px' }}
                  itemStyle={{ fontWeight: 800, color: '#10B981' }}
                  cursor={{ stroke: '#10B981', strokeWidth: 2 }}
                />
                <Area 
                  type="monotone" 
                  dataKey="sales" 
                  stroke="#10B981" 
                  strokeWidth={5} 
                  fillOpacity={1} 
                  fill="url(#colorSales)" 
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      {/* Breakdown Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="p-10 bg-slate-900 rounded-[3rem] text-white shadow-2xl shadow-slate-200">
           <div className="flex items-center justify-between mb-10">
              <h2 className="text-2xl font-bold font-outfit">Quarterly Growth</h2>
              <TrendingUp className="w-6 h-6 text-emerald-400" />
           </div>
           
           <div className="h-[300px] w-full mt-4">
              <ResponsiveContainer width="100%" height="100%">
                 <BarChart data={monthlyData}>
                   <Bar 
                     dataKey="revenue" 
                     fill="#10B981" 
                     radius={[10, 10, 10, 10]} 
                     barSize={35}
                   />
                   <XAxis dataKey="name" hide />
                   <Tooltip 
                     cursor={{ fill: 'rgba(255,255,255,0.05)' }}
                     contentStyle={{ backgroundColor: '#1E293B', borderRadius: '16px', border: 'none' }}
                   />
                 </BarChart>
              </ResponsiveContainer>
           </div>

           <div className="mt-10 pt-10 border-t border-slate-800 flex items-center justify-between">
              <div>
                 <p className="text-slate-400 text-sm font-bold uppercase tracking-widest">Growth Percentage</p>
                 <p className="text-3xl font-black text-emerald-400 mt-1">+28.4% YoY</p>
              </div>
              <button className="flex items-center gap-2 p-4 bg-slate-800 rounded-2xl hover:bg-emerald-600 transition-all font-bold">
                 Full Report <ArrowRight className="w-5 h-5" />
              </button>
           </div>
        </div>

        <div className="p-10 bg-white rounded-[3rem] border border-slate-100 shadow-sm">
           <div className="flex items-center justify-between mb-8">
              <h2 className="text-2xl font-bold text-slate-900 font-outfit">Financial Insights</h2>
              <div className="w-12 h-12 bg-slate-50 rounded-2xl flex items-center justify-center">
                 <Layers className="w-6 h-6 text-slate-400" />
              </div>
           </div>
           
           <div className="space-y-6">
              {[
                { label: 'Cloud Revenue', val: '72%', color: 'bg-emerald-500' },
                { label: 'Mobile App Sales', val: '88%', color: 'bg-blue-500' },
                { label: 'Operational Efficiency', val: '94%', color: 'bg-purple-500' }
              ].map((item, idx) => (
                <div key={idx} className="space-y-3">
                   <div className="flex justify-between text-sm font-bold">
                      <span className="text-slate-500">{item.label}</span>
                      <span className="text-slate-900">{item.val}</span>
                   </div>
                   <div className="h-3 bg-slate-50 rounded-full overflow-hidden">
                      <motion.div 
                        initial={{ width: 0 }}
                        animate={{ width: item.val }}
                        transition={{ duration: 1, delay: 0.5 + (idx * 0.2) }}
                        className={`h-full ${item.color} rounded-full`}
                      />
                   </div>
                </div>
              ))}
           </div>

           <div className="mt-12 p-6 bg-emerald-50 border border-emerald-100 rounded-[2rem]">
              <p className="text-emerald-700 font-bold italic text-center">"Revenue is trending above quarterly projections. Consider increasing delivery partner incentives."</p>
           </div>
        </div>
      </div>
    </div>
  );
}
