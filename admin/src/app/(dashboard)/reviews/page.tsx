'use client';
import { useEffect, useState } from 'react';
import { Check, X, Trash2 } from 'lucide-react';
import toast from 'react-hot-toast';
import api from '../../../lib/api';

export default function ReviewsPage() {
  const [reviews, setReviews] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchReviews = async () => {
    try {
      const res = await api.get('/reviews');
      setReviews(res.data.reviews);
      setLoading(false);
    } catch (error) {
      toast.error('Failed to load reviews');
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReviews();
  }, []);

  const handleApprove = async (id: string, is_approved: boolean) => {
    try {
      await api.patch(`/reviews/${id}/approve`, { is_approved });
      toast.success(is_approved ? 'Review approved' : 'Review hidden');
      fetchReviews();
    } catch (error) {
      toast.error('Failed to update review status');
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm('Delete this review?')) return;
    try {
      await api.delete(`/reviews/${id}`);
      toast.success('Review deleted');
      fetchReviews();
    } catch (error) {
      toast.error('Failed to delete review');
    }
  };

  if (loading) return <div>Loading...</div>;

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-white">Reviews Management</h1>
      
      <div className="bg-card rounded-xl shadow-sm border border-border overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-border">
            <thead className="bg-elevated">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase">Student</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase">Item</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase">Rating</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase">Comment</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-400 uppercase">Status</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-400 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-card divide-y divide-border">
              {reviews.map((review) => (
                <tr key={review.id} className="hover:bg-elevated/30 transition-colors">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-white">{review.user_name}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-400">{review.item_name}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-yellow-500">{'★'.repeat(review.rating)}{'☆'.repeat(5-review.rating)}</td>
                  <td className="px-6 py-4 text-sm text-gray-400 max-w-xs truncate">{review.comment}</td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${review.is_approved ? 'bg-primary/20 text-primary' : 'bg-yellow-500/20 text-yellow-500'}`}>
                      {review.is_approved ? 'Approved' : 'Pending'}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    {!review.is_approved ? (
                      <button onClick={() => handleApprove(review.id, true)} className="text-primary hover:text-[#00C853] mx-2 p-1 bg-primary/10 rounded transition-colors" title="Approve">
                        <Check size={18} />
                      </button>
                    ) : (
                      <button onClick={() => handleApprove(review.id, false)} className="text-yellow-500 hover:text-yellow-400 mx-2 p-1 bg-yellow-500/10 rounded transition-colors" title="Hide">
                        <X size={18} />
                      </button>
                    )}
                    <button onClick={() => handleDelete(review.id)} className="text-red-500 hover:text-red-400 mx-2 p-1 bg-red-500/10 rounded transition-colors" title="Delete">
                      <Trash2 size={18} />
                    </button>
                  </td>
                </tr>
              ))}
              {reviews.length === 0 && (
                <tr><td colSpan={6} className="px-6 py-8 text-center text-gray-500">No reviews found</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
