'use client';
import { useState } from 'react';
import {
  Ticket,
  Utensils,
  TrendingUp,
  AlertCircle,
  BarChart3,
  RefreshCw,
  Pencil,
  Check,
  X,
} from 'lucide-react';
import toast from 'react-hot-toast';
import Link from 'next/link';
import { usePreOrderDashboard } from '../../../hooks/usePreOrder';
import NowServingDisplay from '../../../components/NowServingDisplay';
import CapacityBar from '../../../components/CapacityBar';
import DepartmentBadge from '../../../components/DepartmentBadge';
import TokenRangeBadge from '../../../components/TokenRangeBadge';

// ─── Status badge helper ────────────────────────────────────────────────────
const StatusBadge = ({ status }: { status: string }) => {
  const map: Record<string, string> = {
    pending:   'bg-yellow-100 text-yellow-800',
    confirmed: 'bg-blue-100 text-blue-800',
    preparing: 'bg-orange-100 text-orange-800',
    ready:     'bg-green-100 text-green-800',
    completed: 'bg-gray-100 text-gray-700',
    cancelled: 'bg-red-100 text-red-800',
  };
  return (
    <span className={`px-2 py-0.5 rounded-full text-xs font-semibold capitalize ${map[status] || 'bg-gray-100 text-gray-700'}`}>
      {status}
    </span>
  );
};

// ─── InlineEditLimit ────────────────────────────────────────────────────────
function InlineEditLimit({
  itemId,
  currentLimit,
  bookedQty,
  onSave,
}: {
  itemId: string;
  currentLimit: number;
  bookedQty: number;
  onSave: (itemId: string, newLimit: number) => Promise<void>;
}) {
  const [editing, setEditing] = useState(false);
  const [value, setValue] = useState(String(currentLimit));
  const [saving, setSaving] = useState(false);

  const handleSave = async () => {
    const num = parseInt(value);
    if (isNaN(num) || num < 0 || num > 500) {
      toast.error('Limit must be between 0 and 500');
      return;
    }
    setSaving(true);
    try {
      await onSave(itemId, num);
      toast.success('Limit updated!');
      setEditing(false);
    } catch {
      toast.error('Failed to update limit');
    } finally {
      setSaving(false);
    }
  };

  if (editing) {
    return (
      <div className="flex items-center gap-1">
        {bookedQty > parseInt(value || '0') && (
          <span className="text-xs text-amber-600 mr-1 font-medium">
            ⚠ {bookedQty} already booked
          </span>
        )}
        <input
          id={`limit-input-${itemId}`}
          type="number"
          min={0}
          max={500}
          value={value}
          onChange={(e) => setValue(e.target.value)}
          className="w-20 border border-green-400 rounded-md px-2 py-0.5 text-sm focus:ring-2 focus:ring-green-500 focus:outline-none"
          autoFocus
        />
        <button
          id={`limit-save-${itemId}`}
          onClick={handleSave}
          disabled={saving}
          className="p-1 rounded-full bg-green-100 hover:bg-green-200 text-green-700"
        >
          <Check size={14} />
        </button>
        <button
          id={`limit-cancel-${itemId}`}
          onClick={() => { setEditing(false); setValue(String(currentLimit)); }}
          className="p-1 rounded-full bg-red-100 hover:bg-red-200 text-red-700"
        >
          <X size={14} />
        </button>
      </div>
    );
  }

  return (
    <button
      id={`limit-edit-${itemId}`}
      onClick={() => { setEditing(true); setValue(String(currentLimit)); }}
      className="flex items-center gap-1 text-sm text-gray-700 hover:text-green-700 group"
    >
      <span className="font-semibold">{currentLimit}</span>
      <Pencil size={12} className="opacity-0 group-hover:opacity-100 transition-opacity" />
    </button>
  );
}

// ─── Page ──────────────────────────────────────────────────────────────────
export default function PreOrderDashboardPage() {
  const { data, nowServing, loading, error, fetchDashboard, updateNowServing, updateLimit } =
    usePreOrderDashboard();

  const [nowServingInput, setNowServingInput] = useState('');
  const [updatingNow, setUpdatingNow] = useState(false);

  const handleUpdateNowServing = async () => {
    const num = parseInt(nowServingInput);
    if (isNaN(num) || num < 0) {
      toast.error('Enter a valid token number');
      return;
    }
    setUpdatingNow(true);
    try {
      await updateNowServing(num, data?.current_slot?.slot_name);
      toast.success(`Now serving: #${num}`);
      setNowServingInput('');
    } catch {
      toast.error('Failed to update now serving');
    } finally {
      setUpdatingNow(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="flex flex-col items-center gap-3">
          <div className="w-8 h-8 border-4 border-green-500 border-t-transparent rounded-full animate-spin" />
          <p className="text-gray-500 text-sm">Loading pre-order dashboard...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <AlertCircle className="w-10 h-10 text-red-500 mx-auto mb-2" />
          <p className="text-gray-600">{error}</p>
          <button
            onClick={fetchDashboard}
            className="mt-3 px-4 py-2 bg-green-600 text-white rounded-lg text-sm hover:bg-green-700"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  const slot = data?.current_slot;
  const deptSummary = data?.department_summary || {};

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Pre-Order Dashboard</h1>
          <p className="text-sm text-gray-500 mt-0.5">Real-time token management for pre-orders</p>
        </div>
        <div className="flex items-center gap-3">
          <Link
            href="/pre-order/queue"
            className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg text-sm hover:bg-green-700 font-medium"
          >
            <Ticket size={16} />
            View Queue
          </Link>
          <button
            id="dashboard-refresh-btn"
            onClick={fetchDashboard}
            className="p-2 rounded-lg border border-gray-200 hover:bg-gray-50 text-gray-600"
            title="Refresh"
          >
            <RefreshCw size={16} />
          </button>
        </div>
      </div>

      {/* Top row: Slot card + Now Serving */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Current Slot Info */}
        <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
          {slot ? (
            <div className="flex flex-col sm:flex-row sm:items-center gap-6">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold bg-green-100 text-green-800 capitalize">
                    🟢 {slot.slot_name}
                  </span>
                  <span className="text-xs text-gray-400">{slot.date}</span>
                </div>
                <p className="text-3xl font-black text-gray-900">
                  {slot.start_time.slice(0, 5)} – {slot.end_time.slice(0, 5)}
                </p>
                <div className="mt-3 grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-xs text-gray-500 uppercase tracking-wide">Tokens Issued</p>
                    <p className="text-2xl font-bold text-gray-800">#{slot.current_token_number}</p>
                  </div>
                  <div>
                    <p className="text-xs text-gray-500 uppercase tracking-wide">Est. Queue Wait</p>
                    <p className="text-2xl font-bold text-gray-800">
                      ~{Math.max(0, (slot.current_token_number - slot.now_serving) * 2)} min
                    </p>
                  </div>
                </div>
              </div>

              {/* Now Serving update */}
              <div className="flex flex-col gap-3">
                <p className="text-sm font-semibold text-gray-700">Update Now Serving</p>
                <div className="flex items-center gap-2">
                  <input
                    id="now-serving-input"
                    type="number"
                    min={0}
                    placeholder="Token #"
                    value={nowServingInput}
                    onChange={(e) => setNowServingInput(e.target.value)}
                    onKeyDown={(e) => e.key === 'Enter' && handleUpdateNowServing()}
                    className="w-28 border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-green-500 focus:outline-none"
                  />
                  <button
                    id="now-serving-update-btn"
                    onClick={handleUpdateNowServing}
                    disabled={updatingNow}
                    className="px-4 py-2 bg-green-600 text-white rounded-lg text-sm font-medium hover:bg-green-700 disabled:opacity-50"
                  >
                    {updatingNow ? 'Saving…' : 'Update'}
                  </button>
                </div>
              </div>
            </div>
          ) : (
            <div className="text-center py-8">
              <Utensils className="w-10 h-10 text-gray-300 mx-auto mb-2" />
              <p className="text-gray-500 font-medium">No active meal slot right now</p>
              <p className="text-xs text-gray-400 mt-1">
                Slots: Breakfast 7–10am • Lunch 12–2pm • Snacks 4–6pm • Dinner 7–9pm
              </p>
            </div>
          )}
        </div>

        {/* Now Serving display */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 flex items-center justify-center">
          <NowServingDisplay
            tokenNumber={nowServing}
            slotName={slot?.slot_name}
          />
        </div>
      </div>

      {/* Stats row */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { label: 'Total Orders', value: data?.total_orders ?? 0, icon: Ticket, color: 'text-green-600 bg-green-50' },
          { label: 'Total Portions', value: data?.total_portions ?? 0, icon: BarChart3, color: 'text-blue-600 bg-blue-50' },
          { label: 'Items Sold Out', value: data?.items_sold_out ?? 0, icon: AlertCircle, color: 'text-red-600 bg-red-50' },
          { label: 'Avg Items/Order', value: data?.avg_items_per_order?.toFixed(1) ?? '0.0', icon: TrendingUp, color: 'text-purple-600 bg-purple-50' },
        ].map((stat, i) => (
          <div key={i} className="bg-white rounded-xl border border-gray-100 shadow-sm p-5">
            <div className={`inline-flex p-2 rounded-lg ${stat.color.split(' ')[1]} mb-3`}>
              <stat.icon size={20} className={stat.color.split(' ')[0]} />
            </div>
            <p className="text-2xl font-black text-gray-900">{stat.value}</p>
            <p className="text-xs text-gray-500 mt-0.5">{stat.label}</p>
          </div>
        ))}
      </div>

      {/* Department summary */}
      {Object.keys(deptSummary).length > 0 && (
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
          <h2 className="text-sm font-bold text-gray-700 uppercase tracking-wide mb-3">Department Summary</h2>
          <div className="flex flex-wrap gap-2">
            {Object.entries(deptSummary).sort((a, b) => b[1] - a[1]).map(([dept, count]) => (
              <div key={dept} className="flex items-center gap-1.5">
                <DepartmentBadge department={dept} />
                <span className="text-sm font-semibold text-gray-700">{count} orders</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Per-item capacity table */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
          <h2 className="text-lg font-bold text-gray-900">Item Capacity</h2>
          <span className="text-xs text-gray-400">Click the limit number to edit</span>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-100">
            <thead className="bg-gray-50">
              <tr>
                {['Item', 'Limit', 'Booked', 'Remaining', 'Capacity', 'Status'].map((h) => (
                  <th key={h} className="px-5 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-50">
              {(data?.item_breakdown || []).map((item) => (
                <tr key={item.menu_item_id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-5 py-3">
                    <div className="flex items-center gap-2">
                      <span className="text-green-600 text-sm">🌿</span>
                      <span className="text-sm font-medium text-gray-900">{item.item_name}</span>
                    </div>
                  </td>
                  <td className="px-5 py-3">
                    <InlineEditLimit
                      itemId={item.menu_item_id}
                      currentLimit={item.pre_order_limit}
                      bookedQty={item.booked_qty}
                      onSave={updateLimit}
                    />
                  </td>
                  <td className="px-5 py-3">
                    <span className="text-sm font-semibold text-gray-700">{item.booked_qty}</span>
                  </td>
                  <td className="px-5 py-3">
                    <span className={`text-sm font-semibold ${
                      item.remaining === 0 ? 'text-red-600' :
                      item.remaining <= item.pre_order_limit * 0.2 ? 'text-amber-600' :
                      'text-green-600'
                    }`}>
                      {item.remaining}
                    </span>
                  </td>
                  <td className="px-5 py-3 w-40">
                    <CapacityBar booked={item.booked_qty} limit={item.pre_order_limit} />
                  </td>
                  <td className="px-5 py-3">
                    <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold ${
                      item.status === 'sold_out' ? 'bg-red-100 text-red-800' :
                      item.status === 'limited' ? 'bg-amber-100 text-amber-800' :
                      'bg-green-100 text-green-800'
                    }`}>
                      {item.status === 'sold_out' ? '🔴 Sold Out' :
                       item.status === 'limited' ? '🟡 Limited' : '🟢 Available'}
                    </span>
                  </td>
                </tr>
              ))}
              {(!data?.item_breakdown || data.item_breakdown.length === 0) && (
                <tr>
                  <td colSpan={6} className="px-5 py-10 text-center text-gray-400 text-sm">
                    No items to display. Start a meal slot to see capacity data.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
