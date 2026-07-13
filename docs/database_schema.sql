-- GTEC Pure Veg Canteen System - PostgreSQL Database Schema & Seeds

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ENUMS
CREATE TYPE user_role AS ENUM ('student', 'admin');
CREATE TYPE canteen_busyness AS ENUM ('low', 'moderate', 'high', 'packed');
CREATE TYPE dietary_tag_enum AS ENUM ('veg', 'vegan');
CREATE TYPE item_availability AS ENUM ('available', 'limited', 'sold_out');
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled');

-- USERS TABLE
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role user_role DEFAULT 'student',
    phone VARCHAR(20),
    avatar_url TEXT,
    fcm_token TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- CANTEEN STATUS TABLE
CREATE TABLE canteen_status (
    id SERIAL PRIMARY KEY,
    is_open BOOLEAN DEFAULT false,
    busyness canteen_busyness DEFAULT 'low',
    broadcast_message TEXT,
    updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- MENU CATEGORIES TABLE
CREATE TABLE menu_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    display_order INT DEFAULT 0,
    icon_emoji TEXT,
    is_active BOOLEAN DEFAULT true
);

-- MENU ITEMS TABLE (CRITICAL RULE: is_veg MUST BE TRUE)
CREATE TABLE menu_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID REFERENCES menu_categories(id) ON DELETE RESTRICT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    image_url TEXT,
    is_veg BOOLEAN DEFAULT true CHECK (is_veg = true),
    dietary_tag dietary_tag_enum DEFAULT 'veg',
    availability item_availability DEFAULT 'available',
    limited_quantity INT,
    avg_rating DECIMAL(3,2) DEFAULT 0.00,
    rating_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- REVIEWS TABLE
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID REFERENCES menu_items(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    is_approved BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- FAVOURITES TABLE
CREATE TABLE favourites (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    item_id UUID REFERENCES menu_items(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, item_id)
);

-- ORDERS TABLE
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE RESTRICT,
    items JSONB NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    time_slot VARCHAR(50),
    status order_status DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- NOTIFICATIONS TABLE
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    type VARCHAR(50),
    data JSONB,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- SCHEDULED MENUS TABLE
CREATE TABLE scheduled_menus (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID REFERENCES menu_items(id) ON DELETE CASCADE,
    scheduled_date DATE NOT NULL,
    meal_type VARCHAR(50),
    created_by UUID REFERENCES users(id) ON DELETE SET NULL
);

-- INDEXES
CREATE INDEX idx_menu_items_category ON menu_items(category_id);
CREATE INDEX idx_menu_items_is_active ON menu_items(is_active);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_reviews_item_id ON reviews(item_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_scheduled_menus_date ON scheduled_menus(scheduled_date);


-- ==========================================
-- SEED DATA
-- ==========================================

-- Seed Categories
INSERT INTO menu_categories (id, name, display_order, icon_emoji) VALUES
('c0000000-0000-0000-0000-000000000001', 'Breakfast', 1, '🥞'),
('c0000000-0000-0000-0000-000000000002', 'Lunch', 2, '🍛'),
('c0000000-0000-0000-0000-000000000003', 'Snacks', 3, '🥟'),
('c0000000-0000-0000-0000-000000000004', 'Dinner', 4, '🥘'),
('c0000000-0000-0000-0000-000000000005', 'Beverages', 5, '☕');

-- Seed Menu Items (All 100% Vegetarian)
INSERT INTO menu_items (id, category_id, name, description, price, image_url, is_veg, dietary_tag, availability) VALUES
-- Breakfast
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000001', 'Idli Sambar (3 Pcs)', 'Soft steamed rice cakes served with hot lentil sambar and coconut chutney.', 40.00, 'https://images.unsplash.com/photo-1589301760014-d929f39ce9de?w=300&h=300&fit=crop', true, 'vegan', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000001', 'Masala Dosa', 'Crispy rice crepe filled with spiced potato curry, served with sambar and chutney.', 50.00, 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=300&h=300&fit=crop', true, 'vegan', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000001', 'Pongal', 'Traditional South Indian rice and lentil porridge seasoned with black pepper and ghee.', 45.00, 'https://images.unsplash.com/photo-1630409346824-4f0e7b080087?w=300&h=300&fit=crop', true, 'veg', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000001', 'Puri Sabji (3 Pcs)', 'Deep-fried whole wheat bread served with mild potato curry.', 50.00, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=300&h=300&fit=crop', true, 'vegan', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000001', 'Aloo Paratha', 'Whole wheat flatbread stuffed with spiced potatoes, served with curd.', 60.00, 'https://images.unsplash.com/photo-1626200419189-390888251e6b?w=300&h=300&fit=crop', true, 'veg', 'available'),

-- Lunch
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000002', 'South Indian Veg Meals', 'Unlimited rice, sambar, rasam, kootu, poriyal, papad, and pickle.', 80.00, 'https://images.unsplash.com/photo-1626779848529-573562479e00?w=300&h=300&fit=crop', true, 'veg', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000002', 'Paneer Butter Masala', 'Rich and creamy curry made with paneer, spices, onions, tomatoes, and butter.', 120.00, 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=300&h=300&fit=crop', true, 'veg', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000002', 'Vegetable Biryani', 'Aromatic basmati rice cooked with mixed vegetables and Indian spices.', 100.00, 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=300&h=300&fit=crop', true, 'vegan', 'limited'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000002', 'Dal Tadka', 'Comforting yellow lentil soup tempered with ghee, cumin, and garlic.', 70.00, 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=300&h=300&fit=crop', true, 'veg', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000002', 'Jeera Rice', 'Basmati rice flavored with cumin seeds, perfect with dal.', 60.00, 'https://images.unsplash.com/photo-1618355278487-75898d9ba889?w=300&h=300&fit=crop', true, 'vegan', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000002', 'Roti (2 Pcs)', 'Soft Indian flatbread made from whole wheat flour.', 30.00, 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=300&h=300&fit=crop', true, 'vegan', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000002', 'Sambar Rice', 'Comforting one-pot meal of rice and lentils cooked with vegetables and spices.', 70.00, 'https://images.unsplash.com/photo-1625220194771-7ebdea0b70b9?w=300&h=300&fit=crop', true, 'vegan', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000002', 'Curd Rice', 'Soothing yogurt rice mixed with green chilies, curry leaves, and mustard seeds.', 60.00, 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=300&h=300&fit=crop', true, 'veg', 'available'),

-- Snacks
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000003', 'Samosa (2 Pcs)', 'Deep-fried pastry filled with spiced potatoes and peas.', 30.00, 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=300&h=300&fit=crop', true, 'vegan', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000003', 'Medu Vada (2 Pcs)', 'Crispy, donut-shaped fritters made from urad dal.', 40.00, 'https://images.unsplash.com/photo-1589301760014-d929f39ce9de?w=300&h=300&fit=crop', true, 'vegan', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000003', 'Pani Puri (6 Pcs)', 'Crispy hollow balls filled with spicy mint water, tamarind chutney, and potatoes.', 40.00, 'https://images.unsplash.com/photo-1580979555139-446736a5c13e?w=300&h=300&fit=crop', true, 'vegan', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000003', 'Pav Bhaji', 'Spicy mashed vegetable curry served with soft buttered buns.', 70.00, 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=300&h=300&fit=crop', true, 'veg', 'limited'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000003', 'Gobi Manchurian', 'Indo-Chinese dish of crispy cauliflower florets tossed in a spicy, sweet, and tangy sauce.', 80.00, 'https://images.unsplash.com/photo-1625938146369-adc83368bda7?w=300&h=300&fit=crop', true, 'vegan', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000003', 'Veg Spring Roll', 'Crispy rolls filled with shredded vegetables, served with sweet chili sauce.', 60.00, 'https://images.unsplash.com/photo-1590799863456-ccf3ed6283db?w=300&h=300&fit=crop', true, 'vegan', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000003', 'Onion Pakora', 'Crispy and spiced onion fritters made with gram flour.', 45.00, 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?w=300&h=300&fit=crop', true, 'vegan', 'available'),

-- Dinner
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000004', 'Chapati with Kurma', 'Soft whole wheat chapatis served with mixed vegetable kurma.', 70.00, 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=300&h=300&fit=crop', true, 'vegan', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000004', 'Veg Fried Rice', 'Stir-fried rice with finely chopped vegetables and soy sauce.', 90.00, 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=300&h=300&fit=crop', true, 'vegan', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000004', 'Chole Bhature', 'Spicy chickpea curry served with large fried bread.', 80.00, 'https://images.unsplash.com/photo-1626200419189-390888251e6b?w=300&h=300&fit=crop', true, 'vegan', 'sold_out'),

-- Beverages
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000005', 'Filter Coffee', 'Traditional South Indian strong coffee brewed with milk.', 25.00, 'https://images.unsplash.com/photo-1514432324607-a125290ca577?w=300&h=300&fit=crop', true, 'veg', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000005', 'Masala Chai', 'Indian tea brewed with milk and aromatic spices.', 20.00, 'https://images.unsplash.com/photo-1542272201-b1ca555f8505?w=300&h=300&fit=crop', true, 'veg', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000005', 'Sweet Lassi', 'Refreshing sweet yogurt drink.', 40.00, 'https://images.unsplash.com/photo-1596162954151-cdcb4c0f70a8?w=300&h=300&fit=crop', true, 'veg', 'available'),
(uuid_generate_v4(), 'c0000000-0000-0000-0000-000000000005', 'Fresh Lime Soda', 'Chilled lime juice mixed with soda, sweet or salt.', 30.00, 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=300&h=300&fit=crop', true, 'vegan', 'available');

-- Seed Canteen Status
INSERT INTO canteen_status (is_open, busyness, broadcast_message) VALUES (true, 'low', 'Welcome to GTEC Pure Veg Canteen!');
