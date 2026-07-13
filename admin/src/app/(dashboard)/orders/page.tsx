'use client';
import { useEffect, useState } from 'react';
import toast from 'react-hot-toast';
import api from '../../../lib/api';
import { useSocket } from '../../../hooks/useSocket';

export default function OrdersPage() {
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchOrders = async () => {
    try {
      const res = await api.get('/admin/orders');
      setOrders(res.data.orders);
      setLoading(false);
    } catch (error) {
      toast.error('Failed to load orders');
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrders();
  }, []);

  useSocket('admin:orderUpdate', (order) => {
    setOrders(prev => {
      const exists = prev.find(o => o.id === order.id);
      if (exists) {
        return prev.map(o => o.id === order.id ? order : o);
      }
      return [order, ...prev];
    });
  });

  const updateStatus = async (id: string, status: string) => {
    try {
      await api.patch(`/admin/orders/${id}/status`, { status });
      toast.success('Order status updated');
      // local optimistic update not strictly needed as socket will push 'admin:orderUpdate', 
      // but let's do it to be responsive
      setOrders(prev => prev.map(o => o.id === id ? { ...o, status } : o));
    } catch (error) {
      toast.error('Failed to update status');
    }
  };

  if (loading) return <div>Loading...</div>;

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Orders Management</h1>
      
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Order ID</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Student</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Time Slot</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total (₹)</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Update Status</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {orders.map((order) => (
                <tr key={order.id}>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">#{order.id.split('-')[0]}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{order.user_name}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{order.time_slot}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">₹{order.total_amount}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full 
                      ${order.status === 'pending' ? 'bg-yellow-100 text-yellow-800' : 
                        order.status === 'preparing' ? 'bg-orange-100 text-orange-800' : 
                        order.status === 'ready' ? 'bg-green-100 text-green-800' : 
                        order.status === 'completed' ? 'bg-gray-100 text-gray-800' : 
                        'bg-red-100 text-red-800'}`}>
                      {order.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <select 
                      value={order.status}
                      onChange={(e) => updateStatus(order.id, e.target.value)}
                      className="text-sm border-gray-300 rounded-md focus:ring-primary focus:border-primary p-1 bg-gray-50"
                    >
                      <option value="pending">Pending</option>
                      <option value="confirmed">Confirmed</option>
                      <option value="preparing">Preparing</option>
                      <option value="ready">Ready</option>
                      <option value="completed">Completed</option>
                      <option value="cancelled">Cancelled</option>
                    </select>
                  </td>
                </tr>
              ))}
              {orders.length === 0 && (
                <tr><td colSpan={6} className="px-6 py-4 text-center text-gray-500">No orders found</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
