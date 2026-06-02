import { useState, useEffect } from 'react';
import { 
  Plus,
  Trash2,
  Type,
  DollarSign,
  Layers,
  Archive, 
  Loader2,
  Image as ImageIcon,
  UploadCloud,
  Edit2
} from 'lucide-react';
import { motion } from 'framer-motion';
import { Modal, Input, Select } from '../components/ui/LayoutComponents';

import { useSearchParams } from 'react-router-dom';

import api from '../services/api';

export default function ProductsPage() {
  const [products, setProducts] = useState<any[]>([]);
  const [categories, setCategories] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [searchParams, setSearchParams] = useSearchParams();
  const [editingProduct, setEditingProduct] = useState<any | null>(null);
  
  const categoryFilter = searchParams.get('category');
  
  const [uploading, setUploading] = useState(false);
  const [imagePreview, setImagePreview] = useState<string | null>(null);

  // Fetch Products & Categories from Backend
  const fetchData = async () => {
    try {
      setLoading(true);
      const [prodRes, catRes] = await Promise.all([
        api.get('/products?all=true'), // Fetch all products including disabled/Off ones
        api.get('/categories')
      ]);
      setProducts(prodRes.data);
      setCategories(catRes.data);
      if (catRes.data.length > 0 && !editingProduct) {
        setNewProduct(prev => ({...prev, category: catRes.data[0].name }));
      }
    } catch (err) {
      console.error('Error fetching data:', err);
    } finally {
      setLoading(false);
    }
  };

  const filteredProducts = categoryFilter 
    ? products.filter(p => p.category === categoryFilter)
    : products;

  // Form State
  const [newProduct, setNewProduct] = useState({
    name: '',
    description: '',
    price: 0,
    originalPrice: 0,
    category: '',
    unit: '1 kg',
    stock: 100,
    images: [] as string[],
    isAvailable: true
  });

  useEffect(() => {
    fetchData();
  }, []);

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Show Preview
    const reader = new FileReader();
    reader.onloadend = () => {
      setImagePreview(reader.result as string);
    };
    reader.readAsDataURL(file);

    // Upload to Backend
    try {
      setUploading(true);
      const formData = new FormData();
      formData.append('file', file);
      
      const res = await api.post('/products/upload', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      
      setNewProduct(prev => ({
        ...prev,
        images: [res.data.url]
      }));
    } catch (err) {
      console.error('Upload failed:', err);
      alert('Failed to upload image');
    } finally {
      setUploading(false);
    }
  };

  const resetForm = () => {
    setEditingProduct(null);
    setNewProduct({
      name: '',
      description: '',
      price: 0,
      originalPrice: 0,
      category: categories.length > 0 ? categories[0].name : '',
      unit: '1 kg',
      stock: 100,
      images: [],
      isAvailable: true
    });
    setImagePreview(null);
    setUploading(false);
  };

  // Handle Add/Edit Product
  const handleSaveProduct = async () => {
    try {
      const payload = {
        ...newProduct,
        price: Number(newProduct.price),
        originalPrice: Number(newProduct.originalPrice || newProduct.price),
        stock: Number(newProduct.stock),
        isAvailable: Boolean(newProduct.isAvailable)
      };
      
      if (editingProduct) {
        await api.put(`/products/${editingProduct.id}`, payload);
      } else {
        await api.post('/products', payload);
      }
      
      setIsAddModalOpen(false);
      fetchData(); // Refresh List
      resetForm();
    } catch (err) {
      console.error('Error saving product:', err);
      alert('Failed to save product. Check backend connection.');
    }
  };

  // Handle Delete Product
  const handleDeleteProduct = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this product?')) return;
    try {
      await api.delete(`/products/${id}`);
      fetchData();
    } catch (err) {
      console.error('Error deleting product:', err);
    }
  };

  // Open modal to edit product details
  const openEditModal = (product: any) => {
    setEditingProduct(product);
    setNewProduct({
      name: product.name,
      description: product.description || '',
      price: product.price,
      originalPrice: product.originalPrice || product.price,
      category: product.category,
      unit: product.unit,
      stock: product.stock,
      images: product.images || [],
      isAvailable: product.isAvailable !== undefined ? product.isAvailable : true
    });
    setImagePreview(product.images?.[0] || null);
    setIsAddModalOpen(true);
  };

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-6">
        <div>
           <div className="flex items-center gap-3">
              <h1 className="text-3xl font-bold text-slate-900 font-outfit">Products Catalog</h1>
              {categoryFilter && (
                <div className="flex items-center gap-2 px-3 py-1 bg-emerald-50 text-emerald-600 rounded-lg border border-emerald-100 text-xs font-bold">
                   <span>Category: {categoryFilter}</span>
                   <button onClick={() => setSearchParams({})} className="hover:text-emerald-800 transition-colors">
                      <Trash2 className="w-3 h-3" />
                   </button>
                </div>
              )}
           </div>
           <p className="text-slate-500 mt-2">Manage your inventory in real-time connected to the cloud.</p>
        </div>
        <div className="flex gap-4">
           {categoryFilter && (
             <button 
                onClick={() => setSearchParams({})}
                className="px-6 py-4 bg-slate-100 text-slate-600 font-bold rounded-2xl hover:bg-slate-200 transition-all font-outfit"
             >
                Show All Products
             </button>
           )}
           <button 
             onClick={() => {
                resetForm();
                setIsAddModalOpen(true);
             }}
             className="flex items-center gap-3 px-8 py-4 bg-emerald-600 text-white font-bold rounded-2xl shadow-xl shadow-emerald-100 hover:bg-emerald-700 transition-all hover:-translate-y-1 font-outfit"
           >
             <Plus className="w-5 h-5" />
             <span>Add New Product</span>
           </button>
        </div>
      </div>

      {/* Table Section */}
      <div className="bg-white rounded-[2.5rem] border border-slate-100 shadow-sm overflow-hidden">
        {loading ? (
          <div className="p-20 flex flex-col items-center justify-center gap-4 text-slate-400">
             <Loader2 className="w-10 h-10 animate-spin text-emerald-500" />
             <p className="font-bold uppercase tracking-widest text-xs">Syncing with Backend...</p>
          </div>
        ) : (
          <table className="w-full text-left">
            <thead className="bg-slate-50 border-b border-slate-50">
               <tr>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Product</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Price Details</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Inventory</th>
                 <th className="px-8 py-6 text-xs font-bold uppercase tracking-wider text-slate-400">Actions</th>
               </tr>
            </thead>
            <tbody className="divide-y divide-slate-50">
              {filteredProducts.map((product) => (
                <motion.tr 
                  key={product.id}
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="hover:bg-emerald-50/10 transition-colors group"
                >
                  <td className="px-8 py-6">
                    <div className="flex items-center gap-5">
                       <div className="w-14 h-14 bg-slate-50 rounded-2xl border border-slate-100 flex items-center justify-center overflow-hidden">
                         <img src={product.images[0]} alt="" className="w-full h-full object-cover" />
                       </div>
                       <div>
                         <p className="font-bold text-slate-900">{product.name}</p>
                         <div className="flex items-center gap-2 mt-1">
                           <p className="text-xs text-slate-400 font-bold uppercase tracking-widest">{product.category}</p>
                           <span className={`text-[9px] font-black uppercase tracking-wider px-1.5 py-0.5 rounded ${product.isAvailable ? 'text-emerald-600 bg-emerald-50' : 'text-rose-500 bg-rose-50'}`}>
                             {product.isAvailable ? 'Active' : 'Off / Inactive'}
                           </span>
                         </div>
                       </div>
                    </div>
                  </td>
                  <td className="px-8 py-6">
                    <div className="flex flex-col">
                      <span className="font-bold text-slate-900">₹{product.price}</span>
                      {product.originalPrice && product.originalPrice > product.price && (
                        <span className="text-xs text-slate-400 line-through">₹{product.originalPrice}</span>
                      )}
                    </div>
                  </td>
                  <td className="px-8 py-6 font-bold text-slate-600">{product.stock} Units</td>
                  <td className="px-8 py-6">
                     <div className="flex gap-2">
                        <button 
                          onClick={() => openEditModal(product)}
                          className="p-3 hover:bg-emerald-50 text-slate-300 hover:text-emerald-600 rounded-2xl transition-all"
                          title="Edit Product"
                        >
                           <Edit2 className="w-4 h-4" />
                        </button>
                        <button 
                          onClick={() => handleDeleteProduct(product.id)}
                          className="p-3 hover:bg-red-50 text-slate-300 hover:text-red-500 rounded-2xl transition-all"
                          title="Delete Product"
                        >
                           <Trash2 className="w-4 h-4" />
                        </button>
                     </div>
                  </td>
                </motion.tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* --- ADD / EDIT PRODUCT MODAL --- */}
      <Modal isOpen={isAddModalOpen} onClose={() => setIsAddModalOpen(false)} title={editingProduct ? "Modify Product Catalog" : "Create New Product"}>
         <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div className="space-y-6">
               <Input 
                 label="Product Name" icon={Type} placeholder="Organic Apples" 
                 value={newProduct.name} onChange={(e: any) => setNewProduct({...newProduct, name: e.target.value})}
               />
               <div className="space-y-2">
                 <label className="text-sm font-bold text-slate-700 ml-1">Product Description</label>
                 <textarea 
                   rows={3}
                   placeholder="Fresh apples from the farm..."
                   className="w-full px-5 py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:outline-none focus:border-emerald-500 focus:bg-white text-sm font-medium transition-all"
                   value={newProduct.description}
                   onChange={(e: any) => setNewProduct({...newProduct, description: e.target.value})}
                 />
               </div>
               <div className="grid grid-cols-2 gap-4">
                  <Input 
                    label="Sale Price (₹)" icon={DollarSign} type="number" 
                    value={newProduct.price} onChange={(e: any) => setNewProduct({...newProduct, price: e.target.value})}
                  />
                  <Input 
                    label="Original Price (₹)" icon={DollarSign} type="number" 
                    value={newProduct.originalPrice} onChange={(e: any) => setNewProduct({...newProduct, originalPrice: e.target.value})}
                  />
               </div>

               {/* Availability Toggle Switch */}
               <div className="flex items-center justify-between p-4 bg-slate-50 rounded-2xl border border-slate-100">
                 <div>
                   <p className="text-sm font-bold text-slate-800">Available Status (On/Off)</p>
                   <p className="text-xs text-slate-400 font-bold uppercase tracking-wider mt-0.5">Show or Hide in User Catalog</p>
                 </div>
                 <button
                   type="button"
                   onClick={() => setNewProduct({...newProduct, isAvailable: !newProduct.isAvailable})}
                   className={`w-14 h-8 rounded-full transition-colors relative focus:outline-none ${newProduct.isAvailable ? 'bg-emerald-600' : 'bg-slate-300'}`}
                 >
                   <span className={`absolute top-1 left-1 bg-white w-6 h-6 rounded-full transition-transform ${newProduct.isAvailable ? 'translate-x-6' : ''}`} />
                 </button>
               </div>
            </div>
            <div className="space-y-6">
               <Select 
                 label="Category" icon={Layers} 
                 value={newProduct.category} onChange={(e: any) => setNewProduct({...newProduct, category: e.target.value})}
                 options={categories.map(cat => ({ label: cat.name, value: cat.name }))}
               />
               <div className="grid grid-cols-2 gap-4">
                 <Input 
                   label="Initial Stock" icon={Archive} type="number" 
                   value={newProduct.stock} onChange={(e: any) => setNewProduct({...newProduct, stock: e.target.value})}
                 />
                 <Input 
                   label="Unit" icon={Archive} placeholder="1 kg" 
                   value={newProduct.unit} onChange={(e: any) => setNewProduct({...newProduct, unit: e.target.value})}
                 />
               </div>
               
               {/* Image Options */}
               <div className="space-y-4">
                 <div className="space-y-2">
                   <label className="text-sm font-bold text-slate-700 flex items-center gap-2">
                     <ImageIcon className="w-4 h-4 text-emerald-500" />
                     Product Image (Upload or URL)
                   </label>
                   
                   {/* URL Input */}
                   <Input 
                     label="Direct Image URL" icon={ImageIcon} placeholder="https://s3.aws.com/image.png"
                     value={newProduct.images[0] || ''} 
                     onChange={(e: any) => {
                       const url = e.target.value;
                       setNewProduct({...newProduct, images: [url]});
                       setImagePreview(url); // Set preview to URL
                     }}
                   />

                   {/* Upload Area */}
                   <div className="relative group">
                      <div className={`
                        h-32 w-full rounded-2xl border-2 border-dashed transition-all flex flex-col items-center justify-center gap-3 overflow-hidden
                        ${imagePreview && !newProduct.images[0]?.startsWith('http') ? 'border-emerald-500 bg-emerald-50/30' : 'border-slate-200 bg-slate-50 hover:border-emerald-300 hover:bg-emerald-50/20'}
                      `}>
                        {imagePreview ? (
                          <>
                            <img src={imagePreview} alt="Preview" className="w-full h-full object-cover" />
                            <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                               <p className="text-white text-xs font-bold px-4 py-2 bg-white/20 backdrop-blur-md rounded-lg">Change File</p>
                            </div>
                          </>
                        ) : (
                          <>
                            <div className="p-2 bg-white rounded-xl shadow-sm group-hover:scale-110 transition-transform">
                               <UploadCloud className="w-5 h-5 text-emerald-500" />
                            </div>
                            <div className="text-center">
                               <p className="text-[11px] font-bold text-slate-700 uppercase tracking-widest">Or Click to upload File</p>
                            </div>
                          </>
                        )}
                        {uploading && (
                          <div className="absolute inset-0 bg-white/80 backdrop-blur-sm flex items-center justify-center gap-3">
                             <Loader2 className="w-5 h-5 animate-spin text-emerald-500" />
                             <span className="text-xs font-bold text-emerald-600">Uploading...</span>
                          </div>
                        )}
                        <input 
                          type="file" 
                          accept="image/*"
                          onChange={handleImageUpload}
                          className="absolute inset-0 opacity-0 cursor-pointer"
                          disabled={uploading}
                        />
                      </div>
                   </div>
                 </div>
               </div>

               <button 
                 onClick={handleSaveProduct}
                 disabled={uploading || !imagePreview || !newProduct.images[0]}
                 className="w-full py-5 bg-emerald-600 text-white font-bold rounded-2xl shadow-xl shadow-emerald-100 mt-auto hover:bg-emerald-700 transition-all disabled:opacity-50 disabled:hover:translate-y-0"
               >
                 {uploading ? 'Processing...' : editingProduct ? 'Save Product Changes' : 'Create Listing'}
               </button>
            </div>
         </div>
      </Modal>
    </div>
  );
}
