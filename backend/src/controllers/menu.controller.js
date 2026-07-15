import { 
  getMenuItems, getMenuItemById, 
  createMenuItem, updateMenuItem, updateAvailability, deleteMenuItem 
} from '../models/menuItem.model.js';
import { createGlobalNotification } from '../models/notification.model.js';
import { getCategoryWithCounts } from '../models/menuCategory.model.js';
import { getScheduledMenu, scheduleItem } from '../models/scheduledMenu.model.js';
import { getUsersWhoFavourited } from '../models/favourite.model.js';
import { sendMulticastPushNotification } from '../services/fcm.service.js';
import { getCache, setCache, invalidateCache } from '../services/cache.service.js';
import { getIO } from '../services/socket.service.js';

export const getMenu = async (req, res, next) => {
  try {
    const { category, availability, dietary_tag } = req.query;
    
    // Check Cache if no filters
    const cacheKey = 'menu:all';
    if (!category && !availability && !dietary_tag) {
      const cached = await getCache(cacheKey);
      if (cached) return res.status(200).json(cached);
    }

    const items = await getMenuItems({ category, availability, dietary_tag });
    
    // Group by category
    const grouped = items.reduce((acc, item) => {
      const cat = acc.find(c => c.category === item.category_name);
      if (cat) {
        cat.items.push(item);
      } else {
        acc.push({ category: item.category_name, items: [item] });
      }
      return acc;
    }, []);

    if (!category && !availability && !dietary_tag) {
      await setCache(cacheKey, grouped, 3600);
    }

    res.status(200).json(grouped);
  } catch (error) {
    next(error);
  }
};

export const getCategories = async (req, res, next) => {
  try {
    const categories = await getCategoryWithCounts();
    res.status(200).json(categories);
  } catch (error) {
    next(error);
  }
};

export const getItem = async (req, res, next) => {
  try {
    const item = await getMenuItemById(req.params.id);
    if (!item) return res.status(404).json({ error: 'Item not found' });
    res.status(200).json({ item });
  } catch (error) {
    next(error);
  }
};

export const createMenu = async (req, res, next) => {
  try {
    // is_veg is forced true in the model
    const item = await createMenuItem(req.body);
    await invalidateCache('menu:*');
    
    getIO().emit('menu:itemCreated', item);
    
    // Broadcast notification for new item
    await createGlobalNotification(
      'New Item Added! 🎉', 
      `${item.name} is now available in the canteen.`, 
      'menu_update', 
      { itemId: item.id }
    );
    
    res.status(201).json({ message: 'Item created', item });
  } catch (error) {
    next(error);
  }
};

export const updateMenu = async (req, res, next) => {
  try {
    const item = await updateMenuItem(req.params.id, req.body);
    await invalidateCache('menu:*');
    
    res.status(200).json({ message: 'Item updated', item });
  } catch (error) {
    next(error);
  }
};

export const changeAvailability = async (req, res, next) => {
  try {
    const { availability, limited_quantity } = req.body;
    
    // Fetch old item to check status change
    const oldItem = await getMenuItemById(req.params.id);
    if (!oldItem) return res.status(404).json({ error: 'Item not found' });

    const item = await updateAvailability(req.params.id, availability, limited_quantity);
    await invalidateCache('menu:*');
    
    getIO().emit('menu:itemUpdate', {
      itemId: item.id,
      name: item.name,
      availability: item.availability,
      limitedQuantity: item.limited_quantity
    });

    // FCM Logic: If it was sold_out and is now available
    if (oldItem.availability === 'sold_out' && availability === 'available') {
      const users = await getUsersWhoFavourited(item.id);
      const tokens = users.map(u => u.fcm_token);
      if (tokens.length > 0) {
        await sendMulticastPushNotification(
          tokens,
          'Your Favourite is Back! 🌿',
          `${item.name} is now available to order.`,
          { type: 'item_available', itemId: item.id }
        );
      }
    }

    // Global Notification Logic for sold out and limited
    if (availability === 'sold_out' && oldItem.availability !== 'sold_out') {
      await createGlobalNotification(
        'Item Sold Out! ⚠️', 
        `${item.name} is currently sold out.`, 
        'menu_update', 
        { itemId: item.id }
      );
    } else if (availability === 'limited' && oldItem.availability !== 'limited') {
      await createGlobalNotification(
        'Limited Stock! ⏳', 
        `Only a few portions of ${item.name} are left.`, 
        'menu_update', 
        { itemId: item.id }
      );
    }

    res.status(200).json({ message: 'Availability updated', item });
  } catch (error) {
    next(error);
  }
};

export const deleteMenu = async (req, res, next) => {
  try {
    await deleteMenuItem(req.params.id);
    await invalidateCache('menu:*');
    getIO().emit('menu:itemDeleted', { itemId: req.params.id });
    res.status(200).json({ message: 'Item marked as inactive' });
  } catch (error) {
    next(error);
  }
};

export const getScheduled = async (req, res, next) => {
  try {
    const items = await getScheduledMenu(req.params.date);
    res.status(200).json({ items });
  } catch (error) {
    next(error);
  }
};

export const schedule = async (req, res, next) => {
  try {
    const { item_id, scheduled_date, meal_type } = req.body;
    await scheduleItem(item_id, scheduled_date, meal_type, req.user.id);
    res.status(201).json({ message: 'Scheduled successfully' });
  } catch (error) {
    next(error);
  }
};
