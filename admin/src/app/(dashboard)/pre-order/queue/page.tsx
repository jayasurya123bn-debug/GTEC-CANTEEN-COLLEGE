'use client';
import { useState } from 'react';
import {
  ChevronLeft,
  RefreshCw,
  AlertCircle,
  Filter,
} from 'lucide-react';
import toast from 'react-hot-toast';
import Link from 'next/link';
import { usePreOrderQueue } from '../../../../hooks/usePreOrder';
import NowServingDisplay from '../../../../components/NowServingDisplay';
import TokenRangeBadge from '../../../../components/TokenRangeBadge';
import DepartmentBadge from '../../../../components/DepartmentBadge';

// ─── Constants ──────────────────────────────────────────────────────────────
const SLOTS    = ['breakfast', 'lunch', 'snacks', 'dinner'];
const STATUSES = ['pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled'];
const DEPTS    = ['CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'IT', 'AI&DS', 'BME', 'CHEM'];

const VALID_TRANSITIONS: Record<string, string[]> = {
  pending:   ['confirmed', 'cancelled'],
  confirmed: ['preparing', 'cancelled'],
  preparing: ['ready',     'cancelled'],
  ready:     ['completed', 'cancelled'],
  completed: [],
  cancelled: [],
};

const STATUS_COLORS: Record<string, string> = {
  pending:   'bg-yellow-100 text-yellow-800 border-yellow-200',
  confirmed: 'bg-blue-100 text-blue-800 border-blue-200',
  preparing: 'bg-orange-100 text-orange-800 border-orange-200',
  ready:     'bg-green-100 text-green-800 border-green-200',
  completed: 'bg-gray-100 text-gray-700 border-gray-200',
  cancelled: 'bg-red-100 text-red-800 border-red-200',
};

// ─── Order Row ───────────────────────────────────────────────────────────────
function OrderRow({
  order,
  nowServing,
  onStatusChange,
}: {
  order: any;
  nowServing: number;
  onStatusChange: (orderId: string, status: string) => Promise<void>;
}) {
  const [selectedStatus, setSelectedStatus] = useState('');
  const [updating, setUpdating] = useState(false);

  const isNowServing =
    order.token_start <= nowServing && nowServing <= order.token_end;

  const transitions = VALID_TRANSITIONS[order.status] || [];

  const handleUpdate = async () => {
    if (!selectedStatus) return;
    setUpdating(true);
    try {
      await onStatusChange(order.id, selectedStatus);
      toast.success(`Order updated to ${selectedStatus}`);
      setSelectedStatus('');
    } catch {
      toast.error('Failed to update status');
    } finally {
      setUpdating(false);
    }
  };

  const itemsSummary = (order.items || [])
    .map((i: any) => `${i.quantity}× ${i.name}`)
    .join(', ');

  return (
    <tr
      className={`transition-colors ${
        order.status === 'cancelled' ? 'opacity-50' :
        isNowServing ? 'bg-green-50' : 'hover:bg-gray-50'
      }`}
    >
      {/* Token range */}
      <td className="px-4 py-3">
        <div className={`flex items-start gap-1 ${isNowServing ? 'border-l-4 border-green-500 pl-2' : ''}`}>
          <TokenRangeBadge
            tokenStart={order.token_start}
            tokenEnd={order.token_end}
            size="sm"
          />
        </div>
      </td>

      {/* Student */}
      <td className="px-4 py-3">
        <p className="text-sm font-semibold text-gray-900">{order.student_name || '—'}</p>
        <p className="text-xs text-gray-400">{order.pickup_time || 'No pickup time'}</p>
      </td>

      {/* Dept / Year / Section */}
      <td className="px-4 py-3">
        <div className="flex flex-wrap gap-1">
          <DepartmentBadge department={order.department || '—'} />
          <span className="inline-flex items-center px-1.5 py-0.5 rounded text-xs bg-gray-100 text-gray-600">
            {order.year}
          </span>
          <span className="inline-flex items-center px-1.5 py-0.5 rounded text-xs bg-gray-100 text-gray-600">
            Sec {order.section}
          </span>
        </div>
      </td>

      {/* Items */}
      <td className="px-4 py-3 max-w-xs">
        <p className="text-xs text-gray-700 leading-relaxed truncate" title={itemsSummary}>
          {itemsSummary || '—'}
        </p>
      </td>

      {/* Portions */}
      <td className="px-4 py-3 text-center">
        <span className="text-sm font-bold text-gray-800">{order.total_items}</span>
      </td>

      {/* Amount */}
      <td className="px-4 py-3">
        <span className="text-sm font-semibold text-gray-900">₹{order.total_amount?.toFixed(0)}</span>
      </td>

      {/* Status */}
      <td className="px-4 py-3">
        <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold border capitalize ${STATUS_COLORS[order.status] || ''}`}>
          {order.status}
        </span>
      </td>

      {/* Actions */}
      <td className="px-4 py-3">
        {transitions.length > 0 ? (
          <div className="flex items-center gap-1.5">
            <select
              id={`status-select-${order.id}`}
              value={selectedStatus}
              onChange={(e) => setSelectedStatus(e.target.value)}
              className="text-xs border border-gray-300 rounded-md px-2 py-1 focus:ring-1 focus:ring-green-500 focus:outline-none"
            >
              <option value="">Change…</option>
              {transitions.map((s) => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>
            <button
              id={`status-update-${order.id}`}
              onClick={handleUpdate}
              disabled={!selectedStatus || updating}
              className="px-2 py-1 bg-green-600 text-white rounded-md text-xs font-medium hover:bg-green-700 disabled:opacity-40 disabled:cursor-not-allowed"
            >
              {updating ? '…' : 'Go'}
            </button>
          </div>
        ) : (
          <span className="text-xs text-gray-400">—</span>
        )}
      </td>
    </tr>
  );
}

// ─── Page ───────────────────────────────────────────────────────────────────
export default function TokenQueuePage() {
  const [mealSlot, setMealSlot]   = useState('');
  const [status, setStatus]       = useState('');
  const [department, setDept]     = useState('');

  const { orders, slot, nowServing, loading, error, fetchQueue, updateOrderStatus } =
    usePreOrderQueue({ meal_slot: mealSlot, status, department });

  // Department summary from current orders
  const deptSummary = orders.reduce<Record<string, number>>((acc, o) => {
    if (o.department) acc[o.department] = (acc[o.department] || 0) + 1;
    return acc;
  }, {});

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="w-8 h-8 border-4 border-green-500 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div className="flex items-center gap-3">
          <Link href="/pre-order" className="p-1.5 rounded-lg border border-gray-200 hover:bg-gray-50">
            <ChevronLeft size={18} className="text-gray-500" />
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Token Queue</h1>
            <p className="text-sm text-gray-400">
              {slot ? `${slot.slot_name} — ${slot.date}` : 'No active slot'}
            </p>
          </div>
        </div>
        <button
          id="queue-refresh-btn"
          onClick={fetchQueue}
          className="flex items-center gap-2 px-3 py-2 rounded-lg border border-gray-200 text-sm text-gray-600 hover:bg-gray-50"
        >
          <RefreshCw size={15} /> Refresh
        </button>
      </div>

      {/* Now Serving + Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <div className="sm:col-span-1 bg-white rounded-2xl border border-gray-100 shadow-sm p-4 flex items-center justify-center">
          <NowServingDisplay tokenNumber={nowServing} slotName={slot?.slot_name} />
        </div>

        <div className="sm:col-span-3 grid grid-cols-3 gap-4">
          {[
            { label: 'Total Tokens', value: slot?.current_token_number ?? 0 },
            { label: 'Orders in Queue', value: orders.length },
            { label: 'Now Serving', value: nowServing > 0 ? `#${nowServing}` : '—' },
          ].map((s) => (
            <div key={s.label} className="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 flex flex-col justify-center">
              <p className="text-3xl font-black text-gray-900">{s.value}</p>
              <p className="text-xs text-gray-500 mt-1">{s.label}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Department summary */}
      {Object.keys(deptSummary).length > 0 && (
        <div className="bg-white rounded-xl border border-gray-100 shadow-sm px-5 py-3 flex flex-wrap gap-3 items-center">
          <span className="text-xs font-bold text-gray-400 uppercase tracking-wide">Depts:</span>
          {Object.entries(deptSummary).sort((a, b) => b[1] - a[1]).map(([dept, count]) => (
            <span key={dept} className="flex items-center gap-1">
              <DepartmentBadge department={dept} />
              <span className="text-xs text-gray-600 font-semibold">{count}</span>
            </span>
          ))}
        </div>
      )}

      {/* Filters */}
      <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-4">
        <div className="flex items-center gap-2 mb-3">
          <Filter size={15} className="text-gray-400" />
          <span className="text-sm font-semibold text-gray-600">Filters</span>
        </div>
        <div className="flex flex-wrap gap-3">
          <select
            id="filter-meal-slot"
            value={mealSlot}
            onChange={(e) => setMealSlot(e.target.value)}
            className="border border-gray-300 rounded-lg px-3 py-1.5 text-sm focus:ring-2 focus:ring-green-500 focus:outline-none"
          >
            <option value="">All Slots</option>
            {SLOTS.map((s) => <option key={s} value={s}>{s}</option>)}
          </select>

          <select
            id="filter-status"
            value={status}
            onChange={(e) => setStatus(e.target.value)}
            className="border border-gray-300 rounded-lg px-3 py-1.5 text-sm focus:ring-2 focus:ring-green-500 focus:outline-none"
          >
            <option value="">All Statuses</option>
            {STATUSES.map((s) => <option key={s} value={s}>{s}</option>)}
          </select>

          <select
            id="filter-department"
            value={department}
            onChange={(e) => setDept(e.target.value)}
            className="border border-gray-300 rounded-lg px-3 py-1.5 text-sm focus:ring-2 focus:ring-green-500 focus:outline-none"
          >
            <option value="">All Depts</option>
            {DEPTS.map((d) => <option key={d} value={d}>{d}</option>)}
          </select>

          {(mealSlot || status || department) && (
            <button
              id="clear-filters-btn"
              onClick={() => { setMealSlot(''); setStatus(''); setDept(''); }}
              className="text-sm text-red-600 hover:text-red-800 font-medium"
            >
              Clear Filters
            </button>
          )}
        </div>
      </div>

      {/* Queue Table */}
      {error ? (
        <div className="flex items-center gap-2 p-4 bg-red-50 text-red-700 rounded-xl">
          <AlertCircle size={16} />
          <span className="text-sm">{error}</span>
        </div>
      ) : (
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-100">
              <thead className="bg-gray-50">
                <tr>
                  {['Token #', 'Student', 'Dept / Year / Sec', 'Items', 'Portions', 'Amount', 'Status', 'Action'].map((h) => (
                    <th key={h} className="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider whitespace-nowrap">
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-50">
                {orders.length === 0 ? (
                  <tr>
                    <td colSpan={8} className="px-5 py-12 text-center text-gray-400 text-sm">
                      No pre-orders found for the selected filters.
                    </td>
                  </tr>
                ) : (
                  orders.map((order) => (
                    <OrderRow
                      key={order.id}
                      order={order}
                      nowServing={nowServing}
                      onStatusChange={updateOrderStatus}
                    />
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
