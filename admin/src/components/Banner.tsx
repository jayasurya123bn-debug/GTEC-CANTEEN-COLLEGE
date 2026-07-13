import Image from 'next/image';
import { useAuth } from '../context/AuthContext';
import { LogOut } from 'lucide-react';

export default function Banner() {
  const { user, logout } = useAuth();

  return (
    <div className="w-full bg-white shadow-sm border-b-2 border-primary">
      <div className="flex justify-between items-center px-6 py-3">
        {/* Left: Logo */}
        <div className="flex items-center space-x-3">
          <div className="relative w-8 h-8">
            <Image 
              src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTm3g3mMzC7F1NuBc-kiDLH7NwnJzsqwOQfW6x-Vkd54g&s=10"
              alt="GTEC Logo"
              layout="fill"
              objectFit="contain"
            />
          </div>
          <span className="font-bold text-gray-800 text-lg hidden sm:block">
            GTEC Pure Veg Canteen <span className="text-primary font-normal">| Admin Panel</span>
          </span>
        </div>

        {/* Right: User */}
        <div className="flex items-center space-x-4">
          <div className="text-sm text-right hidden sm:block">
            <p className="font-semibold text-gray-800">{user?.name}</p>
            <p className="text-gray-500 text-xs capitalize">{user?.role}</p>
          </div>
          <button 
            onClick={logout}
            className="p-2 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-full transition-colors"
            title="Logout"
          >
            <LogOut size={20} />
          </button>
        </div>
      </div>
    </div>
  );
}
