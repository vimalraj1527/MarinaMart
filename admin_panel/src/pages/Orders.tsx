import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { 
  ShoppingBag, 
  MapPin, 
  Truck,
  CheckCircle2,
  Clock,
  ChevronRight,
  ShieldCheck,
  Loader2
} from 'lucide-react';
import { motion } from 'framer-motion';
import { Modal } from '../components/ui/LayoutComponents';

const API_BASE_URL = 'http://localhost:5001';

export default function OrdersPage() {
  const [orders, setOrders] = useState<any[]>([]);
  const [riders, setRiders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [isAssignModalOpen, setIsAssignModalOpen] = useState(false);
  const [selectedOrder, setSelectedOrder] = useState<any>(null);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [ordRes, ridRes] = await Promise.all([
        axios.get(`${API_BASE_URL}/orders`),
        axios.get(`${API_BASE_URL}/riders?status=Available`)
      ]);
      setOrders(ordRes.data);
      setRiders(ridRes.data);
    } catch (err) {
      console.error('Error fetching data:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleAssignRider = async (riderId: string) => {
    try {
      await axios.patch(`${API_BASE_URL}/orders/${selectedOrder.id}/assign/${riderId}`);
      setIsAssignModalOpen(false);
      fetchData();
    } catch (err) {
      console.error('Error assigning rider:', err);
    }
  };

  const updateOrderStatus = async (id: string, status: string) => {
    try {
      await axios.patch(`${API_BASE_URL}/orders/${id}/status`, { status });
      fetchData();
    } catch (err) {
      console.error('Error updating status:', err);
    }
  };

  return (
    <div className="space-y-8">
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
        <div>
           <h1 className="text-3xl font-bold text-slate-900 font-outfit">Live Orders</h1>
           <p className="text-slate-500 mt-2">Monitor and coordinate real-time grocery logistics.</p>
        </div>
      </div>

      <div className="bg-white rounded-[2.5rem] border border-slate-100 shadow-sm overflow-hidden">
        {loading ? (
          <div className="p-20 flex flex-col items-center justify-center gap-4 text-slate-400">
             <Loader2 className="w-10 h-10 animate-spin text-emerald-500" />
             <p className="font-bold uppercase tracking-widest text-xs">Syncing Logistics...</p>
          </div>
        ) : (
          <table className="w-full text-left">
            <thead className="bg-slate-50 border-b border-slate-50">
               <tr>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Order ID & Identity</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Delivery To</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Status</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400 text-center">Manage</th>
               </tr>
            </thead>
            <tbody className="divide-y divide-slate-50">
              {orders.map((order, idx) => (
                <motion.tr key={order.id} initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="hover:bg-slate-50/50 transition-all">
                  <td className="px-8 py-6">
                    <div className="flex items-center gap-4">
                       <div className="p-3 bg-emerald-50 rounded-xl">
                         <ShoppingBag className="w-5 h-5 text-emerald-600" />
                       </div>
                       <div>
                         <p className="font-bold text-slate-900">{order.orderNumber}</p>
                         <p className="text-xs text-slate-400 font-semibold">{order.customerName}</p>
                       </div>
                    </div>
                  </td>
                  <td className="px-8 py-6">
                    <div className="flex flex-col gap-1">
                       <div className="flex items-center gap-2">
                         <MapPin className="w-3.5 h-3.5 text-slate-300" />
                         <span className="text-xs text-slate-600 font-bold">{order.deliveryAddress}</span>
                       </div>
                    </div>
                  </td>
                  <td className="px-8 py-6">
                    <span className={`px-4 py-2 rounded-full text-[10px] font-bold uppercase tracking-widest ${
                       order.status === 'Delivered' ? 'bg-emerald-100 text-emerald-700' : 'bg-blue-100 text-blue-700'
                    }`}>
                       {order.status}
                    </span>
                  </td>
                  <td className="px-8 py-6">
                    <div className="flex justify-center gap-3">
                       {order.status === 'Pending' ? (
                          <button 
                            onClick={() => { setSelectedOrder(order); setIsAssignModalOpen(true); }}
                            className="px-4 py-2 bg-emerald-600 text-white text-[10px] font-bold rounded-xl shadow-lg shadow-emerald-50"
                          >
                             Assign Rider
                          </button>
                       ) : (
                          <div className="flex items-center gap-2 text-xs font-bold text-slate-400">
                             <Truck className="w-3.5 h-3.5 text-emerald-500" />
                             {order.assignedRider?.name || 'Assigned'}
                          </div>
                       )}
                    </div>
                  </td>
                </motion.tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      <Modal isOpen={isAssignModalOpen} onClose={() => setIsAssignModalOpen(false)} title="Select Rider">
         <div className="space-y-4">
            {riders.length > 0 ? riders.map(rider => (
               <div 
                 key={rider.id}
                 onClick={() => handleAssignRider(rider.id)}
                 className="p-5 bg-white border-2 border-slate-50 hover:border-emerald-500 hover:bg-emerald-50/20 rounded-3xl transition-all cursor-pointer flex items-center justify-between"
               >
                  <div className="flex items-center gap-4">
                     <div className="w-12 h-12 bg-slate-100 rounded-xl flex items-center justify-center font-bold text-slate-400">
                        {rider.name.charAt(0)}
                     </div>
                     <div>
                        <p className="font-bold text-slate-900">{rider.name}</p>
                        <p className="text-xs text-slate-400 font-bold uppercase tracking-widest">{rider.vehicleType}</p>
                     </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-slate-400" />
               </div>
            )) : <p className="text-center p-8 text-slate-400 font-bold">No riders available nearby.</p>}
         </div>
      </Modal>
    </div>
  );
}
