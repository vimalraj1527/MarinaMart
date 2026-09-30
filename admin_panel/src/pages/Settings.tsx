import { useState, useEffect } from 'react';
import { 
  Store, 
  Truck, 
  ShieldCheck, 
  Mail, 
  DollarSign,
  Clock,
  Save,
  CheckCircle2,
  Bell,
  Users,
  UserPlus,
  Key,
  ShieldAlert,
  TrendingUp,
  Zap,
  Map
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { Input } from '../components/ui/LayoutComponents';
import api from '../services/api';

type TabType = 'store' | 'delivery' | 'payment' | 'security' | 'notifications' | 'admins';

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState<TabType>('store');
  const [isSaving, setIsSaving] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [user, setUser] = useState<any>(null);

  // Form States - Defaulted to Kadapakkam, Cheyyur godown hub
  const [storeSettings, setStoreSettings] = useState<any>({
    name: 'MaRinaMaRt',
    email: 'support@marinamart.in',
    phone: '+91 9629272964',
    address: 'Godown Hub, Kadapakkam, Cheyyur, Chengalpattu, Tamil Nadu',
    latitude: 12.2818,
    longitude: 79.9905
  });

  const [deliverySettings, setDeliverySettings] = useState({
    baseCharge: 25,
    instantBase: 50,
    perKmCharge: 5,
    freeThreshold: 499,
    openingTime: '06:00',
    closingTime: '23:30',
    isActive: true
  });

  const [paymentSettings, setPaymentSettings] = useState({
    upiId: '9629272964@upi',
    upiPhone: '9629272964',
    upiName: 'MaRinaMaRt',
    customQrUrl: '',
    customGpayUrl: '',
  });

  const [securitySettings, setSecuritySettings] = useState({
    twoFactor: true,
    sessionTimeout: 120,
    failedAttempts: 5
  });

  const [notificationSettings, setNotificationSettings] = useState({
    orderAlerts: true,
    riderAlerts: true,
    weeklyReport: false,
    inventoryAlerts: true
  });

  const [newAdmin, setNewAdmin] = useState({ name: '', email: '', password: '', role: 'Admin' });

  useEffect(() => {
    const userData = localStorage.getItem('user');
    if (userData) setUser(JSON.parse(userData));
    
    // Load from API
    const loadSettings = async () => {
      try {
        const response = await api.get('/settings');
        const data = response.data;
        if (data.store) setStoreSettings(data.store);
        if (data.delivery) setDeliverySettings({ ...deliverySettings, ...data.delivery });
        if (data.payment) setPaymentSettings({ ...paymentSettings, ...data.payment });
        if (data.security) setSecuritySettings(data.security);
        if (data.notifications) setNotificationSettings(data.notifications);
      } catch (err) {
        console.error('Failed to load settings from API:', err);
      }
    };
    
    loadSettings();
  }, []);

  const saveSettings = async () => {
    try {
      setIsSaving(true);
      const payload = {
        store: storeSettings,
        delivery: deliverySettings,
        payment: paymentSettings,
        security: securitySettings,
        notifications: notificationSettings
      };
      
      await api.post('/settings/bulk', payload);
      setShowSuccess(true);
      setTimeout(() => setShowSuccess(false), 3000);
    } catch (err) {
       console.error('Failed to save settings:', err);
       alert('Failed to update system settings.');
    } finally {
       setIsSaving(false);
    }
  };

  const handleCreateAdmin = async () => {
    if (!newAdmin.name || !newAdmin.email || !newAdmin.password) return;
    try {
      setIsSaving(true);
      await api.post('/users', newAdmin);
      setShowSuccess(true);
      setNewAdmin({ name: '', email: '', password: '', role: 'Admin' });
      setTimeout(() => setShowSuccess(false), 3000);
    } catch (err) {
       console.error('Failed to create admin:', err);
       alert('Failed to create admin account.');
    } finally {
       setIsSaving(false);
    }
  };

  const TabButton = ({ id, icon: Icon, label }: { id: TabType, icon: any, label: string }) => (
    <button 
      onClick={() => setActiveTab(id)}
      className={`
        flex items-center gap-2.5 px-4 sm:px-6 py-3 sm:py-3.5 rounded-2xl transition-all duration-300 font-bold text-xs sm:text-sm cursor-pointer whitespace-nowrap
        ${activeTab === id ? 'bg-emerald-600 text-white shadow-lg shadow-emerald-100' : 'bg-slate-50 text-slate-500 hover:bg-slate-100'}
      `}
    >
      <Icon className="w-4 h-4 flex-shrink-0" />
      <span>{label}</span>
    </button>
  );

  return (
    <div className="space-y-6 sm:space-y-8 text-slate-900 relative">
      {/* Floating Success Message */}
      <AnimatePresence>
        {showSuccess && (
          <motion.div 
            initial={{ opacity: 0, y: -50 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -50 }}
            className="fixed top-6 sm:top-10 left-1/2 -translate-x-1/2 z-[200] flex items-center gap-3 px-5 py-3.5 bg-emerald-600 text-white rounded-2xl shadow-2xl shadow-emerald-200 font-bold text-xs sm:text-sm max-w-[90vw]"
          >
            <CheckCircle2 className="w-5 h-5 flex-shrink-0" />
            <span>Changes Saved Successfully!</span>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Header */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold text-slate-900 font-outfit">Platform Settings</h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">Manage store configuration, godown hub location & admin access.</p>
        </div>
      </div>

      {/* Tabs - Horizontal Scroll on Mobile */}
      <div className="flex items-center gap-2 sm:gap-3 bg-white p-3 sm:p-4 rounded-[2rem] border border-slate-100 shadow-sm overflow-x-auto scrollbar-none">
        <TabButton id="store" icon={Store} label="Store Registry" />
        <TabButton id="delivery" icon={Truck} label="Logistics Config" />
        <TabButton id="payment" icon={DollarSign} label="Payment Methods" />
        {user?.role === 'SuperAdmin' && (
           <TabButton id="admins" icon={ShieldAlert} label="Admin Management" />
        )}
        <TabButton id="notifications" icon={Bell} label="Alerts & Info" />
        <TabButton id="security" icon={ShieldCheck} label="Account Stability" />
      </div>

      <motion.div key={activeTab} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} className="grid grid-cols-1 lg:grid-cols-3 gap-6 sm:gap-8">
        <div className="lg:col-span-2 space-y-6 bg-white p-5 sm:p-8 md:p-10 rounded-[2rem] sm:rounded-[2.5rem] border border-slate-100 shadow-sm">
          <AnimatePresence mode="wait">
            {activeTab === 'store' && (
              <motion.div key="store" className="space-y-6 sm:space-y-8">
                 <div className="flex items-center gap-4 mb-2">
                    <div className="p-3 bg-indigo-50 rounded-2xl flex-shrink-0">
                       <Store className="w-6 h-6 text-indigo-600" />
                    </div>
                    <div>
                       <h2 className="text-lg sm:text-xl font-bold text-slate-900 font-outfit">Store & Godown Identity</h2>
                       <p className="text-xs text-slate-400">Kadapakkam, Cheyyur Fulfillment Hub</p>
                    </div>
                 </div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 sm:gap-6">
                    <Input label="Store Name" icon={Store} value={storeSettings.name} onChange={(e: any) => setStoreSettings({...storeSettings, name: e.target.value})} />
                    <Input label="Support Email" icon={Mail} value={storeSettings.email} onChange={(e: any) => setStoreSettings({...storeSettings, email: e.target.value})} />
                    <Input label="Godown Business Address" icon={Store} value={storeSettings.address} onChange={(e: any) => setStoreSettings({...storeSettings, address: e.target.value})} />
                    <Input label="Contact Phone" icon={Store} value={storeSettings.phone} onChange={(e: any) => setStoreSettings({...storeSettings, phone: e.target.value})} />
                    <Input label="Godown Latitude" icon={Map} type="number" step="any" value={storeSettings.latitude} onChange={(e: any) => setStoreSettings({...storeSettings, latitude: Number(e.target.value)})} />
                    <Input label="Godown Longitude" icon={Map} type="number" step="any" value={storeSettings.longitude} onChange={(e: any) => setStoreSettings({...storeSettings, longitude: Number(e.target.value)})} />
                 </div>
                 <div className="flex flex-col sm:flex-row gap-3 pt-2">
                  <button onClick={saveSettings} disabled={isSaving} className="px-6 py-3.5 bg-slate-900 text-white font-bold rounded-2xl hover:bg-slate-800 transition-all flex items-center justify-center gap-2.5 cursor-pointer text-xs sm:text-sm">
                      {isSaving ? <Clock className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
                      Save Identity
                  </button>
                  <button 
                    onClick={() => {
                      setStoreSettings({
                        ...storeSettings,
                        address: 'Godown Hub, Kadapakkam, Cheyyur, Chengalpattu, Tamil Nadu',
                        latitude: 12.2818,
                        longitude: 79.9905
                      });
                    }} 
                    className="px-6 py-3.5 bg-emerald-50 text-emerald-600 font-bold rounded-2xl hover:bg-emerald-100 transition-all flex items-center justify-center gap-2.5 cursor-pointer border border-emerald-100 text-xs sm:text-sm"
                  >
                      <Map className="w-4 h-4" />
                      Set Kadapakkam, Cheyyur Spot
                  </button>
                 </div>
              </motion.div>
            )}

            {activeTab === 'delivery' && (
               <motion.div key="delivery" className="space-y-6 sm:space-y-8">
                  <div className="flex items-center gap-4 mb-2">
                     <div className="p-3 bg-emerald-50 rounded-2xl flex-shrink-0">
                        <Truck className="w-6 h-6 text-emerald-600" />
                     </div>
                     <h2 className="text-lg sm:text-xl font-bold text-slate-900 font-outfit">Logistics & Distance Rules</h2>
                  </div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 sm:gap-6">
                     <Input label="Scheduled Base Delivery (₹)" icon={DollarSign} type="number" value={deliverySettings.baseCharge} onChange={(e: any) => setDeliverySettings({...deliverySettings, baseCharge: Number(e.target.value)})} />
                     <Input label="Instant Delivery Base Fee (₹)" icon={Zap} type="number" value={deliverySettings.instantBase} onChange={(e: any) => setDeliverySettings({...deliverySettings, instantBase: Number(e.target.value)})} />
                     <Input label="Instant Fee Per KM (₹)" icon={TrendingUp} type="number" value={deliverySettings.perKmCharge} onChange={(e: any) => setDeliverySettings({...deliverySettings, perKmCharge: Number(e.target.value)})} />
                     <Input label="Free Scheduled Delivery Threshold (₹)" icon={DollarSign} type="number" value={deliverySettings.freeThreshold} onChange={(e: any) => setDeliverySettings({...deliverySettings, freeThreshold: Number(e.target.value)})} />
                     <Input label="Operating Hours (Opening)" icon={Clock} type="time" value={deliverySettings.openingTime} onChange={(e: any) => setDeliverySettings({...deliverySettings, openingTime: e.target.value})} />
                     <Input label="Operating Hours (Closing)" icon={Clock} type="time" value={deliverySettings.closingTime} onChange={(e: any) => setDeliverySettings({...deliverySettings, closingTime: e.target.value})} />
                  </div>
                  <button onClick={saveSettings} disabled={isSaving} className="px-6 py-3.5 bg-slate-900 text-white font-bold rounded-2xl hover:bg-slate-800 transition-all flex items-center justify-center gap-2.5 cursor-pointer text-xs sm:text-sm w-full sm:w-auto">
                      {isSaving ? <Clock className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
                      Save Logistics Rules
                  </button>
               </motion.div>
            )}

            {activeTab === 'payment' && (
               <motion.div key="payment" className="space-y-6 sm:space-y-8">
                  <div className="flex items-center gap-4 mb-2">
                     <div className="p-3 bg-blue-50 rounded-2xl flex-shrink-0">
                        <DollarSign className="w-6 h-6 text-blue-600" />
                     </div>
                     <h2 className="text-lg sm:text-xl font-bold text-slate-900 font-outfit">UPI & Direct Merchant QR</h2>
                  </div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 sm:gap-6">
                     <Input label="Merchant VPA / UPI ID" icon={DollarSign} value={paymentSettings.upiId} onChange={(e: any) => setPaymentSettings({...paymentSettings, upiId: e.target.value})} />
                     <Input label="Merchant Phone Number" icon={DollarSign} value={paymentSettings.upiPhone} onChange={(e: any) => setPaymentSettings({...paymentSettings, upiPhone: e.target.value})} />
                     <Input label="Payee Display Name" icon={DollarSign} value={paymentSettings.upiName} onChange={(e: any) => setPaymentSettings({...paymentSettings, upiName: e.target.value})} />
                     <Input label="Custom QR Code Image URL" icon={DollarSign} placeholder="https://..." value={paymentSettings.customQrUrl} onChange={(e: any) => setPaymentSettings({...paymentSettings, customQrUrl: e.target.value})} />
                  </div>
                  <button onClick={saveSettings} disabled={isSaving} className="px-6 py-3.5 bg-slate-900 text-white font-bold rounded-2xl hover:bg-slate-800 transition-all flex items-center justify-center gap-2.5 cursor-pointer text-xs sm:text-sm w-full sm:w-auto">
                      {isSaving ? <Clock className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
                      Save Merchant Handles
                  </button>
               </motion.div>
            )}

            {activeTab === 'admins' && user?.role === 'SuperAdmin' && (
               <motion.div key="admins" className="space-y-6 sm:space-y-8">
                  <div className="flex items-center gap-4 mb-2">
                     <div className="p-3 bg-purple-50 rounded-2xl flex-shrink-0">
                        <UserPlus className="w-6 h-6 text-purple-600" />
                     </div>
                     <h2 className="text-lg sm:text-xl font-bold text-slate-900 font-outfit">Create Administrator</h2>
                  </div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 sm:gap-6">
                     <Input label="Full Name" icon={Users} value={newAdmin.name} onChange={(e: any) => setNewAdmin({...newAdmin, name: e.target.value})} />
                     <Input label="Email Address" icon={Mail} value={newAdmin.email} onChange={(e: any) => setNewAdmin({...newAdmin, email: e.target.value})} />
                     <Input label="Secure Password" icon={Key} type="password" value={newAdmin.password} onChange={(e: any) => setNewAdmin({...newAdmin, password: e.target.value})} />
                  </div>
                  <button onClick={handleCreateAdmin} disabled={isSaving} className="px-6 py-3.5 bg-purple-600 hover:bg-purple-700 text-white font-bold rounded-2xl transition-all flex items-center justify-center gap-2.5 cursor-pointer text-xs sm:text-sm w-full sm:w-auto">
                      {isSaving ? <Clock className="w-4 h-4 animate-spin" /> : <UserPlus className="w-4 h-4" />}
                      Create Admin User
                  </button>
               </motion.div>
            )}

            {activeTab === 'notifications' && (
               <motion.div key="notifications" className="space-y-6">
                  <h2 className="text-lg sm:text-xl font-bold text-slate-900 font-outfit mb-4">Notification Preferences</h2>
                  <div className="space-y-4">
                     <div className="flex items-center justify-between p-4 bg-slate-50 rounded-2xl">
                        <div>
                           <p className="font-bold text-xs sm:text-sm text-slate-900">New Order Alerts</p>
                           <p className="text-[10px] sm:text-xs text-slate-400">Receive real-time push for new customer orders</p>
                        </div>
                        <input type="checkbox" checked={notificationSettings.orderAlerts} onChange={(e) => setNotificationSettings({...notificationSettings, orderAlerts: e.target.checked})} className="w-5 h-5 accent-emerald-600 rounded cursor-pointer" />
                     </div>
                     <div className="flex items-center justify-between p-4 bg-slate-50 rounded-2xl">
                        <div>
                           <p className="font-bold text-xs sm:text-sm text-slate-900">Logistics Fleet Alerts</p>
                           <p className="text-[10px] sm:text-xs text-slate-400">Rider assignment & pickup status notifications</p>
                        </div>
                        <input type="checkbox" checked={notificationSettings.riderAlerts} onChange={(e) => setNotificationSettings({...notificationSettings, riderAlerts: e.target.checked})} className="w-5 h-5 accent-emerald-600 rounded cursor-pointer" />
                     </div>
                  </div>
                  <button onClick={saveSettings} disabled={isSaving} className="mt-4 px-6 py-3.5 bg-slate-900 text-white font-bold rounded-2xl hover:bg-slate-800 transition-all flex items-center justify-center gap-2.5 cursor-pointer text-xs sm:text-sm w-full sm:w-auto">
                      {isSaving ? <Clock className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
                      Save Preferences
                  </button>
               </motion.div>
            )}

            {activeTab === 'security' && (
               <motion.div key="security" className="space-y-6">
                  <h2 className="text-lg sm:text-xl font-bold text-slate-900 font-outfit mb-4">Account Security</h2>
                  <div className="space-y-4">
                     <div className="flex items-center justify-between p-4 bg-slate-50 rounded-2xl">
                        <div>
                           <p className="font-bold text-xs sm:text-sm text-slate-900">Two-Factor Authentication</p>
                           <p className="text-[10px] sm:text-xs text-slate-400">Require OTP code for administrative logins</p>
                        </div>
                        <input type="checkbox" checked={securitySettings.twoFactor} onChange={(e) => setSecuritySettings({...securitySettings, twoFactor: e.target.checked})} className="w-5 h-5 accent-emerald-600 rounded cursor-pointer" />
                     </div>
                  </div>
                  <button onClick={saveSettings} disabled={isSaving} className="mt-4 px-6 py-3.5 bg-slate-900 text-white font-bold rounded-2xl hover:bg-slate-800 transition-all flex items-center justify-center gap-2.5 cursor-pointer text-xs sm:text-sm w-full sm:w-auto">
                      {isSaving ? <Clock className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
                      Save Security Options
                  </button>
               </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* System Summary Widget */}
        <div className="bg-slate-900 text-white p-6 sm:p-8 rounded-[2rem] sm:rounded-[2.5rem] shadow-2xl flex flex-col justify-between h-fit">
           <div className="space-y-6">
              <div className="flex items-center gap-3">
                 <div className="w-10 h-10 bg-emerald-500/20 text-emerald-400 rounded-xl flex items-center justify-center">
                    <ShieldCheck className="w-5 h-5" />
                 </div>
                 <div>
                    <h3 className="font-bold text-sm sm:text-base font-outfit">Godown Hub Sync</h3>
                    <p className="text-[10px] text-emerald-400 font-bold uppercase tracking-widest">Active & Operational</p>
                 </div>
              </div>
              <div className="p-4 bg-white/5 rounded-2xl border border-white/10 space-y-2 text-xs">
                 <p className="text-slate-400 font-bold uppercase text-[10px]">Location Spot</p>
                 <p className="font-bold text-white leading-relaxed">Kadapakkam, Cheyyur, Chengalpattu (12.2818, 79.9905)</p>
              </div>
              <div className="p-4 bg-white/5 rounded-2xl border border-white/10 space-y-2 text-xs">
                 <p className="text-slate-400 font-bold uppercase text-[10px]">Active Server Node</p>
                 <p className="font-bold text-emerald-400 truncate">https://marinamart.onrender.com</p>
              </div>
           </div>
        </div>
      </motion.div>
    </div>
  );
}
