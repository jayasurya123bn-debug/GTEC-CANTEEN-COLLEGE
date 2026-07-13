import { getFavourites, addFavourite, removeFavourite, checkFavourite } from '../models/favourite.model.js';
import { getMenuItemById } from '../models/menuItem.model.js';
import { sendPushNotification } from '../services/fcm.service.js';
import { findUserById } from '../models/user.model.js';

export const listFavourites = async (req, res, next) => {
  try {
    const favourites = await getFavourites(req.user.id);
    res.status(200).json({ favourites });
  } catch (error) {
    next(error);
  }
};

export const addFav = async (req, res, next) => {
  try {
    const itemId = req.params.itemId;
    await addFavourite(req.user.id, itemId);
    
    // Check if item is available and notify user
    const item = await getMenuItemById(itemId);
    const user = await findUserById(req.user.id);
    
    if (item && item.availability === 'available' && user.fcm_token) {
      await sendPushNotification(
        user.fcm_token,
        'Great Choice! 🌿',
        `${item.name} is available right now. Pre-order before it runs out!`,
        { type: 'favourite_added', itemId: item.id }
      );
    }
    
    res.status(201).json({ message: 'Added to favourites' });
  } catch (error) {
    next(error);
  }
};

export const removeFav = async (req, res, next) => {
  try {
    await removeFavourite(req.user.id, req.params.itemId);
    res.status(200).json({ message: 'Removed from favourites' });
  } catch (error) {
    next(error);
  }
};

export const checkFav = async (req, res, next) => {
  try {
    const isFavourited = await checkFavourite(req.user.id, req.params.itemId);
    res.status(200).json({ isFavourited });
  } catch (error) {
    next(error);
  }
};
