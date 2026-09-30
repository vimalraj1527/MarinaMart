import { useState, useEffect } from 'react';
import { NavLink, Outlet, useNavigate, Link, useLocation } from 'react-router-dom';
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
  Gift,
  MessageSquare,
  Menu,
  X
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import api from '../../services/api';
import { formatToISTTimeOnly } from '../../services/dateUtils';

const SidebarItem = ({ icon: Icon, label, path, onClick }: any) => (
  <NavLink 
    to={path}
    onClick={onClick}
    className={({ isActive }) => `
      flex items-center gap-4 px-6 py-3.5 transition-all duration-300
      ${isActive ? 'bg-emerald-50 text-emerald-600 border-r-4 border-emerald-600 font-bold' : 'text-slate-500 hover:bg-slate-50 hover:text-slate-900 font-semibold'}
    `}
  >
    <Icon className="w-5 h-5 flex-shrink-0" />
    <span className="text-sm">{label}</span>
  </NavLink>
);

export default function DashboardLayout() {
  const navigate = useNavigate();
  const location = useLocation();
  const [currentUser, setCurrentUser] = useState<any>(null);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  useEffect(() => {
    const user = localStorage.getItem('user');
    if (user) {
      setCurrentUser(JSON.parse(user));
    }
  }, []);

  // Close mobile drawer when route changes
  useEffect(() => {
    setIsMobileMenuOpen(false);
  }, [location.pathname]);

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
        time: formatToISTTimeOnly(order.createdAt),
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
    const timer = setInterval(fetchNotifications, 60000);
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

  const navContent = (
    <>
      <Link 
        to="/" 
        onClick={() => setIsMobileMenuOpen(false)}
        className="p-6 md:p-8 flex items-center gap-4 hover:opacity-80 transition-opacity cursor-pointer border-b border-slate-50 md:border-b-0"
      >
        <div className="p-3 bg-emerald-600 rounded-2xl shadow-lg shadow-emerald-100 flex-shrink-0">
          <Package className="w-6 h-6 text-white" />
        </div>
        <div>
          <h1 className="text-xl font-bold text-slate-900 font-outfit">Instamart</h1>
          <p className="text-[10px] uppercase font-bold tracking-widest text-emerald-600">Admin Panel</p>
        </div>
      </Link>

      <nav className="flex-1 mt-2 md:mt-6 overflow-y-auto">
        <SidebarItem icon={LayoutDashboard} label="Dashboard" path="/" onClick={() => setIsMobileMenuOpen(false)} />
        <SidebarItem icon={TrendingUp} label="Revenue" path="/revenue" onClick={() => setIsMobileMenuOpen(false)} />
        <SidebarItem icon={Package} label="Products" path="/products" onClick={() => setIsMobileMenuOpen(false)} />
        <SidebarItem icon={Layers} label="Banners" path="/banners" onClick={() => setIsMobileMenuOpen(false)} />
        <SidebarItem icon={Layers} label="Categories" path="/categories" onClick={() => setIsMobileMenuOpen(false)} />
        <SidebarItem icon={ShoppingBag} label="Orders" path="/orders" onClick={() => setIsMobileMenuOpen(false)} />
        <SidebarItem icon={Users} label="Customers" path="/customers" onClick={() => setIsMobileMenuOpen(false)} />
        <SidebarItem icon={Wallet} label="Wallet Approvals" path="/wallet-requests" onClick={() => setIsMobileMenuOpen(false)} />
        <SidebarItem icon={Gift} label="Wallet Coupons" path="/wallet-coupons" onClick={() => setIsMobileMenuOpen(false)} />
        <SidebarItem icon={Truck} label="Riders Fleet" path="/riders" onClick={() => setIsMobileMenuOpen(false)} />
        <SidebarItem icon={MessageSquare} label="Support Chats" path="/support" onClick={() => setIsMobileMenuOpen(false)} />
        <SidebarItem icon={Settings} label="Settings" path="/settings" onClick={() => setIsMobileMenuOpen(false)} />
      </nav>

      <div className="p-6 md:p-8 border-t border-slate-50 mt-auto">
        <button 
          onClick={handleLogout}
          className="flex items-center gap-4 text-slate-500 hover:text-red-500 transition-colors w-full group cursor-pointer"
        >
          <div className="p-3 bg-slate-50 rounded-2xl group-hover:bg-red-50 transition-colors flex-shrink-0">
            <LogOut className="w-5 h-5" />
          </div>
          <span className="font-semibold text-sm">Sign Out</span>
        </button>
      </div>
    </>
  );

  return (
    <div className="flex min-h-screen bg-[#F8FAFC]">
      {/* Desktop Sidebar */}
      <aside className="hidden lg:flex lg:w-72 bg-white border-r border-slate-100 flex-col sticky top-0 h-screen z-40 flex-shrink-0">
        {navContent}
      </aside>

      {/* Mobile Sidebar Overlay Drawer */}
      <AnimatePresence>
        {isMobileMenuOpen && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsMobileMenuOpen(false)}
              className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 lg:hidden"
            />
            <motion.aside
              initial={{ x: '-100%' }}
              animate={{ x: 0 }}
              exit={{ x: '-100%' }}
              transition={{ type: 'spring', damping: 25, stiffness: 200 }}
              className="fixed inset-y-0 left-0 w-80 max-w-[85vw] bg-white z-50 flex flex-col shadow-2xl lg:hidden"
            >
              <div className="absolute top-5 right-5 z-10">
                <button
                  onClick={() => setIsMobileMenuOpen(false)}
                  className="p-2 rounded-xl bg-slate-100 text-slate-600 hover:bg-slate-200 transition-colors"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>
              {navContent}
            </motion.aside>
          </>
        )}
      </AnimatePresence>

      {/* Main Content Area */}
      <main className="flex-1 min-w-0 flex flex-col">
        {/* Header */}
        <header className="bg-white/90 backdrop-blur-xl border-b border-slate-100 px-4 sm:px-8 py-4 sticky top-0 z-30 flex items-center justify-between h-20">
          <div className="flex items-center gap-3 lg:hidden">
            <button
              onClick={() => setIsMobileMenuOpen(true)}
              className="p-3 bg-slate-50 hover:bg-slate-100 text-slate-700 rounded-2xl border border-slate-200/60 transition-all cursor-pointer"
            >
              <Menu className="w-5 h-5" />
            </button>
            <Link to="/" className="flex items-center gap-2">
              <div className="p-2 bg-emerald-600 rounded-xl">
                <Package className="w-4 h-4 text-white" />
              </div>
              <span className="font-bold text-slate-900 font-outfit text-base">Instamart</span>
            </Link>
          </div>

          <div className="flex items-center gap-3 sm:gap-6 ml-auto">
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
                      className="absolute right-0 mt-4 w-80 sm:w-96 bg-white rounded-[2rem] shadow-2xl border border-slate-100 overflow-hidden z-50 origin-top-right max-w-[calc(100vw-2rem)]"
                    >
                      <div className="p-5 border-b border-slate-100 flex items-center justify-between">
                        <h3 className="text-base font-bold text-slate-900">Notifications</h3>
                        <span className="px-3 py-1 bg-emerald-50 text-emerald-600 text-[10px] font-bold rounded-lg uppercase tracking-widest">{unreadCount} New</span>
                      </div>

                      <div className="max-h-[380px] overflow-y-auto">
                        {notifications.length > 0 ? (
                          notifications.map((n) => (
                            <div 
                              key={n.id} 
                              onClick={() => markAsRead(n.id)}
                              className={`p-5 border-b border-slate-50 last:border-0 cursor-pointer transition-colors flex gap-3 items-start ${n.isRead ? 'opacity-60 grayscale' : 'hover:bg-slate-50 bg-emerald-50/5'}`}
                            >
                              <div className={`p-2.5 rounded-xl flex-shrink-0 ${n.type === 'order' ? 'bg-emerald-100 text-emerald-600' : 'bg-blue-100 text-blue-600'}`}>
                                {n.type === 'order' ? <OrderIcon className="w-4 h-4" /> : <Clock className="w-4 h-4" />}
                              </div>
                              <div className="flex-1 min-w-0">
                                <div className="flex justify-between items-start mb-1">
                                  <p className="font-bold text-xs sm:text-sm text-slate-900">{n.title}</p>
                                  <p className="text-[10px] font-bold text-slate-400">{n.time}</p>
                                </div>
                                <p className="text-xs text-slate-500 line-clamp-2 leading-relaxed">{n.message}</p>
                              </div>
                              {!n.isRead && (
                                <div className="w-2 h-2 bg-emerald-500 rounded-full mt-2 ring-4 ring-emerald-50 flex-shrink-0" />
                              )}
                            </div>
                          ))
                        ) : (
                          <div className="p-8 text-center text-slate-400">
                             <Bell className="w-8 h-8 mx-auto mb-3 opacity-20" />
                             <p className="font-bold text-xs sm:text-sm">All caught up!</p>
                             <p className="text-xs opacity-60">No new notifications at the moment.</p>
                          </div>
                        )}
                      </div>

                      <button 
                        onClick={() => {
                          setNotifications(prev => prev.map(n => ({...n, isRead: true})));
                          setUnreadCount(0);
                        }}
                        className="w-full py-4 bg-slate-50 text-xs font-bold text-slate-500 hover:text-emerald-600 transition-colors border-t border-slate-50 cursor-pointer"
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
              className="flex items-center gap-3 bg-slate-50 pl-2 pr-3 sm:pr-4 py-1.5 rounded-2xl border border-slate-100 hover:border-emerald-200 hover:bg-emerald-50/20 transition-all cursor-pointer group"
            >
              <div className="w-9 h-9 sm:w-10 sm:h-10 bg-emerald-600 rounded-xl flex items-center justify-center text-white font-bold text-xs sm:text-sm group-hover:scale-105 transition-transform flex-shrink-0">
                {currentUser?.name?.charAt(0) || 'A'}
              </div>
              <div className="hidden sm:block min-w-[90px]">
                <p className="text-xs font-bold text-slate-900 leading-tight truncate">{currentUser?.name || 'Admin'}</p>
                <p className="text-[10px] text-slate-400 font-bold uppercase tracking-tighter mt-0.5">{currentUser?.role || 'Admin'}</p>
              </div>
            </Link>
          </div>
        </header>

        <div className="p-4 sm:p-6 md:p-8 lg:p-10 flex-1">
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
