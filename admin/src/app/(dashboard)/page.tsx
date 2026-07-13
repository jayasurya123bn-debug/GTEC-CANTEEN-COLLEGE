'use client';
import { useEffect, useState } from 'react';
import { Utensils, IndianRupee, ShoppingBag, Star, Send } from 'lucide-react';
import toast from 'react-hot-toast';
import StatsCard from '../../components/StatsCard';
import StatusToggle from '../../components/StatusToggle';
import api from '../../lib/api';
import { useSocket } from '../../hooks/useSocket';
import { CanteenStatus } from '../../types';

export default function Dashboard() {
  const [stats, setStats] = useState<any>(null);
  const [recentOrders, setRecentOrders] = useState<any[]>([]);
  const [canteenStatus, setCanteenStatus] = useState<CanteenStatus>({ is_open: false, busyness: 'low', broadcast_message: '' });
  const [broadcastInput, setBroadcastInput] = useState('');
  const [loading, setLoading] = useState(true);

  const fetchData = async () => {
    try {
      const [statsRes, ordersRes, statusRes] = await Promise.all([
        api.get('/admin/stats'),
        api.get('/admin/stats/recent-orders'),
        api.get('/canteen/status')
      ]);
      setStats(statsRes.data);
      setRecentOrders(ordersRes.data.orders);
      setCanteenStatus(statusRes.data);
      setBroadcastInput(statusRes.data.broadcast_message || '');
      setLoading(false);
    } catch (error) {
      toast.error('Failed to load dashboard data');
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  useSocket('canteen:status', (data) => {
    setCanteenStatus({
      is_open: data.isOpen,
      busyness: data.busyness,
      broadcast_message: data.broadcastMessage
    });
  });

  useSocket('admin:orderUpdate', (order) => {
    // Optimistically update recent orders list
    setRecentOrders(prev => {
      const exists = prev.find(o => o.id === order.id);
      if (exists) {
        return prev.map(o => o.id === order.id ? order : o);
      }
      return [order, ...prev].slice(0, 10);
    });
    // Re-fetch stats to keep them accurate
    api.get('/admin/stats').then(res => setStats(res.data));
  });

  const handleToggleStatus = async (isOpen: boolean) => {
    try {
      await api.put('/canteen/status', { is_open: isOpen });
      toast.success(`Canteen is now ${isOpen ? 'OPEN' : 'CLOSED'}`);
    } catch (error) {
      toast.error('Failed to update status');
    }
  };

  const handleUpdateBusyness = async (e: React.ChangeEvent<HTMLSelectElement>) => {
    try {
      await api.put('/canteen/status', { busyness: e.target.value });
      toast.success('Busyness updated');
    } catch (error) {
      toast.error('Failed to update busyness');
    }
  };

  const handleSendBroadcast = async () => {
    try {
      await api.put('/canteen/broadcast', { broadcast_message: broadcastInput });
      toast.success('Broadcast sent!');
      setBroadcastInput('');
    } catch (error) {
      toast.error('Failed to send broadcast');
    }
  };

  if (loading) return <div>Loading dashboard...</div>;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900">Overview</h1>
        <div className="flex items-center space-x-4 bg-white px-4 py-2 rounded-lg shadow-sm border border-gray-200">
          <span className="text-sm font-medium text-gray-700">Canteen Status:</span>
          <StatusToggle isOpen={canteenStatus.is_open} onChange={handleToggleStatus} />
          <span className={`text-sm font-bold ${canteenStatus.is_open ? 'text-primary' : 'text-gray-500'}`}>
            {canteenStatus.is_open ? 'OPEN' : 'CLOSED'}
          </span>
          <div className="h-6 w-px bg-gray-300 mx-2"></div>
          <select 
            className="text-sm border-gray-300 rounded-md focus:ring-primary focus:border-primary p-1"
            value={canteenStatus.busyness}
            onChange={handleUpdateBusyness}
          >
            <option value="low">Low Traffic</option>
            <option value="moderate">Moderate</option>
            <option value="high">High Traffic</option>
            <option value="packed">Packed</option>
          </select>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatsCard title="Total Menu Items" value={stats?.total_items || 0} icon={Utensils} />
        <StatsCard title="Orders Today" value={stats?.orders_today || 0} icon={ShoppingBag} />
        <StatsCard title="Revenue Today" value={`₹${stats?.revenue_today || 0}`} icon={IndianRupee} />
        <StatsCard title="Average Rating" value={`${stats?.avg_rating || 0} / 5.0`} icon={Star} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Recent Orders */}
        <div className="lg:col-span-2 bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center">
            <h2 className="text-lg font-bold text-gray-900">Recent Orders</h2>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Order ID</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Customer</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Amount</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {recentOrders.map((order) => (
                  <tr key={order.id}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">#{order.id.split('-')[0]}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{order.user_name || 'Student'}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">₹{order.total_amount}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm">
                      <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full 
                        ${order.status === 'pending' ? 'bg-yellow-100 text-yellow-800' : 
                          order.status === 'ready' ? 'bg-green-100 text-green-800' : 
                          order.status === 'completed' ? 'bg-gray-100 text-gray-800' : 
                          'bg-blue-100 text-blue-800'}`}>
                        {order.status}
                      </span>
                    </td>
                  </tr>
                ))}
                {recentOrders.length === 0 && (
                  <tr>
                    <td colSpan={4} className="px-6 py-4 text-center text-gray-500">No recent orders</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>

        {/* Broadcast Message */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100">
          <div className="px-6 py-4 border-b border-gray-100">
            <h2 className="text-lg font-bold text-gray-900">Broadcast Message</h2>
          </div>
          <div className="p-6">
            <p className="text-sm text-gray-600 mb-4">Send a push notification and update the banner in the app for all students.</p>
            <textarea
              className="w-full border border-gray-300 rounded-lg p-3 text-sm focus:ring-primary focus:border-primary"
              rows={4}
              placeholder="E.g., Special meals available today!"
              value={broadcastInput}
              onChange={(e) => setBroadcastInput(e.target.value)}
            ></textarea>
            <button 
              onClick={handleSendBroadcast}
              className="mt-4 w-full flex justify-center items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary hover:bg-green-700"
            >
              <Send size={16} className="mr-2" />
              Broadcast Now
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
