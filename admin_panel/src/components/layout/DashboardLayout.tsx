import React, { useState, useEffect } from 'react';
import { NavLink, Outlet, useNavigate, Link } from 'react-router-dom';
import { 
  LayoutDashboard, 
  ShoppingBag, 
  Package, 
  Users, 
  Truck,
  Settings, 
  Bell, 
  LogOut,
  Layers,
  TrendingUp
} from 'lucide-react';
import { motion } from 'framer-motion';

const SidebarItem = ({ icon: Icon, label, path }: any) => (
  <NavLink 
    to={path}
    className={({ isActive }) => `
      flex items-center gap-4 px-6 py-4 transition-all duration-300
      ${isActive ? 'bg-emerald-50 text-emerald-600 border-r-4 border-emerald-600' : 'text-slate-500 hover:bg-slate-50 hover:text-slate-900'}
    `}
  >
    <Icon className="w-5 h-5" />
    <span className="font-semibold text-sm">{label}</span>
  </NavLink>
);

export default function DashboardLayout() {
  const navigate = useNavigate();
  const [currentUser, setCurrentUser] = useState<any>(null);

  useEffect(() => {
    const user = localStorage.getItem('user');
    if (user) {
      setCurrentUser(JSON.parse(user));
    }
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    navigate('/login');
  };

  return (
    <div className="flex min-h-screen bg-[#F8FAFC]">
      {/* Sidebar */}
      <aside className="w-72 bg-white border-r border-slate-100 flex flex-col sticky top-0 h-screen z-50">
        <Link 
          to="/" 
          className="p-8 flex items-center gap-4 hover:opacity-80 transition-opacity cursor-pointer"
        >
          <div className="p-3 bg-emerald-600 rounded-2xl shadow-lg shadow-emerald-100">
            <Package className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="text-xl font-bold text-slate-900 font-outfit">Instamart</h1>
            <p className="text-[10px] uppercase font-bold tracking-widest text-emerald-600">Admin Panel</p>
          </div>
        </Link>

        <nav className="flex-1 mt-6">
          <SidebarItem icon={LayoutDashboard} label="Dashboard" path="/" />
          <SidebarItem icon={TrendingUp} label="Revenue" path="/revenue" />
          <SidebarItem icon={Package} label="Products" path="/products" />
          <SidebarItem icon={Layers} label="Categories" path="/categories" />
          <SidebarItem icon={ShoppingBag} label="Orders" path="/orders" />
          <SidebarItem icon={Users} label="Customers" path="/customers" />
          <SidebarItem icon={Truck} label="Riders Fleet" path="/riders" />
          <SidebarItem icon={Settings} label="Settings" path="/settings" />
        </nav>

        <div className="p-8 border-t border-slate-50">
          <button 
            onClick={handleLogout}
            className="flex items-center gap-4 text-slate-500 hover:text-red-500 transition-colors w-full group"
          >
            <div className="p-3 bg-slate-50 rounded-2xl group-hover:bg-red-50 transition-colors">
              <LogOut className="w-5 h-5" />
            </div>
            <span className="font-semibold text-sm">Sign Out</span>
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="flex-1 min-w-0">
        <header className="bg-white/80 backdrop-blur-xl border-b border-slate-100 px-8 py-4 sticky top-0 z-40 flex justify-between items-center h-20">
          <div className="flex items-center gap-6 ml-auto">
            <button className="relative p-3 bg-slate-50 rounded-2xl hover:bg-slate-100 transition-colors group">
              <Bell className="w-5 h-5 text-slate-500 group-hover:text-slate-900" />
              <span className="absolute top-2 right-2 w-2.5 h-2.5 bg-red-500 border-2 border-white rounded-full" />
            </button>
            <Link 
              to="/settings"
              className="flex items-center gap-4 bg-slate-50 pl-2 pr-4 py-2 rounded-2xl border border-slate-100 hover:border-emerald-200 hover:bg-emerald-50/20 transition-all cursor-pointer group"
            >
              <div className="w-10 h-10 bg-emerald-600 rounded-xl flex items-center justify-center text-white font-bold text-sm group-hover:scale-105 transition-transform">
                {currentUser?.name?.charAt(0) || 'A'}
              </div>
              <div className="min-w-[100px]">
                <p className="text-xs font-bold text-slate-900 leading-tight">{currentUser?.name || 'Loading...'}</p>
                <p className="text-[10px] text-slate-400 font-bold uppercase tracking-tighter mt-0.5">{currentUser?.role || 'Admin Account'}</p>
              </div>
            </Link>
          </div>
        </header>

        <div className="p-10">
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4 }}
          >
            <Outlet />
          </motion.div>
        </div>
      </main>
    </div>
  );
}
