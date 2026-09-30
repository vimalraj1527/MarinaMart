import { useState, useEffect } from 'react';
import { 
  Plus, 
  Trash2, 
  Type,
  ImageIcon,
  Loader2,
  Edit2,
  Upload
} from 'lucide-react';
import { motion } from 'framer-motion';
import { Modal, Input } from '../components/ui/LayoutComponents';
import api from '../services/api';
import { useNavigate } from 'react-router-dom';
import { formatImageUrl } from '../services/imageUtils';

export default function CategoriesPage() {
  const [categories, setCategories] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingCategory, setEditingCategory] = useState<any>(null);
  const [uploading, setUploading] = useState(false);
  const navigate = useNavigate();

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const formData = new FormData();
    formData.append('file', file);

    try {
      setUploading(true);
      const res = await api.post('/categories/upload', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });
      setCategoryForm({ ...categoryForm, image: res.data.url });
    } catch (err) {
      console.error('Upload failed:', err);
      alert('Photo upload failed.');
    } finally {
      setUploading(false);
    }
  };
  
  const [categoryForm, setCategoryForm] = useState({
    name: '',
    image: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400',
    isActive: true
  });

  const fetchCategories = async () => {
    try {
      setLoading(true);
      const response = await api.get('/categories');
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

  const handleSaveCategory = async () => {
    if (!categoryForm.name) return;
    try {
      if (editingCategory) {
        await api.patch(`/categories/${editingCategory.id}`, categoryForm);
      } else {
        await api.post('/categories', categoryForm);
      }
      setIsModalOpen(false);
      fetchCategories();
      resetForm();
    } catch (err) {
      console.error('Error saving category:', err);
      alert('Failed to save category.');
    }
  };

  const handleDeleteCategory = async (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    if (!window.confirm('Delete this category?')) return;
    try {
      await api.delete(`/categories/${id}`);
      fetchCategories();
    } catch (err) {
      console.error('Error deleting category:', err);
    }
  };

  const openEditModal = (category: any, e: React.MouseEvent) => {
    e.stopPropagation();
    setEditingCategory(category);
    setCategoryForm({
      name: category.name,
      image: category.image || 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400',
      isActive: category.isActive ?? true
    });
    setIsModalOpen(true);
  };

  const openAddModal = () => {
    setEditingCategory(null);
    resetForm();
    setIsModalOpen(true);
  };

  const resetForm = () => {
    setCategoryForm({
      name: '',
      image: 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400',
      isActive: true
    });
  };

  return (
    <div className="space-y-6 sm:space-y-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold text-slate-900 font-outfit">Catalog Categories</h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">Organize your products into shopping departments.</p>
        </div>
        <button 
          onClick={openAddModal}
          className="flex items-center justify-center gap-3 px-6 py-3.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-2xl shadow-lg shadow-emerald-600/20 transition-all cursor-pointer text-xs sm:text-sm w-full sm:w-auto"
        >
          <Plus className="w-5 h-5" />
          <span>New Category</span>
        </button>
      </div>

      {/* Grid Section */}
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 sm:gap-6">
        {loading ? (
          <div className="col-span-full py-16 sm:py-20 flex flex-col items-center justify-center gap-4 text-slate-400">
             <Loader2 className="w-10 h-10 animate-spin text-emerald-500" />
             <p className="font-bold uppercase tracking-widest text-xs">Loading Categories...</p>
          </div>
        ) : categories.length === 0 ? (
          <div className="col-span-full py-16 sm:py-20 text-center text-slate-400 border-2 border-dashed border-slate-100 rounded-[2rem] sm:rounded-[2.5rem]">
             <p className="text-xs sm:text-sm font-semibold">No categories found. Create one to get started.</p>
          </div>
        ) : categories.map((category) => {
          const catImg = formatImageUrl(category.image);
          return (
            <motion.div 
              key={category.id}
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              whileHover={{ y: -5 }}
              onClick={() => navigate(`/products?category=${category.name}`)}
              className="bg-white p-5 sm:p-6 rounded-[2rem] sm:rounded-[2.5rem] border border-slate-100 shadow-sm hover:shadow-xl hover:shadow-emerald-500/5 transition-all group relative cursor-pointer"
            >
               <div className="absolute top-4 right-4 flex gap-2 z-20">
                  <button 
                      onClick={(e) => openEditModal(category, e)}
                      className="p-2 bg-emerald-50 text-emerald-600 rounded-xl transition-all hover:bg-emerald-100 cursor-pointer shadow-sm"
                      title="Edit Category"
                  >
                      <Edit2 className="w-4 h-4" />
                  </button>
                  <button 
                      onClick={(e) => handleDeleteCategory(category.id, e)}
                      className="p-2 bg-red-50 text-red-500 rounded-xl transition-all hover:bg-red-100 cursor-pointer shadow-sm"
                      title="Delete Category"
                  >
                      <Trash2 className="w-4 h-4" />
                  </button>
               </div>
               
               <div className="w-16 h-16 sm:w-20 sm:h-20 bg-slate-50 rounded-2xl flex items-center justify-center mb-4 sm:mb-6 overflow-hidden border border-slate-100">
                  <img 
                    src={catImg} 
                    alt={category.name} 
                    className="w-full h-full object-cover" 
                    onError={(e: any) => {
                      e.target.onerror = null;
                      e.target.src = 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400';
                    }}
                  />
               </div>
               <h3 className="text-lg sm:text-xl font-bold text-slate-900 mb-2 truncate pr-16">{category.name}</h3>
               <span className={`inline-block text-[10px] font-black uppercase tracking-widest px-3 py-1 rounded-xl ${category.isActive ? 'text-emerald-600 bg-emerald-50' : 'text-slate-400 bg-slate-100'}`}>
                 {category.isActive ? 'Active' : 'Off'}
               </span>
            </motion.div>
          );
        })}
      </div>

      <Modal 
        isOpen={isModalOpen} 
        onClose={() => setIsModalOpen(false)} 
        title={editingCategory ? "Modify Repository Category" : "New Catalog Category"}
      >
         <div className="space-y-5 sm:space-y-6">
            <div className="space-y-2">
              <label className="text-xs sm:text-sm font-bold text-slate-700 ml-1">Category Illustration</label>
              <div className="flex flex-col sm:flex-row gap-3">
                <input 
                  type="file" id="cat-image" className="hidden" 
                  onChange={handleFileUpload} accept="image/*"
                />
                <label 
                  htmlFor="cat-image" 
                  className="flex-1 flex items-center justify-center gap-3 py-3.5 sm:py-4 bg-slate-50 border-2 border-dashed border-slate-200 rounded-2xl hover:border-emerald-500 hover:bg-emerald-50/20 transition-all cursor-pointer group"
                >
                  {uploading ? (
                    <>
                      <Loader2 className="w-5 h-5 animate-spin text-emerald-500" />
                      <span className="font-bold text-emerald-600 text-xs sm:text-sm">Uploading photo...</span>
                    </>
                  ) : (
                    <>
                      <Upload className="w-5 h-5 text-slate-400 group-hover:text-emerald-500" />
                      <span className="font-bold text-slate-500 group-hover:text-emerald-600 font-outfit text-xs sm:text-sm">Upload Photo</span>
                    </>
                  )}
                </label>
              </div>
            </div>

            <Input 
              label="Category Image URL" icon={ImageIcon} placeholder="https://..." 
              value={categoryForm.image} onChange={(e: any) => setCategoryForm({...categoryForm, image: e.target.value})}
            />

            {categoryForm.image && (
              <div className="relative w-20 h-20 rounded-2xl overflow-hidden border border-slate-100">
                <img 
                  src={formatImageUrl(categoryForm.image)} 
                  alt="Preview" 
                  className="w-full h-full object-cover" 
                  onError={(e: any) => {
                    e.target.onerror = null;
                    e.target.src = 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400';
                  }}
                />
              </div>
            )}

            <Input 
              label="Category Name" icon={Type} placeholder="e.g. Fresh Fruits & Vegetables" 
              value={categoryForm.name} onChange={(e: any) => setCategoryForm({...categoryForm, name: e.target.value})}
            />

            <div className="flex items-center justify-between p-4 bg-slate-50 border border-slate-100 rounded-2xl">
              <div>
                <p className="text-xs sm:text-sm font-bold text-slate-900">Active Visibility</p>
                <p className="text-[10px] sm:text-xs text-slate-400 font-medium">Show category in customer app navigation</p>
              </div>
              <input 
                type="checkbox"
                checked={categoryForm.isActive}
                onChange={(e) => setCategoryForm({...categoryForm, isActive: e.target.checked})}
                className="w-5 h-5 accent-emerald-600 rounded cursor-pointer"
              />
            </div>

            <div className="pt-4 flex gap-4">
              <button 
                onClick={() => setIsModalOpen(false)}
                className="flex-1 py-3.5 bg-slate-100 hover:bg-slate-200 text-slate-600 font-bold rounded-2xl text-xs sm:text-sm transition-all cursor-pointer"
              >
                Cancel
              </button>
              <button 
                onClick={handleSaveCategory}
                className="flex-1 py-3.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-2xl text-xs sm:text-sm shadow-lg shadow-emerald-600/20 transition-all cursor-pointer"
              >
                {editingCategory ? "Update Category" : "Save Category"}
              </button>
            </div>
         </div>
      </Modal>
    </div>
  );
}
