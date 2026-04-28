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

type TabType = 'store' | 'delivery' | 'security' | 'notifications' | 'admins';

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState<TabType>('store');
  const [isSaving, setIsSaving] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [user, setUser] = useState<any>(null);

  // Form States
  const [storeSettings, setStoreSettings] = useState<any>({
    name: 'Bloomarina Instamart',
    email: 'support@instamart.co',
    phone: '+91 9876543210',
    address: '123 Cloud St, Silicon Valley, CA',
    latitude: 12.9716,
    longitude: 77.5946
  });

  const [deliverySettings, setDeliverySettings] = useState({
    baseCharge: 25, // Scheduled Flat Fee
    instantBase: 50, // Instant Base Fee
    perKmCharge: 5,  // Instant Per KM
    freeThreshold: 499,
    openingTime: '06:00',
    closingTime: '23:30',
    isActive: true
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
        // Merge with defaults to handle new fields gracefully
        if (data.delivery) setDeliverySettings({ ...deliverySettings, ...data.delivery });
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
      await api.post('/settings/bulk', {
        store: storeSettings,
        delivery: deliverySettings,
        security: securitySettings,
        notifications: notificationSettings
      });
      
      setShowSuccess(true);
      setTimeout(() => setShowSuccess(false), 3000);
    } catch (err) {
      console.error('Failed to save settings:', err);
      alert("Failed to sync platform rules to server.");
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
        flex items-center gap-3 px-6 py-4 rounded-2xl transition-all duration-300 font-bold text-sm cursor-pointer
        ${activeTab === id ? 'bg-emerald-600 text-white shadow-lg shadow-emerald-100' : 'bg-slate-50 text-slate-500 hover:bg-slate-100'}
      `}
    >
      <Icon className="w-4 h-4" />
      {label}
    </button>
  );

  return (
    <div className="space-y-8 text-slate-900 relative">
      {/* Floating Success Message */}
      <AnimatePresence>
        {showSuccess && (
          <motion.div 
            initial={{ opacity: 0, y: -50 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -50 }}
            className="fixed top-10 left-1/2 -translate-x-1/2 z-[200] flex items-center gap-3 px-6 py-4 bg-emerald-600 text-white rounded-2xl shadow-2xl shadow-emerald-200 font-bold"
          >
            <CheckCircle2 className="w-5 h-5" />
            <span>Changes Saved Successfully!</span>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Header */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
        <div>
          <h1 className="text-3xl font-bold text-slate-900 font-outfit">Platform Settings</h1>
          <p className="text-slate-500 mt-2">Manage store configuration and administrative access.</p>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex flex-wrap gap-4 bg-white p-4 rounded-[2rem] border border-slate-100 shadow-sm">
        <TabButton id="store" icon={Store} label="Store Registry" />
        <TabButton id="delivery" icon={Truck} label="Logistics Config" />
        {user?.role === 'SuperAdmin' && (
           <TabButton id="admins" icon={ShieldAlert} label="Admin Management" />
        )}
        <TabButton id="notifications" icon={Bell} label="Alerts & Info" />
        <TabButton id="security" icon={ShieldCheck} label="Account Stability" />
      </div>

      <motion.div key={activeTab} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 space-y-6 bg-white p-10 rounded-[2.5rem] border border-slate-100 shadow-sm">
          <AnimatePresence mode="wait">
            {activeTab === 'store' && (
              <motion.div key="store" className="space-y-8">
                 <div className="flex items-center gap-4 mb-4">
                    <div className="p-3 bg-indigo-50 rounded-2xl">
                       <Store className="w-6 h-6 text-indigo-600" />
                    </div>
                    <h2 className="text-xl font-bold text-slate-900 font-outfit">Store Identity</h2>
                 </div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <Input label="Store Name" icon={Store} value={storeSettings.name} onChange={(e: any) => setStoreSettings({...storeSettings, name: e.target.value})} />
                    <Input label="Support Email" icon={Mail} value={storeSettings.email} onChange={(e: any) => setStoreSettings({...storeSettings, email: e.target.value})} />
                    <Input label="Business Address" icon={Store} value={storeSettings.address} onChange={(e: any) => setStoreSettings({...storeSettings, address: e.target.value})} />
                    <Input label="Contact Phone" icon={Store} value={storeSettings.phone} onChange={(e: any) => setStoreSettings({...storeSettings, phone: e.target.value})} />
                    <Input label="Store Latitude" icon={Map} type="number" step="any" value={storeSettings.latitude} onChange={(e: any) => setStoreSettings({...storeSettings, latitude: Number(e.target.value)})} />
                    <Input label="Store Longitude" icon={Map} type="number" step="any" value={storeSettings.longitude} onChange={(e: any) => setStoreSettings({...storeSettings, longitude: Number(e.target.value)})} />
                 </div>
                 <div className="flex gap-4">
                  <button onClick={saveSettings} disabled={isSaving} className="mt-4 px-8 py-4 bg-slate-900 text-white font-bold rounded-2xl hover:bg-slate-800 transition-all flex items-center gap-3 cursor-pointer">
                      {isSaving ? <Clock className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
                      Save Identity
                  </button>
                  <button 
                    onClick={() => {
                      if (navigator.geolocation) {
                        navigator.geolocation.getCurrentPosition((pos) => {
                          setStoreSettings({...storeSettings, latitude: pos.coords.latitude, longitude: pos.coords.longitude});
                        });
                      }
                    }} 
                    className="mt-4 px-8 py-4 bg-emerald-50 text-emerald-600 font-bold rounded-2xl hover:bg-emerald-100 transition-all flex items-center gap-3 cursor-pointer border border-emerald-100"
                  >
                      <Map className="w-4 h-4" />
                      Set to Current Location
                  </button>
                 </div>
              </motion.div>
            )}

            {activeTab === 'delivery' && (
              <motion.div key="delivery" className="space-y-8">
                 <div className="flex items-center gap-4 mb-4">
                    <div className="p-3 bg-blue-50 rounded-2xl">
                       <Truck className="w-6 h-6 text-blue-600" />
                    </div>
                    <h2 className="text-xl font-bold text-slate-900 font-outfit">Logistics Configuration</h2>
                 </div>
                 
                 <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="space-y-6">
                       <h3 className="text-sm font-black uppercase tracking-widest text-slate-400">General Billing</h3>
                       <Input label="Scheduled Delivery Fee (₹)" icon={DollarSign} type="number" value={deliverySettings.baseCharge} onChange={(e: any) => setDeliverySettings({...deliverySettings, baseCharge: Number(e.target.value)})} />
                       <Input label="Free Delivery Above (₹)" icon={TrendingUp} type="number" value={deliverySettings.freeThreshold} onChange={(e: any) => setDeliverySettings({...deliverySettings, freeThreshold: Number(e.target.value)})} />
                    </div>

                    <div className="space-y-6">
                       <h3 className="text-sm font-black uppercase tracking-widest text-slate-400">Instant Delivery Logic</h3>
                       <Input label="Instant Base Fee (₹)" icon={Zap} type="number" value={deliverySettings.instantBase} onChange={(e: any) => setDeliverySettings({...deliverySettings, instantBase: Number(e.target.value)})} />
                       <Input label="Charge per Kilometer (₹)" icon={Map} type="number" value={deliverySettings.perKmCharge} onChange={(e: any) => setDeliverySettings({...deliverySettings, perKmCharge: Number(e.target.value)})} />
                    </div>
                 </div>

                 <div className="grid grid-cols-1 md:grid-cols-2 gap-6 pt-6 border-t border-slate-50">
                    <Input label="Opening Hours" icon={Clock} type="time" value={deliverySettings.openingTime} onChange={(e: any) => setDeliverySettings({...deliverySettings, openingTime: e.target.value})} />
                    <Input label="Closing Hours" icon={Clock} type="time" value={deliverySettings.closingTime} onChange={(e: any) => setDeliverySettings({...deliverySettings, closingTime: e.target.value})} />
                 </div>

                 <button onClick={saveSettings} disabled={isSaving} className="mt-4 px-8 py-4 bg-slate-900 text-white font-bold rounded-2xl hover:bg-slate-800 transition-all flex items-center gap-3 cursor-pointer">
                    {isSaving ? <Clock className="w-4 h-4 animate-spin" /> : <Save className="w-4 h-4" />}
                    Save Logistics Engine
                 </button>
              </motion.div>
            )}

            {activeTab === 'notifications' && (
              <motion.div key="notifications" className="space-y-8">
                 <div className="flex items-center gap-4 mb-4">
                    <div className="p-3 bg-amber-50 rounded-2xl">
                       <Bell className="w-6 h-6 text-amber-600" />
                    </div>
                    <h2 className="text-xl font-bold text-slate-900 font-outfit">Notification Preferences</h2>
                 </div>
                 <div className="space-y-4">
                    {Object.entries(notificationSettings).map(([key, val]) => (
                      <div key={key} className="flex items-center justify-between p-6 bg-slate-50 rounded-2xl border border-slate-100">
                         <div>
                            <p className="font-bold text-slate-900 capitalize">{key.replace(/([A-Z])/g, ' $1')}</p>
                            <p className="text-xs text-slate-400">Receive system alerts for {key}.</p>
                         </div>
                         <button 
                           onClick={() => setNotificationSettings({...notificationSettings, [key]: !val})}
                           className={`w-12 h-6 rounded-full transition-all relative cursor-pointer ${val ? 'bg-emerald-500' : 'bg-slate-300'}`}
                         >
                            <div className={`absolute top-1 w-4 h-4 rounded-full bg-white transition-all ${val ? 'right-1' : 'left-1'}`} />
                         </button>
                      </div>
                    ))}
                 </div>
                 <button onClick={saveSettings} disabled={isSaving} className="px-8 py-4 bg-slate-900 text-white font-bold rounded-2xl hover:bg-slate-800 transition-all flex items-center gap-3 cursor-pointer">
                    Save Alerts
                 </button>
              </motion.div>
            )}

            {activeTab === 'security' && (
              <motion.div key="security" className="space-y-8">
                 <div className="flex items-center gap-4 mb-4">
                    <div className="p-3 bg-rose-50 rounded-2xl">
                       <ShieldCheck className="w-6 h-6 text-rose-600" />
                    </div>
                    <h2 className="text-xl font-bold text-slate-900 font-outfit">Account Stability</h2>
                 </div>
                 <div className="space-y-6">
                    <div className="p-8 bg-slate-900 rounded-[2rem]">
                       <h3 className="text-white font-bold mb-4">Update Access Key</h3>
                       <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                          <Input label="New Password" type="password" icon={Key} placeholder="Enter new password" />
                          <Input label="Confirm Password" type="password" icon={Key} placeholder="Confirm password" />
                       </div>
                       <button onClick={saveSettings} className="mt-6 px-6 py-3 bg-rose-500 text-white font-bold rounded-xl text-sm hover:bg-rose-600 transition-all cursor-pointer">
                          Update Password
                       </button>
                    </div>
                 </div>
              </motion.div>
            )}

            {activeTab === 'admins' && user?.role === 'SuperAdmin' && (
              <motion.div key="admins" className="space-y-8">
                <div className="flex items-center gap-4 mb-4">
                    <div className="p-3 bg-emerald-50 rounded-2xl">
                       <UserPlus className="w-6 h-6 text-emerald-600" />
                    </div>
                    <div>
                       <h2 className="text-xl font-bold text-slate-900 font-outfit">New Administrative Staff</h2>
                       <p className="text-xs text-slate-400 font-bold uppercase tracking-widest mt-1">SuperAdmin Privilege</p>
                    </div>
                 </div>
                 <div className="grid grid-cols-1 gap-6 bg-slate-50 p-8 rounded-3xl border border-slate-100">
                    <Input label="Full Name" icon={Users} value={newAdmin.name} onChange={(e: any) => setNewAdmin({...newAdmin, name: e.target.value})} />
                    <Input label="Email Address" icon={Mail} value={newAdmin.email} onChange={(e: any) => setNewAdmin({...newAdmin, email: e.target.value})} />
                    <Input label="Access Password" icon={Key} type="password" value={newAdmin.password} onChange={(e: any) => setNewAdmin({...newAdmin, password: e.target.value})} />
                    <button onClick={handleCreateAdmin} disabled={isSaving} className="w-full py-5 bg-emerald-600 text-white font-bold rounded-2xl shadow-xl shadow-emerald-100 hover:bg-emerald-700 transition-all font-outfit mt-4 cursor-pointer">
                       Create Admin Account
                    </button>
                 </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* Sidebar Info */}
        <div className="space-y-8">
           <div className="bg-slate-900 p-8 rounded-[2.5rem] text-white shadow-2xl">
              <h3 className="text-lg font-bold font-outfit">Session Context</h3>
              <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mt-1">Status: Active Registry</p>
              <div className="mt-8 p-6 bg-white/5 rounded-2xl border border-white/10 backdrop-blur-sm">
                 <p className="text-xs font-bold text-emerald-400 mb-1">Authenticated as:</p>
                 <p className="text-xl font-black text-white">{user?.name}</p>
                 <p className="text-[10px] text-slate-500 mt-2">Role: {user?.role}</p>
              </div>
           </div>
        </div>
      </motion.div>
    </div>
  );
}
