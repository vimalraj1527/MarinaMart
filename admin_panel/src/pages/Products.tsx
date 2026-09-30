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
import { formatImageUrl } from '../services/imageUtils';

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

  const fetchData = async () => {
    try {
      setLoading(true);
      const [prodRes, catRes] = await Promise.all([
        api.get('/products?all=true'),
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

    const reader = new FileReader();
    reader.onloadend = () => {
      setImagePreview(reader.result as string);
    };
    reader.readAsDataURL(file);

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
      console.error('Failed to upload photo:', err);
      alert('Photo upload failed.');
    } finally {
      setUploading(false);
    }
  };

  const handleAddProduct = async () => {
    if (!newProduct.name || !newProduct.price) {
       alert('Please provide product name and price.');
       return;
    }
    try {
       if (editingProduct) {
          await api.patch(`/products/${editingProduct.id}`, newProduct);
       } else {
          await api.post('/products', newProduct);
       }
       setIsAddModalOpen(false);
       setEditingProduct(null);
       fetchData();
       resetForm();
    } catch (err) {
       console.error('Error saving product:', err);
       alert('Failed to save product.');
    }
  };

  const handleDeleteProduct = async (id: string) => {
    if (!window.confirm("Delete this inventory item permanently?")) return;
    try {
       await api.delete(`/products/${id}`);
       fetchData();
    } catch (err) {
       console.error('Error deleting product:', err);
       alert('Failed to delete item.');
    }
  };

  const openAddModal = () => {
     setEditingProduct(null);
     resetForm();
     setIsAddModalOpen(true);
  };

  const openEditModal = (product: any) => {
     setEditingProduct(product);
     setNewProduct({
        name: product.name || '',
        description: product.description || '',
        price: product.price || 0,
        originalPrice: product.originalPrice || 0,
        category: product.category || (categories[0]?.name || ''),
        unit: product.unit || '1 kg',
        stock: product.stock || 100,
        images: product.images || [product.image] || [],
        isAvailable: product.isAvailable !== false
     });
     setImagePreview(formatImageUrl(product.images?.[0] || product.image));
     setIsAddModalOpen(true);
  };

  const resetForm = () => {
     setNewProduct({
        name: '',
        description: '',
        price: 0,
        originalPrice: 0,
        category: categories[0]?.name || '',
        unit: '1 kg',
        stock: 100,
        images: [],
        isAvailable: true
     });
     setImagePreview(null);
  };

  return (
    <div className="space-y-6 sm:space-y-8">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold text-slate-900 font-outfit">Product Management</h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">Manage items, stock counts, pricing, and availability.</p>
        </div>
        <button 
          onClick={openAddModal}
          className="flex items-center justify-center gap-3 px-6 py-3.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-2xl shadow-lg shadow-emerald-600/20 transition-all cursor-pointer text-sm w-full sm:w-auto"
        >
          <Plus className="w-5 h-5" />
          <span>Add New Item</span>
        </button>
      </div>

      {/* Category Pills Filter */}
      {categories.length > 0 && (
         <div className="flex items-center gap-2 overflow-x-auto pb-2 scrollbar-none">
            <button
               onClick={() => setSearchParams({})}
               className={`px-4 py-2 rounded-xl text-xs font-bold transition-all whitespace-nowrap cursor-pointer ${!categoryFilter ? 'bg-emerald-600 text-white shadow-md shadow-emerald-600/20' : 'bg-white text-slate-600 hover:bg-slate-50 border border-slate-100'}`}
            >
               All Categories ({products.length})
            </button>
            {categories.map((c) => {
               const count = products.filter(p => p.category === c.name).length;
               const isSel = categoryFilter === c.name;
               return (
                  <button
                     key={c.id}
                     onClick={() => setSearchParams({ category: c.name })}
                     className={`px-4 py-2 rounded-xl text-xs font-bold transition-all whitespace-nowrap cursor-pointer ${isSel ? 'bg-emerald-600 text-white shadow-md shadow-emerald-600/20' : 'bg-white text-slate-600 hover:bg-slate-50 border border-slate-100'}`}
                  >
                     {c.name} ({count})
                  </button>
               );
            })}
         </div>
      )}

      {/* Table Section */}
      <div className="bg-white rounded-[2rem] sm:rounded-[2.5rem] border border-slate-100 shadow-sm overflow-hidden">
        {loading ? (
          <div className="p-16 sm:p-20 flex flex-col items-center justify-center gap-4 text-slate-400">
             <Loader2 className="w-10 h-10 animate-spin text-emerald-500" />
             <p className="font-bold uppercase tracking-widest text-xs">Syncing with Backend...</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left min-w-[650px]">
              <thead className="bg-slate-50 border-b border-slate-50">
                 <tr>
                   <th className="px-6 sm:px-8 py-5 text-xs font-bold uppercase tracking-wider text-slate-400">Product</th>
                   <th className="px-6 sm:px-8 py-5 text-xs font-bold uppercase tracking-wider text-slate-400">Price Details</th>
                   <th className="px-6 sm:px-8 py-5 text-xs font-bold uppercase tracking-wider text-slate-400">Inventory</th>
                   <th className="px-6 sm:px-8 py-5 text-xs font-bold uppercase tracking-wider text-slate-400">Actions</th>
                 </tr>
              </thead>
              <tbody className="divide-y divide-slate-50">
                {filteredProducts.map((product) => {
                  const imgUrl = formatImageUrl(product.images?.[0] || product.image);
                  return (
                    <motion.tr 
                      key={product.id}
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      className="hover:bg-emerald-50/10 transition-colors group"
                    >
                      <td className="px-6 sm:px-8 py-5">
                        <div className="flex items-center gap-4 sm:gap-5">
                           <div className="w-12 h-12 sm:w-14 sm:h-14 bg-slate-50 rounded-2xl border border-slate-100 flex items-center justify-center overflow-hidden flex-shrink-0">
                             <img 
                               src={imgUrl} 
                               alt={product.name} 
                               className="w-full h-full object-cover" 
                               onError={(e: any) => {
                                 e.target.onerror = null;
                                 e.target.src = 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400';
                               }}
                             />
                           </div>
                           <div>
                             <p className="font-bold text-slate-900 text-xs sm:text-sm">{product.name}</p>
                             <div className="flex items-center gap-2 mt-1 flex-wrap">
                               <p className="text-[10px] sm:text-xs text-slate-400 font-bold uppercase tracking-widest">{product.category}</p>
                               <span className={`text-[9px] font-black uppercase tracking-wider px-1.5 py-0.5 rounded ${product.isAvailable ? 'text-emerald-600 bg-emerald-50' : 'text-rose-500 bg-rose-50'}`}>
                                 {product.isAvailable ? 'Active' : 'Off'}
                               </span>
                             </div>
                           </div>
                        </div>
                      </td>
                      <td className="px-6 sm:px-8 py-5">
                        <div className="flex flex-col">
                          <span className="font-bold text-slate-900 text-xs sm:text-sm">₹{product.price}</span>
                          {product.originalPrice && product.originalPrice > product.price && (
                            <span className="text-[10px] sm:text-xs text-slate-400 line-through">₹{product.originalPrice}</span>
                          )}
                        </div>
                      </td>
                      <td className="px-6 sm:px-8 py-5 font-bold text-slate-600 text-xs sm:text-sm">{product.stock} Units</td>
                      <td className="px-6 sm:px-8 py-5">
                         <div className="flex gap-2">
                            <button 
                              onClick={() => openEditModal(product)}
                              className="p-2.5 sm:p-3 hover:bg-emerald-50 text-slate-400 hover:text-emerald-600 rounded-xl transition-all cursor-pointer"
                              title="Edit Product"
                            >
                               <Edit2 className="w-4 h-4" />
                            </button>
                            <button 
                              onClick={() => handleDeleteProduct(product.id)}
                              className="p-2.5 sm:p-3 hover:bg-red-50 text-slate-400 hover:text-red-500 rounded-xl transition-all cursor-pointer"
                              title="Delete Product"
                            >
                               <Trash2 className="w-4 h-4" />
                            </button>
                         </div>
                      </td>
                    </motion.tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* --- ADD / EDIT PRODUCT MODAL --- */}
      <Modal isOpen={isAddModalOpen} onClose={() => setIsAddModalOpen(false)} title={editingProduct ? "Modify Product Catalog" : "Create New Product"}>
         <div className="grid grid-cols-1 md:grid-cols-2 gap-6 sm:gap-8">
            <div className="space-y-5 sm:space-y-6">
               <Input 
                 label="Product Name" icon={Type} placeholder="Organic Apples" 
                 value={newProduct.name} onChange={(e: any) => setNewProduct({...newProduct, name: e.target.value})}
               />
               <div className="space-y-2">
                 <label className="text-xs sm:text-sm font-bold text-slate-700 ml-1">Product Description</label>
                 <textarea 
                   rows={3}
                   placeholder="Fresh apples from the farm..."
                   className="w-full px-4 sm:px-5 py-3 sm:py-4 bg-slate-50 border border-slate-100 rounded-2xl focus:outline-none focus:border-emerald-500 focus:bg-white text-xs sm:text-sm font-medium transition-all"
                   value={newProduct.description}
                   onChange={(e: any) => setNewProduct({...newProduct, description: e.target.value})}
                 />
               </div>
               <div className="grid grid-cols-2 gap-4">
                  <Input 
                    label="Sale Price (₹)" icon={DollarSign} type="number" 
                    value={newProduct.price} onChange={(e: any) => setNewProduct({...newProduct, price: parseFloat(e.target.value) || 0})}
                  />
                  <Input 
                    label="Original Price (₹)" icon={DollarSign} type="number" 
                    value={newProduct.originalPrice} onChange={(e: any) => setNewProduct({...newProduct, originalPrice: parseFloat(e.target.value) || 0})}
                  />
               </div>
               <div className="grid grid-cols-2 gap-4">
                  <Select 
                     label="Category" icon={Layers}
                     value={newProduct.category}
                     onChange={(e: any) => setNewProduct({...newProduct, category: e.target.value})}
                     options={categories.map(c => ({ label: c.name, value: c.name }))}
                  />
                  <Input 
                     label="Quantity Unit" icon={Archive} placeholder="1 kg / 500g"
                     value={newProduct.unit} onChange={(e: any) => setNewProduct({...newProduct, unit: e.target.value})}
                  />
               </div>
               <div className="flex items-center justify-between p-4 bg-slate-50 border border-slate-100 rounded-2xl">
                  <div>
                    <p className="text-xs sm:text-sm font-bold text-slate-900">Available Status</p>
                    <p className="text-[10px] sm:text-xs text-slate-400 font-medium">Show or hide item in store</p>
                  </div>
                  <input 
                    type="checkbox"
                    checked={newProduct.isAvailable}
                    onChange={(e) => setNewProduct({...newProduct, isAvailable: e.target.checked})}
                    className="w-5 h-5 accent-emerald-600 rounded cursor-pointer"
                  />
               </div>
            </div>

            <div className="space-y-5 sm:space-y-6 flex flex-col justify-between">
               <div>
                  <label className="text-xs sm:text-sm font-bold text-slate-700 ml-1 block mb-2">Item Illustration</label>
                  <div className="relative border-2 border-dashed border-slate-200 rounded-[2rem] p-6 text-center hover:border-emerald-500 transition-colors bg-slate-50/50">
                     <input 
                        type="file" 
                        accept="image/*"
                        onChange={handleImageUpload}
                        className="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10"
                     />
                     {uploading ? (
                        <div className="py-12 flex flex-col items-center gap-3">
                           <Loader2 className="w-8 h-8 animate-spin text-emerald-500" />
                           <p className="text-xs font-bold text-emerald-600">Uploading photo...</p>
                        </div>
                     ) : imagePreview ? (
                        <div className="relative aspect-video rounded-2xl overflow-hidden border border-slate-100 group">
                           <img 
                             src={imagePreview} 
                             alt="Preview" 
                             className="w-full h-full object-cover" 
                             onError={(e: any) => {
                               e.target.onerror = null;
                               e.target.src = 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400';
                             }}
                           />
                           <div className="absolute inset-0 bg-slate-900/40 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
                              <p className="text-white text-xs font-bold flex items-center gap-2">
                                 <UploadCloud className="w-4 h-4" /> Change Image
                              </p>
                           </div>
                        </div>
                     ) : (
                        <div className="py-12 flex flex-col items-center gap-3">
                           <div className="p-4 bg-emerald-50 text-emerald-600 rounded-2xl">
                              <ImageIcon className="w-6 h-6" />
                           </div>
                           <div>
                              <p className="text-xs sm:text-sm font-bold text-slate-700">Click or drag image file here</p>
                              <p className="text-[10px] text-slate-400 font-medium mt-1">PNG, JPG, WEBP up to 5MB</p>
                           </div>
                        </div>
                     )}
                  </div>
               </div>

               <div className="pt-4 flex gap-4">
                  <button 
                     onClick={() => setIsAddModalOpen(false)}
                     className="flex-1 py-3.5 bg-slate-100 hover:bg-slate-200 text-slate-600 font-bold rounded-2xl text-xs sm:text-sm transition-all cursor-pointer"
                  >
                     Cancel
                  </button>
                  <button 
                     onClick={handleAddProduct}
                     className="flex-1 py-3.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-2xl text-xs sm:text-sm shadow-lg shadow-emerald-600/20 transition-all cursor-pointer"
                  >
                     {editingProduct ? "Save Changes" : "Create Item"}
                  </button>
               </div>
            </div>
         </div>
      </Modal>
    </div>
  );
}
