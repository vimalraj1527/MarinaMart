import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { 
  Layers, 
  Plus, 
  Trash2, 
  Type,
  ImageIcon,
  Loader2
} from 'lucide-react';
import { motion } from 'framer-motion';
import { Modal, Input } from '../components/ui/LayoutComponents';

const API_BASE_URL = 'http://localhost:5001';

export default function CategoriesPage() {
  const [categories, setCategories] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  
  // Form State
  const [newCategory, setNewCategory] = useState({
    name: '',
    image: 'https://placehold.co/400'
  });

  const fetchCategories = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_BASE_URL}/categories`);
      setCategories(response.data);
    } catch (err) {
      console.error('Error fetching categories:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCategories();
  }, []);

  const handleAddCategory = async () => {
    if (!newCategory.name) return;
    try {
      await axios.post(`${API_BASE_URL}/categories`, newCategory);
      setIsAddModalOpen(false);
      fetchCategories();
      setNewCategory({ name: '', image: 'https://placehold.co/400' });
    } catch (err) {
      console.error('Error adding category:', err);
      alert('Failed to add category.');
    }
  };

  const handleDeleteCategory = async (id: string) => {
    if (!window.confirm('Delete this category?')) return;
    try {
      await axios.delete(`${API_BASE_URL}/categories/${id}`);
      fetchCategories();
    } catch (err) {
      console.error('Error deleting category:', err);
    }
  };

  return (
    <div className="space-y-8">
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
        <div>
           <h1 className="text-3xl font-bold text-slate-900 font-outfit">Product Categories</h1>
           <p className="text-slate-500 mt-2">Organize your store catalog for better customer experience.</p>
        </div>
        <button 
          onClick={() => setIsAddModalOpen(true)}
          className="flex items-center gap-3 px-8 py-4 bg-emerald-600 text-white font-bold rounded-2xl shadow-xl shadow-emerald-100 hover:bg-emerald-700 transition-all hover:-translate-y-1"
        >
          <Plus className="w-5 h-5" />
          <span>Add New Category</span>
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        {loading ? (
          <div className="col-span-full py-20 flex flex-col items-center justify-center gap-4 text-slate-400">
             <Loader2 className="w-10 h-10 animate-spin text-emerald-500" />
             <p className="font-bold uppercase tracking-widest text-xs">Loading Categories...</p>
          </div>
        ) : categories.length === 0 ? (
          <div className="col-span-full py-20 text-center text-slate-400 border-2 border-dashed border-slate-100 rounded-[2.5rem]">
             <p>No categories found. Create one to get started.</p>
          </div>
        ) : categories.map((category) => (
          <motion.div 
            key={category.id}
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            className="bg-white p-6 rounded-[2.5rem] border border-slate-100 shadow-sm hover:shadow-xl hover:shadow-emerald-500/5 transition-all group relative"
          >
             <button 
                onClick={() => handleDeleteCategory(category.id)}
                className="absolute top-4 right-4 p-2 bg-red-50 text-red-500 rounded-xl opacity-0 group-hover:opacity-100 transition-opacity"
             >
                <Trash2 className="w-4 h-4" />
             </button>
             
             <div className="w-20 h-20 bg-slate-50 rounded-2xl flex items-center justify-center mb-6 overflow-hidden border border-slate-100">
                <img src={category.image} alt={category.name} className="w-full h-full object-cover" />
             </div>
             <h3 className="text-xl font-bold text-slate-900 mb-1">{category.name}</h3>
             <p className="text-xs font-bold text-slate-400 uppercase tracking-widest">Active Category</p>
          </motion.div>
        ))}
      </div>

      <Modal isOpen={isAddModalOpen} onClose={() => setIsAddModalOpen(false)} title="Create Category">
         <div className="space-y-6">
            <Input 
              label="Category Name" icon={Type} placeholder="e.g. Fruits & Vegetables" 
              value={newCategory.name} onChange={(e: any) => setNewCategory({...newCategory, name: e.target.value})}
            />
            <Input 
              label="Image URL" icon={ImageIcon} placeholder="https://..." 
              value={newCategory.image} onChange={(e: any) => setNewCategory({...newCategory, image: e.target.value})}
            />
            <button 
              onClick={handleAddCategory}
              className="w-full py-5 bg-emerald-600 text-white font-bold rounded-2xl shadow-xl shadow-emerald-100 hover:bg-emerald-700 transition-all"
            >
              Save Category
            </button>
         </div>
      </Modal>
    </div>
  );
}
