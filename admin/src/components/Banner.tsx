import Image from 'next/image';
import { useAuth } from '../context/AuthContext';
import { LogOut } from 'lucide-react';

export default function Banner() {
  const { user, logout } = useAuth();

  return (
    <div className="w-full bg-card shadow-sm border-b border-border">
      <div className="flex justify-between items-center px-6 py-3">
        {/* Left: Logo */}
        <div className="flex items-center space-x-3">
          <div className="relative w-8 h-8 rounded-full overflow-hidden border border-primary">
            <Image 
              src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrTnuNmoXMfrv2kq0V8mxmPXDzx00wQFxedgi9ixZyRA&s=10"
              alt="GTEC Logo"
              layout="fill"
              objectFit="cover"
            />
          </div>
          <span className="font-bold text-white text-lg hidden sm:block">
            GTEC Pure Veg Canteen <span className="text-primary font-normal">| Admin Panel</span>
          </span>
        </div>

        {/* Right: User */}
        <div className="flex items-center space-x-4">
          <div className="text-sm text-right hidden sm:block">
            <p className="font-semibold text-white">{user?.name}</p>
            <p className="text-gray-400 text-xs capitalize">{user?.role}</p>
          </div>
          <button 
            onClick={logout}
            className="p-2 text-gray-400 hover:text-red-500 hover:bg-red-500/10 rounded-full transition-colors"
            title="Logout"
          >
            <LogOut size={20} />
          </button>
        </div>
      </div>
    </div>
  );
}
