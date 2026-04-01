import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { 
  Plus, 
  Truck, 
  Star, 
  Phone, 
  ShieldCheck, 
  Type, 
  Settings, 
  Loader2,
  ChevronRight
} from 'lucide-react';
import { motion } from 'framer-motion';
import { Modal, Input, Select } from '../components/ui/LayoutComponents';

const API_BASE_URL = 'http://localhost:5001';

export default function RidersPage() {
  const [riders, setRiders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  
  // Rider Form State
  const [newRider, setNewRider] = useState({
    name: '',
    email: '',
    phone: '',
    vehicleType: 'Bike',
    status: 'Available'
  });

  const fetchRiders = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_BASE_URL}/riders`);
      setRiders(response.data);
    } catch (err) {
      console.error('Error fetching riders:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRiders();
  }, []);

  const handleAddRider = async () => {
    try {
      await axios.post(`${API_BASE_URL}/riders`, newRider);
      setIsAddModalOpen(false);
      fetchRiders();
    } catch (err) {
      console.error('Error adding rider:', err);
    }
  };

  return (
    <div className="space-y-8">
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
        <div>
           <h1 className="text-3xl font-bold text-slate-900 font-outfit">Riders Fleet</h1>
           <p className="text-slate-500 mt-2">Manage and monitor your delivery partners in real-time.</p>
        </div>
        <button 
          onClick={() => setIsAddModalOpen(true)}
          className="flex items-center gap-3 px-8 py-4 bg-emerald-600 text-white font-bold rounded-2xl shadow-xl shadow-emerald-100 hover:bg-emerald-700 transition-all hover:-translate-y-1"
        >
          <Plus className="w-5 h-5" />
          <span>Add New Partner</span>
        </button>
      </div>

      <div className="bg-white rounded-[2.5rem] border border-slate-100 shadow-sm overflow-hidden">
        {loading ? (
          <div className="p-20 flex flex-col items-center justify-center gap-4 text-slate-400">
             <Loader2 className="w-10 h-10 animate-spin text-emerald-500" />
             <p className="font-bold uppercase tracking-widest text-xs">Syncing Fleet...</p>
          </div>
        ) : (
          <table className="w-full text-left">
            <thead className="bg-slate-50 border-b border-slate-50">
               <tr>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Rider Identity</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Performance</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Status</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400 text-center">Manage</th>
               </tr>
            </thead>
            <tbody className="divide-y divide-slate-50">
              {riders.map((rider, idx) => (
                <motion.tr key={rider.id} initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="hover:bg-slate-50/50 transition-all">
                  <td className="px-8 py-6">
                    <div className="flex items-center gap-5">
                       <div className="w-12 h-12 bg-emerald-50 rounded-xl flex items-center justify-center font-bold text-emerald-600">
                         {rider.name.charAt(0)}
                       </div>
                       <div>
                         <p className="font-bold text-slate-900">{rider.name}</p>
                         <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">{rider.vehicleType} • {rider.phone}</p>
                       </div>
                    </div>
                  </td>
                  <td className="px-8 py-6">
                    <div className="flex items-center gap-2">
                       <Star className="w-4 h-4 text-amber-500 fill-amber-500" />
                       <span className="font-bold text-slate-900">{rider.rating || '4.5'}</span>
                    </div>
                  </td>
                  <td className="px-8 py-6">
                    <span className={`px-4 py-2 rounded-full text-[10px] font-bold uppercase tracking-widest ${
                       rider.status === 'Available' ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-700'
                    }`}>
                       {rider.status}
                    </span>
                  </td>
                  <td className="px-8 py-6">
                    <div className="flex justify-center gap-2">
                       <button className="p-3 hover:bg-slate-50 text-slate-300 hover:text-slate-900 rounded-2xl transition-all">
                          <Phone className="w-4 h-4" />
                       </button>
                    </div>
                  </td>
                </motion.tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      <Modal isOpen={isAddModalOpen} onClose={() => setIsAddModalOpen(false)} title="Register Delivery Partner">
         <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div className="space-y-6">
               <Input 
                 label="Full name" icon={Type} placeholder="Mike Delivery" 
                 value={newRider.name} onChange={(e: any) => setNewRider({...newRider, name: e.target.value})}
               />
               <Input 
                 label="Email address" icon={Type} type="email" placeholder="mike@example.com" 
                 value={newRider.email} onChange={(e: any) => setNewRider({...newRider, email: e.target.value})}
               />
               <Input 
                 label="Phone number" icon={Phone} placeholder="+1 234 567 890" 
                 value={newRider.phone} onChange={(e: any) => setNewRider({...newRider, phone: e.target.value})}
               />
            </div>
            <div className="space-y-6">
               <Select 
                 label="Vehicle type" icon={Truck} 
                 value={newRider.vehicleType} onChange={(e: any) => setNewRider({...newRider, vehicleType: e.target.value})}
                 options={[
                   { label: 'Bike', value: 'Bike' },
                   { label: 'Scooter', value: 'Scooter' },
                   { label: 'Car', value: 'Car' },
                 ]}
               />
               <button 
                 onClick={handleAddRider}
                 className="w-full py-5 bg-emerald-600 text-white font-bold rounded-2xl shadow-xl shadow-emerald-100 mt-auto hover:bg-emerald-700 transition-all font-outfit"
               >
                 Register Rider
               </button>
               <div className="flex items-center gap-3 text-slate-400 p-2 border-t border-slate-50 mt-4">
                  <ShieldCheck className="w-5 h-5 text-emerald-500" />
                  <p className="text-[10px] font-bold uppercase tracking-widest leading-none">Security screening required</p>
               </div>
            </div>
         </div>
      </Modal>
    </div>
  );
}
