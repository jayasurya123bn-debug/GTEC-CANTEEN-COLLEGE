import { useEffect, useState, useCallback } from 'react';
import api from '../lib/api';
import { useSocket } from './useSocket';

export interface SlotInfo {
  id: string;
  slot_name: string;
  start_time: string;
  end_time: string;
  current_token_number: number;
  now_serving: number;
  date: string;
}

export interface ItemCapacity {
  menu_item_id: string;
  item_name: string;
  pre_order_limit: number;
  booked_qty: number;
  remaining: number;
  status: 'available' | 'limited' | 'sold_out';
}

export interface PreOrderItem {
  id: string;
  token_number: number;
  token_start: number;
  token_end: number;
  student_name: string;
  department: string;
  year: string;
  section: string;
  meal_slot: string;
  items: Array<{ menu_item_id: string; name: string; quantity: number; price: number; subtotal: number }>;
  total_items: number;
  total_amount: number;
  pickup_time: string;
  status: string;
  created_at: string;
}

export interface DashboardData {
  current_slot: SlotInfo | null;
  total_orders: number;
  total_portions: number;
  items_sold_out: number;
  avg_items_per_order: number;
  item_breakdown: ItemCapacity[];
  orders: PreOrderItem[];
  department_summary: Record<string, number>;
}

// ─── usePreOrderDashboard ──────────────────────────────────────────────────
export function usePreOrderDashboard() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [nowServing, setNowServing] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchDashboard = useCallback(async () => {
    try {
      setLoading(true);
      const res = await api.get('/admin/pre-order/dashboard');
      setData(res.data);
      if (res.data?.current_slot?.now_serving !== undefined) {
        setNowServing(res.data.current_slot.now_serving);
      }
      setError(null);
    } catch (err: any) {
      setError(err?.response?.data?.error || 'Failed to load dashboard');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchDashboard();
  }, [fetchDashboard]);

  // Real-time: capacity updates
  useSocket('pre_order:capacityUpdate', (payload: any) => {
    setData((prev) => {
      if (!prev) return prev;
      const updated = prev.item_breakdown.map((item) => {
        if (item.menu_item_id === payload.itemId) {
          return {
            ...item,
            remaining: payload.remaining,
            status: payload.status,
            booked_qty: item.pre_order_limit - payload.remaining,
          };
        }
        return item;
      });
      return { ...prev, item_breakdown: updated };
    });
  });

  // Real-time: now serving
  useSocket('canteen:nowServing', (payload: any) => {
    setNowServing(payload.tokenNumber);
  });

  // Real-time: new order placed
  useSocket('order:tokenGenerated', () => {
    fetchDashboard();
  });

  // Real-time: order status updated
  useSocket('order:statusUpdate', () => {
    fetchDashboard();
  });

  const updateNowServing = async (tokenNumber: number, slotName?: string) => {
    await api.patch('/admin/token-queue/now-serving', {
      token_number: tokenNumber,
      slot_name: slotName,
    });
    setNowServing(tokenNumber);
  };

  const updateLimit = async (itemId: string, newLimit: number) => {
    await api.patch(`/admin/menu/${itemId}/pre-order-limit`, {
      pre_order_limit: newLimit,
    });
    await fetchDashboard();
  };

  return { data, nowServing, loading, error, fetchDashboard, updateNowServing, updateLimit };
}

// ─── usePreOrderQueue ──────────────────────────────────────────────────────
export function usePreOrderQueue(filters: {
  meal_slot?: string;
  status?: string;
  department?: string;
}) {
  const [orders, setOrders] = useState<PreOrderItem[]>([]);
  const [slot, setSlot] = useState<SlotInfo | null>(null);
  const [nowServing, setNowServing] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchQueue = useCallback(async () => {
    try {
      setLoading(true);
      const params = new URLSearchParams();
      if (filters.meal_slot)  params.set('meal_slot', filters.meal_slot);
      if (filters.status)     params.set('status', filters.status);
      if (filters.department) params.set('department', filters.department);

      const [ordersRes, queueRes] = await Promise.all([
        api.get(`/admin/pre-order/orders?${params.toString()}`),
        api.get('/admin/token-queue'),
      ]);

      setOrders(ordersRes.data.orders);
      setSlot(queueRes.data.slot);
      setNowServing(queueRes.data.now_serving || 0);
      setError(null);
    } catch (err: any) {
      setError(err?.response?.data?.error || 'Failed to load queue');
    } finally {
      setLoading(false);
    }
  }, [filters.meal_slot, filters.status, filters.department]);

  useEffect(() => {
    fetchQueue();
  }, [fetchQueue]);

  useSocket('order:statusUpdate', () => fetchQueue());
  useSocket('canteen:nowServing', (payload: any) => setNowServing(payload.tokenNumber));

  const updateOrderStatus = async (orderId: string, status: string) => {
    await api.patch(`/admin/pre-order/${orderId}/status`, { status });
    await fetchQueue();
  };

  return { orders, slot, nowServing, loading, error, fetchQueue, updateOrderStatus };
}
