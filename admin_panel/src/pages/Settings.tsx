import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { 
  Store, 
  Truck, 
  ShieldCheck, 
  Globe, 
  Mail, 
  MapPin, 
  Phone,
  DollarSign,
  Clock,
  Save,
  CheckCircle2,
  Bell,
  Users,
  UserPlus,
  Key,
  ShieldAlert
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { Input, Select } from '../components/ui/LayoutComponents';

type TabType = 'store' | 'delivery' | 'security' | 'notifications' | 'admins';

import api from '../services/api';

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState<TabType>('store');
  const [isSaving, setIsSaving] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [user, setUser] = useState<any>(null);

  // Admin Form State
  const [newAdmin, setNewAdmin] = useState({ name: '', email: '', password: '', role: 'Admin' });

  useEffect(() => {
    const userData = localStorage.getItem('user');
    if (userData) setUser(JSON.parse(userData));
  }, []);

  const handleCreateAdmin = async () => {
    try {
      setIsSaving(true);
      await api.post('/users', newAdmin);
      setShowSuccess(true);
      setNewAdmin({ name: '', email: '', password: '', role: 'Admin' });
      setTimeout(() => setShowSuccess(false), 3000);
    } catch (err) {
       console.error('Failed to create admin:', err);
    } finally {
       setIsSaving(false);
    }
  };

  const TabButton = ({ id, icon: Icon, label }: { id: TabType, icon: any, label: string }) => (
    <button 
      onClick={() => setActiveTab(id)}
      className={`
        flex items-center gap-3 px-6 py-4 rounded-2xl transition-all duration-300 font-bold text-sm
        ${activeTab === id ? 'bg-emerald-600 text-white shadow-lg shadow-emerald-100' : 'bg-slate-50 text-slate-500 hover:bg-slate-100'}
      `}
    >
      <Icon className="w-4 h-4" />
      {label}
    </button>
  );

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
        <div>
          <h1 className="text-3xl font-bold text-slate-900 font-outfit">Platform Settings</h1>
          <p className="text-slate-500 mt-2">Manage store configuration and administrative access.</p>
        </div>
        <div className="flex items-center gap-4">
           {showSuccess && (
             <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="flex items-center gap-2 px-4 py-2 bg-emerald-50 text-emerald-600 rounded-xl border border-emerald-100 font-bold text-xs">
                <CheckCircle2 className="w-4 h-4" /> Success!
             </motion.div>
           )}
        </div>
      </div>

      <div className="flex flex-wrap gap-4 bg-white p-4 rounded-[2rem] border border-slate-100 shadow-sm">
        <TabButton id="store" icon={Store} label="Store Registry" />
        <TabButton id="delivery" icon={Truck} label="Logistics Config" />
        
        {/* SUPER ADMIN ONLY TAB */}
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
                    <Input label="Store Name" icon={Store} defaultValue="Bloomarina Instamart" />
                    <Input label="Support Email" icon={Mail} defaultValue="support@instamart.co" />
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
                    <Input label="Staff Full Name" icon={Users} value={newAdmin.name} onChange={(e: any) => setNewAdmin({...newAdmin, name: e.target.value})} />
                    <Input label="Administrative Email" icon={Mail} value={newAdmin.email} onChange={(e: any) => setNewAdmin({...newAdmin, email: e.target.value})} />
                    <Input label="Secure Entry Key" icon={Key} type="password" value={newAdmin.password} onChange={(e: any) => setNewAdmin({...newAdmin, password: e.target.value})} />
                    
                    <button 
                      onClick={handleCreateAdmin}
                      disabled={isSaving}
                      className="w-full py-5 bg-emerald-600 text-white font-bold rounded-2xl shadow-xl shadow-emerald-100 hover:bg-emerald-700 transition-all font-outfit mt-4"
                    >
                       Create Admin Account
                    </button>
                 </div>
              </motion.div>
            )}

            {/* Other tabs follow similar pattern... */}
          </AnimatePresence>
        </div>

        {/* Sidebar Info */}
        <div className="space-y-8">
           <div className="bg-slate-900 p-8 rounded-[2.5rem] text-white shadow-2xl">
              <h3 className="text-lg font-bold font-outfit">Security Clearance</h3>
              <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest mt-1">Logged as {user?.name}</p>
              
              <div className="mt-8 p-6 bg-white/5 rounded-2xl border border-white/10 backdrop-blur-sm">
                 <p className="text-xs font-bold text-emerald-400 mb-1">Current Privilege:</p>
                 <p className="text-xl font-black text-white">{user?.role}</p>
                 <p className="text-[10px] text-slate-500 mt-2">Authenticated on Mar 31, 2026</p>
              </div>
           </div>
        </div>
      </motion.div>
    </div>
  );
}
