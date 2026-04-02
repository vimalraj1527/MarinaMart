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
  
  // Form State
  const [categoryForm, setCategoryForm] = useState({
    name: '',
    image: 'https://placehold.co/400'
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
      image: category.image || 'https://placehold.co/400'
    });
    setIsModalOpen(true);
  };

  const resetForm = () => {
    setEditingCategory(null);
    setCategoryForm({ name: '', image: 'https://placehold.co/400' });
    setUploading(false);
  };

  return (
    <div className="space-y-8">
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
        <div>
           <h1 className="text-3xl font-bold text-slate-900 font-outfit">Product Categories</h1>
           <p className="text-slate-500 mt-2">Organize your store catalog for better customer experience.</p>
        </div>
        <button 
          onClick={() => { resetForm(); setIsModalOpen(true); }}
          className="flex items-center gap-3 px-8 py-4 bg-emerald-600 text-white font-bold rounded-2xl shadow-xl shadow-emerald-100 hover:bg-emerald-700 transition-all hover:-translate-y-1 font-outfit"
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
            whileHover={{ y: -5 }}
            onClick={() => navigate(`/products?category=${category.name}`)}
            className="bg-white p-6 rounded-[2.5rem] border border-slate-100 shadow-sm hover:shadow-xl hover:shadow-emerald-500/5 transition-all group relative cursor-pointer"
          >
             <div className="absolute top-4 right-4 flex gap-2">
                <button 
                    onClick={(e) => openEditModal(category, e)}
                    className="p-2 bg-emerald-50 text-emerald-600 rounded-xl opacity-0 group-hover:opacity-100 transition-opacity hover:bg-emerald-100 z-20"
                >
                    <Edit2 className="w-4 h-4" />
                </button>
                <button 
                    onClick={(e) => handleDeleteCategory(category.id, e)}
                    className="p-2 bg-red-50 text-red-500 rounded-xl opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-100 z-20"
                >
                    <Trash2 className="w-4 h-4" />
                </button>
             </div>
             
             <div className="w-20 h-20 bg-slate-50 rounded-2xl flex items-center justify-center mb-6 overflow-hidden border border-slate-100">
                <img src={category.image} alt={category.name} className="w-full h-full object-cover" />
             </div>
             <h3 className="text-xl font-bold text-slate-900 mb-1">{category.name}</h3>
             <p className="text-xs font-bold text-slate-400 uppercase tracking-widest">Active Category</p>
          </motion.div>
        ))}
      </div>

      <Modal 
        isOpen={isModalOpen} 
        onClose={() => setIsModalOpen(false)} 
        title={editingCategory ? "Modify Repository Category" : "New Catalog Category"}
      >
         <div className="space-y-6">
            <div className="space-y-2">
              <label className="text-sm font-bold text-slate-700 ml-1">Category Illustration</label>
              <div className="flex gap-4">
                <input 
                  type="file" id="cat-image" className="hidden" 
                  onChange={handleFileUpload} accept="image/*"
                />
                <label 
                  htmlFor="cat-image" 
                  className="flex-1 flex items-center justify-center gap-3 py-4 bg-slate-50 border-2 border-dashed border-slate-200 rounded-2xl hover:border-emerald-500 hover:bg-emerald-50/20 transition-all cursor-pointer group"
                >
                  {uploading ? (
                    <>
                      <Loader2 className="w-5 h-5 animate-spin text-emerald-500" />
                      <span className="font-bold text-emerald-600">Uploading Repository Asset...</span>
                    </>
                  ) : (
                    <>
                      <Upload className="w-5 h-5 text-slate-400 group-hover:text-emerald-500" />
                      <span className="font-bold text-slate-500 group-hover:text-emerald-600 font-outfit text-sm">Directly Upload Cloud Photo</span>
                    </>
                  )}
                </label>
              </div>
            </div>
            <Input 
              label="Category Name" icon={Type} placeholder="e.g. Fruits & Vegetables" 
              value={categoryForm.name} onChange={(e: any) => setCategoryForm({...categoryForm, name: e.target.value})}
            />
            <Input 
              label="Image URL (e.g. AWS S3)" icon={ImageIcon} placeholder="https://s3.aws.com/category-icon.png" 
              value={categoryForm.image} onChange={(e: any) => setCategoryForm({...categoryForm, image: e.target.value})}
            />
            {categoryForm.image && (
              <div className="bg-slate-50 p-6 rounded-3xl border border-slate-100 flex flex-col items-center gap-4">
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Photo Preview</p>
                <div className="w-32 h-32 bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
                  <img src={categoryForm.image} alt="Preview" className="w-full h-full object-cover" />
                </div>
              </div>
            )}
            <button 
              onClick={handleSaveCategory}
              className="w-full py-5 bg-emerald-600 text-white font-bold rounded-2xl shadow-xl shadow-emerald-100 hover:bg-emerald-700 transition-all font-outfit"
            >
              {editingCategory ? "Update Repository" : "Establish Category"}
            </button>
         </div>
      </Modal>
    </div>
  );
}
