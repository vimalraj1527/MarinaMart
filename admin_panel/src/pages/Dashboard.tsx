import { 
  ShoppingBag, 
  Users, 
  TrendingUp, 
  Package, 
  MapPin
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

const data = [
  { name: 'Mon', sales: 4000, orders: 240 },
  { name: 'Tue', sales: 3000, orders: 198 },
  { name: 'Wed', sales: 2000, orders: 980 },
  { name: 'Thu', sales: 2780, orders: 390 },
  { name: 'Fri', sales: 1890, orders: 480 },
  { name: 'Sat', sales: 2390, orders: 380 },
  { name: 'Sun', sales: 3490, orders: 430 },
];

const StatCard = ({ title, value, icon: Icon, trend }: any) => (
  <motion.div 
    initial={{ opacity: 0, y: 20 }}
    whileInView={{ opacity: 1, y: 0 }}
    className="p-6 bg-white rounded-3xl border border-slate-100 shadow-sm hover:shadow-md transition-shadow"
  >
    <div className="flex items-center justify-between">
      <div className="p-3 bg-emerald-50 rounded-2xl">
        <Icon className="w-6 h-6 text-emerald-600" />
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
  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-slate-900 font-outfit">Performance Insights</h1>
        <p className="text-slate-500 mt-2">Track your business growth and delivery performance.</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard title="Total Sales" value="₹42,890.00" icon={TrendingUp} trend="+12.5%" />
        <StatCard title="Total Orders" value="1,280" icon={ShoppingBag} trend="+8.2%" />
        <StatCard title="Active Users" value="842" icon={Users} trend="+3.1%" />
        <StatCard title="Pending Deliveries" value="45" icon={Package} trend="-2.4%" />
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 p-8 bg-white rounded-3xl border border-slate-100 shadow-sm">
          <div className="flex justify-between items-center mb-8">
            <h2 className="text-xl font-bold text-slate-900 font-outfit">Sales Trends</h2>
          </div>
          <div className="h-[300px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={data}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E2E8F0" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#64748B', fontSize: 12}} dy={10} />
                <YAxis axisLine={false} tickLine={false} tick={{fill: '#64748B', fontSize: 12}} />
                <Tooltip 
                  contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 15px -3px rgba(0,0,0,0.1)' }}
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
            {[1, 2, 3, 4].map((item) => (
              <div key={item} className="flex gap-4 items-center">
                <div className="w-12 h-12 bg-slate-50 rounded-2xl flex items-center justify-center">
                  <MapPin className="w-6 h-6 text-slate-400" />
                </div>
                <div>
                  <p className="text-sm font-bold text-slate-900">Order #882{item}</p>
                  <p className="text-xs text-emerald-500 font-medium">On the Way</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
