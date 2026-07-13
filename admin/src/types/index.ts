export interface User {
  id: string;
  name: string;
  email: string;
  role: 'student' | 'admin';
  phone?: string;
  avatar_url?: string;
}

export interface MenuItem {
  id: string;
  category_id: string;
  name: string;
  description?: string;
  price: string; // decimal as string from PG
  image_url?: string;
  is_veg: true;
  dietary_tag: 'veg' | 'vegan';
  availability: 'available' | 'limited' | 'sold_out';
  limited_quantity?: number;
  avg_rating: string;
  category_name?: string;
}

export interface Order {
  id: string;
  user_id: string;
  user_name: string;
  items: any[];
  total_amount: string;
  status: 'pending' | 'confirmed' | 'preparing' | 'ready' | 'completed' | 'cancelled';
  created_at: string;
}

export interface Review {
  id: string;
  item_id: string;
  user_name: string;
  item_name: string;
  rating: number;
  comment?: string;
  is_approved: boolean;
  created_at: string;
}

export interface CanteenStatus {
  is_open: boolean;
  busyness: 'low' | 'moderate' | 'high' | 'packed';
  broadcast_message?: string;
}
