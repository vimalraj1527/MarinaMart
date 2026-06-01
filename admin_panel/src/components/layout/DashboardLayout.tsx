import { useState, useEffect } from 'react';
import { NavLink, Outlet, useNavigate, Link } from 'react-router-dom';
import { 
  LayoutDashboard, 
  ShoppingBag, 
  Package, 
  Users, 
  Truck,
  Settings, 
  LogOut,
  Layers,
  TrendingUp,
  ShoppingBag as OrderIcon,
  Bell,
  Clock,
  Wallet,
  Gift
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import api from '../../services/api';

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

  const [isNotificationOpen, setIsNotificationOpen] = useState(false);
  const [notifications, setNotifications] = useState<any[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);

  const fetchNotifications = async () => {
    try {
      const res = await api.get('/orders');
      const recentOrders = res.data.slice(0, 5);
      
      const incoming = recentOrders.map((order: any) => ({
        id: order.id,
        title: 'New Order Received',
        message: `Order ${order.orderNumber} placed by ${order.customerName}`,
        time: new Date(order.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        type: 'order',
        isRead: false
      }));

      incoming.push({
        id: 'sys-1',
        title: 'Platform Maintenance',
        message: 'Cloud database synchronization complete.',
        time: 'Just now',
        type: 'system',
        isRead: false
      });

      setNotifications(prev => {
        const merged = incoming.map((newItem: any) => {
          const existing = prev.find((p: any) => p.id === newItem.id);
          return existing ? { ...newItem, isRead: existing.isRead } : newItem;
        });
        const unreadCurrent = merged.filter((m: any) => !m.isRead).length;
        setUnreadCount(unreadCurrent);
        return merged;
      });
    } catch (err) {
      console.error('Error loading notifications:', err);
    }
  };

  useEffect(() => {
    fetchNotifications();
    const timer = setInterval(fetchNotifications, 60000); // Refresh every minute
    return () => clearInterval(timer);
  }, []);

  const handleLogout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    navigate('/login');
  };

  const markAsRead = (id: string) => {
    setNotifications(prev => prev.map(n => n.id === id ? { ...n, isRead: true } : n));
    setUnreadCount(prev => Math.max(0, prev - 1));
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

        <nav className="flex-1 mt-6 overflow-y-auto">
          <SidebarItem icon={LayoutDashboard} label="Dashboard" path="/" />
          <SidebarItem icon={TrendingUp} label="Revenue" path="/revenue" />
          <SidebarItem icon={Package} label="Products" path="/products" />
          <SidebarItem icon={Layers} label="Banners" path="/banners" />
          <SidebarItem icon={Layers} label="Categories" path="/categories" />
          <SidebarItem icon={ShoppingBag} label="Orders" path="/orders" />
          <SidebarItem icon={Users} label="Customers" path="/customers" />
          <SidebarItem icon={Wallet} label="Wallet Approvals" path="/wallet-requests" />
          <SidebarItem icon={Gift} label="Wallet Coupons" path="/wallet-coupons" />
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
            <div className="relative">
              <button 
                onClick={() => setIsNotificationOpen(!isNotificationOpen)}
                className={`relative p-3 rounded-2xl transition-all group ${isNotificationOpen ? 'bg-emerald-600 text-white shadow-lg shadow-emerald-200' : 'bg-slate-50 text-slate-500 hover:bg-slate-100 hover:text-slate-900'}`}
              >
                <Bell className="w-5 h-5 flex-shrink-0" />
                {unreadCount > 0 && (
                  <span className={`absolute top-2 right-2 w-2.5 h-2.5 border-2 rounded-full ${isNotificationOpen ? 'bg-white border-emerald-600' : 'bg-red-500 border-white'}`} />
                )}
              </button>

              <AnimatePresence>
                {isNotificationOpen && (
                  <>
                    <motion.div 
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      exit={{ opacity: 0 }}
                      onClick={() => setIsNotificationOpen(false)}
                      className="fixed inset-0 z-40 bg-transparent"
                    />
                    <motion.div
                      initial={{ opacity: 0, y: 15, scale: 0.95 }}
                      animate={{ opacity: 1, y: 0, scale: 1 }}
                      exit={{ opacity: 0, y: 15, scale: 0.95 }}
                      className="absolute right-0 mt-4 w-96 bg-white rounded-[2.5rem] shadow-2xl border border-slate-100 overflow-hidden z-50 origin-top-right"
                    >
                      <div className="p-6 border-b border-slate-100 flex items-center justify-between">
                        <h3 className="text-lg font-bold text-slate-900">Notifications</h3>
                        <span className="px-3 py-1 bg-emerald-50 text-emerald-600 text-[10px] font-bold rounded-lg uppercase tracking-widest">{unreadCount} New</span>
                      </div>

                      <div className="max-h-[450px] overflow-y-auto">
                        {notifications.length > 0 ? (
                          notifications.map((n) => (
                            <div 
                              key={n.id} 
                              onClick={() => markAsRead(n.id)}
                              className={`p-6 border-b border-slate-50 last:border-0 cursor-pointer transition-colors flex gap-4 items-start ${n.isRead ? 'opacity-60 grayscale' : 'hover:bg-slate-50 bg-emerald-50/5'}`}
                            >
                              <div className={`p-3 rounded-2xl ${n.type === 'order' ? 'bg-emerald-100 text-emerald-600' : 'bg-blue-100 text-blue-600'}`}>
                                {n.type === 'order' ? <OrderIcon className="w-4 h-4" /> : <Clock className="w-4 h-4" />}
                              </div>
                              <div className="flex-1 min-w-0">
                                <div className="flex justify-between items-start mb-1">
                                  <p className="font-bold text-sm text-slate-900">{n.title}</p>
                                  <p className="text-[10px] font-bold text-slate-400">{n.time}</p>
                                </div>
                                <p className="text-xs text-slate-500 line-clamp-2 leading-relaxed">{n.message}</p>
                              </div>
                              {!n.isRead && (
                                <div className="w-2 h-2 bg-emerald-500 rounded-full mt-2 ring-4 ring-emerald-50" />
                              )}
                            </div>
                          ))
                        ) : (
                          <div className="p-12 text-center text-slate-400">
                             <Bell className="w-10 h-10 mx-auto mb-4 opacity-20" />
                             <p className="font-bold text-sm">All caught up!</p>
                             <p className="text-xs opacity-60">No new notifications at the moment.</p>
                          </div>
                        )}
                      </div>

                      <button 
                        onClick={() => {
                          setNotifications(prev => prev.map(n => ({...n, isRead: true})));
                          setUnreadCount(0);
                        }}
                        className="w-full py-5 bg-slate-50 text-xs font-bold text-slate-500 hover:text-emerald-600 transition-colors border-t border-slate-50 cursor-pointer"
                      >
                        Mark All as Read
                      </button>
                    </motion.div>
                  </>
                )}
              </AnimatePresence>
            </div>
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
