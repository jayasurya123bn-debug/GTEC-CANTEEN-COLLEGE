'use client';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { Plus, Edit2, Trash2 } from 'lucide-react';
import toast from 'react-hot-toast';
import api from '../../../lib/api';
import VegBadge from '../../../components/VegBadge';
import AvailabilityBadge from '../../../components/AvailabilityBadge';
import { useSocket } from '../../../hooks/useSocket';

export default function MenuPage() {
  const [categories, setCategories] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchMenu = async () => {
    try {
      const res = await api.get('/menu');
      setCategories(res.data);
      setLoading(false);
    } catch (error) {
      toast.error('Failed to load menu');
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchMenu();
  }, []);

  useSocket('menu:itemUpdate', fetchMenu);
  useSocket('menu:itemCreated', fetchMenu);
  useSocket('menu:itemDeleted', fetchMenu);

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to remove this item?')) return;
    try {
      await api.delete(`/menu/${id}`);
      toast.success('Item removed');
    } catch (error) {
      toast.error('Failed to remove item');
    }
  };

  if (loading) return <div>Loading...</div>;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900">Menu Management</h1>
        <Link 
          href="/menu/new"
          className="bg-primary hover:bg-green-700 text-white px-4 py-2 rounded-lg flex items-center shadow-sm"
        >
          <Plus size={20} className="mr-2" />
          Add Veg Item
        </Link>
      </div>

      {categories.map((category) => (
        <div key={category.category} className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden mb-6">
          <div className="bg-gray-50 px-6 py-3 border-b border-gray-100 font-bold text-gray-800">
            {category.category}
          </div>
          <div className="divide-y divide-gray-100">
            {category.items.map((item: any) => (
              <div key={item.id} className="p-4 sm:p-6 flex items-center hover:bg-gray-50 transition-colors">
                <div className="relative w-16 h-16 rounded-lg overflow-hidden flex-shrink-0 bg-gray-100">
                  {item.image_url ? (
                    <Image src={item.image_url} alt={item.name} layout="fill" objectFit="cover" />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center text-gray-400">No Img</div>
                  )}
                </div>
                <div className="ml-4 flex-1">
                  <div className="flex items-center space-x-2">
                    <h3 className="text-lg font-bold text-gray-900">{item.name}</h3>
                    <VegBadge type={item.dietary_tag} />
                  </div>
                  <p className="text-sm text-gray-500 line-clamp-1">{item.description}</p>
                  <div className="mt-1 flex items-center space-x-4">
                    <span className="font-semibold text-primary">₹{item.price}</span>
                    <AvailabilityBadge status={item.availability} />
                  </div>
                </div>
                <div className="ml-4 flex space-x-2">
                  <Link href={`/menu/${item.id}/edit`} className="p-2 text-gray-400 hover:text-blue-600 rounded-full hover:bg-blue-50">
                    <Edit2 size={18} />
                  </Link>
                  <button onClick={() => handleDelete(item.id)} className="p-2 text-gray-400 hover:text-red-600 rounded-full hover:bg-red-50">
                    <Trash2 size={18} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      ))}
      
      {categories.length === 0 && (
        <div className="text-center py-12 bg-white rounded-xl border border-gray-100">
          <p className="text-gray-500 mb-4">No menu items found.</p>
          <Link href="/menu/new" className="text-primary font-medium hover:underline">Add your first item</Link>
        </div>
      )}
    </div>
  );
}
