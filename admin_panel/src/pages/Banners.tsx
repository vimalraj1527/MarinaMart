import { useState, useEffect } from 'react';
import { 
  Plus, 
  Trash2, 
  Type,
  ImageIcon,
  Loader2,
  Edit2,
  Palette
} from 'lucide-react';
import { motion } from 'framer-motion';
import { Modal, Input } from '../components/ui/LayoutComponents';
import api from '../services/api';

export default function BannersPage() {
  const [banners, setBanners] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingBanner, setEditingBanner] = useState<any>(null);

  const [bannerForm, setBannerForm] = useState({
    title: '',
    color: '0xFF00B894',
    lottieUrl: 'https://assets9.lottiefiles.com/packages/lf20_76m8m1.json'
  });

  const fetchBanners = async () => {
    try {
      setLoading(true);
      const response = await api.get('/banners');
      setBanners(response.data);
    } catch (err) {
      console.error('Error fetching banners:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBanners();
  }, []);

  const handleSaveBanner = async () => {
    if (!bannerForm.title) return;
    try {
      if (editingBanner) {
        await api.put(`/banners/${editingBanner.id}`, bannerForm);
      } else {
        await api.post('/banners', bannerForm);
      }
      setIsModalOpen(false);
      fetchBanners();
      resetForm();
    } catch (err) {
      console.error('Error saving banner:', err);
      alert('Failed to save banner.');
    }
  };

  const handleDeleteBanner = async (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    if (!window.confirm('Delete this banner?')) return;
    try {
      await api.delete(`/banners/${id}`);
      fetchBanners();
    } catch (err) {
      console.error('Error deleting banner:', err);
    }
  };

  const openEditModal = (banner: any, e: React.MouseEvent) => {
    e.stopPropagation();
    setEditingBanner(banner);
    setBannerForm({
      title: banner.title,
      color: banner.color || '0xFF00B894',
      lottieUrl: banner.lottieUrl || 'https://assets9.lottiefiles.com/packages/lf20_76m8m1.json'
    });
    setIsModalOpen(true);
  };

  const resetForm = () => {
    setEditingBanner(null);
    setBannerForm({ title: '', color: '0xFF00B894', lottieUrl: 'https://assets9.lottiefiles.com/packages/lf20_76m8m1.json' });
  };

  return (
    <div className="space-y-8">
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
        <div>
           <h1 className="text-3xl font-bold text-slate-900 font-outfit">Promotional Banners</h1>
           <p className="text-slate-500 mt-2">Manage home screen slider promotions.</p>
        </div>
        <button 
          onClick={() => { resetForm(); setIsModalOpen(true); }}
          className="flex items-center gap-3 px-8 py-4 bg-emerald-600 text-white font-bold rounded-2xl shadow-xl shadow-emerald-100 hover:bg-emerald-700 transition-all hover:-translate-y-1 font-outfit"
        >
          <Plus className="w-5 h-5" />
          <span>Add New Banner</span>
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        {loading ? (
          <div className="col-span-full py-20 flex flex-col items-center justify-center gap-4 text-slate-400">
             <Loader2 className="w-10 h-10 animate-spin text-emerald-500" />
             <p className="font-bold uppercase tracking-widest text-xs">Loading Banners...</p>
          </div>
        ) : banners.length === 0 ? (
          <div className="col-span-full py-20 text-center text-slate-400 border-2 border-dashed border-slate-100 rounded-[2.5rem]">
             <p>No banners found. Create one to get started.</p>
          </div>
        ) : banners.map((banner) => (
          <motion.div 
            key={banner.id}
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            whileHover={{ y: -5 }}
            className="bg-white p-6 rounded-[2.5rem] border border-slate-100 shadow-sm hover:shadow-xl hover:shadow-emerald-500/5 transition-all group relative cursor-pointer"
          >
             <div className="absolute top-4 right-4 flex gap-2">
                <button 
                    onClick={(e) => openEditModal(banner, e)}
                    className="p-2 bg-emerald-50 text-emerald-600 rounded-xl opacity-0 group-hover:opacity-100 transition-opacity hover:bg-emerald-100 z-20"
                >
                    <Edit2 className="w-4 h-4" />
                </button>
                <button 
                    onClick={(e) => handleDeleteBanner(banner.id, e)}
                    className="p-2 bg-red-50 text-red-500 rounded-xl opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-100 z-20"
                >
                    <Trash2 className="w-4 h-4" />
                </button>
             </div>
             
             <div className="w-full h-32 bg-slate-50 rounded-2xl flex items-center justify-center mb-6 overflow-hidden border border-slate-100" style={{ backgroundColor: `#${banner.color.replace('0xFF', '')}` }}>
                 <p className="text-white text-center font-bold px-4 whitespace-pre-wrap">{banner.title}</p>
             </div>
             <h3 className="text-xl font-bold text-slate-900 mb-1">{banner.title.replace('\n', ' ')}</h3>
             <p className="text-xs font-bold text-slate-400 uppercase tracking-widest">Active Banner</p>
          </motion.div>
        ))}
      </div>

      <Modal 
        isOpen={isModalOpen} 
        onClose={() => setIsModalOpen(false)} 
        title={editingBanner ? "Modify Banner" : "New Promotional Banner"}
      >
         <div className="space-y-6">
            <Input 
              label="Banner Title (use \n for line breaks)" icon={Type} placeholder="e.g. Fresh Delivery\nEVERYDAY" 
              value={bannerForm.title} onChange={(e: any) => setBannerForm({...bannerForm, title: e.target.value})}
            />
            <Input 
              label="Color Code (e.g. 0xFF00B894)" icon={Palette} placeholder="0xFF00B894" 
              value={bannerForm.color} onChange={(e: any) => setBannerForm({...bannerForm, color: e.target.value})}
            />
            <Input 
              label="Lottie/Image URL" icon={ImageIcon} placeholder="https://assets9.lottiefiles.com/packages/lf20_76m8m1.json" 
              value={bannerForm.lottieUrl} onChange={(e: any) => setBannerForm({...bannerForm, lottieUrl: e.target.value})}
            />
            
            <button 
              onClick={handleSaveBanner}
              className="w-full py-5 bg-emerald-600 text-white font-bold rounded-2xl shadow-xl shadow-emerald-100 hover:bg-emerald-700 transition-all font-outfit"
            >
              {editingBanner ? "Update Banner" : "Publish Banner"}
            </button>
         </div>
      </Modal>
    </div>
  );
}
