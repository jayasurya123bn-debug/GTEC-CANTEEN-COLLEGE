'use client';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Leaf } from 'lucide-react';
import toast from 'react-hot-toast';
import api from '../../../../lib/api';

export default function NewMenuItem() {
  const router = useRouter();
  const [categories, setCategories] = useState<any[]>([]);
  const [formData, setFormData] = useState({
    name: '',
    category_id: '',
    description: '',
    price: '',
    image_url: '',
    dietary_tag: 'veg',
    availability: 'available'
  });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    api.get('/menu/categories').then(res => setCategories(res.data));
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await api.post('/menu', {
        ...formData,
        price: parseFloat(formData.price)
      });
      toast.success('Veg item created successfully');
      router.push('/menu');
    } catch (error: any) {
      toast.error(error.response?.data?.details?.[0] || 'Failed to create item');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div className="flex items-center space-x-2">
        <h1 className="text-2xl font-bold text-gray-900">Add New Menu Item</h1>
      </div>

      <div className="bg-veg-50 border border-primary/20 p-4 rounded-lg flex items-start space-x-3">
        <Leaf className="text-primary mt-0.5" size={20} />
        <div>
          <h3 className="text-primary font-bold">100% Pure Veg Canteen Rule</h3>
          <p className="text-sm text-green-800">This item will automatically be marked as Vegetarian. Non-veg items are strictly not permitted in this system.</p>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="col-span-2">
            <label className="block text-sm font-medium text-gray-700 mb-1">Item Name</label>
            <input 
              type="text" required value={formData.name} onChange={e => setFormData({...formData, name: e.target.value})}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary focus:border-primary"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
            <select required value={formData.category_id} onChange={e => setFormData({...formData, category_id: e.target.value})}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary focus:border-primary">
              <option value="">Select Category</option>
              {categories.map(c => <option key={c.id} value={c.id}>{c.icon_emoji} {c.name}</option>)}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Price (₹)</label>
            <input type="number" step="0.01" min="0" required value={formData.price} onChange={e => setFormData({...formData, price: e.target.value})}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary focus:border-primary"
            />
          </div>

          <div className="col-span-2">
            <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea rows={3} value={formData.description} onChange={e => setFormData({...formData, description: e.target.value})}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary focus:border-primary"
            ></textarea>
          </div>

          <div className="col-span-2">
            <label className="block text-sm font-medium text-gray-700 mb-1">Image URL (Unsplash)</label>
            <input type="url" value={formData.image_url} onChange={e => setFormData({...formData, image_url: e.target.value})}
              placeholder="https://images.unsplash.com/photo-..."
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary focus:border-primary"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Dietary Tag</label>
            <div className="flex space-x-4">
              <label className="flex items-center space-x-2 cursor-pointer">
                <input type="radio" name="dietary" value="veg" checked={formData.dietary_tag === 'veg'} onChange={e => setFormData({...formData, dietary_tag: e.target.value})} className="text-primary focus:ring-primary" />
                <span className="text-sm">🌿 Veg</span>
              </label>
              <label className="flex items-center space-x-2 cursor-pointer">
                <input type="radio" name="dietary" value="vegan" checked={formData.dietary_tag === 'vegan'} onChange={e => setFormData({...formData, dietary_tag: e.target.value})} className="text-primary focus:ring-primary" />
                <span className="text-sm">🌿 Vegan</span>
              </label>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Availability</label>
            <select value={formData.availability} onChange={e => setFormData({...formData, availability: e.target.value})}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-primary focus:border-primary">
              <option value="available">Available</option>
              <option value="limited">Limited</option>
              <option value="sold_out">Sold Out</option>
            </select>
          </div>
        </div>

        <div className="flex justify-end space-x-3 pt-4 border-t border-gray-100">
          <button type="button" onClick={() => router.back()} className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">Cancel</button>
          <button type="submit" disabled={loading} className="px-4 py-2 bg-primary hover:bg-green-700 text-white rounded-md text-sm font-medium shadow-sm disabled:opacity-50">
            {loading ? 'Saving...' : 'Save Veg Item'}
          </button>
        </div>
      </form>
    </div>
  );
}
