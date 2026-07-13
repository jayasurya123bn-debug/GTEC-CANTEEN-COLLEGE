'use client';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { LayoutDashboard, Utensils, ClipboardList, Star, Leaf } from 'lucide-react';

const navItems = [
  { name: 'Dashboard', href: '/', icon: LayoutDashboard },
  { name: 'Menu', href: '/menu', icon: Utensils },
  { name: 'Orders', href: '/orders', icon: ClipboardList },
  { name: 'Reviews', href: '/reviews', icon: Star },
];

export default function Sidebar() {
  const pathname = usePathname();

  return (
    <div className="w-64 bg-white shadow-md h-full min-h-screen flex flex-col">
      <div className="p-6 border-b border-gray-100 flex items-center space-x-2">
        <Leaf className="text-primary" size={24} />
        <span className="font-bold text-xl text-primary tracking-tight">Pure Veg Admin</span>
      </div>
      
      <nav className="flex-1 p-4 space-y-2">
        {navItems.map((item) => {
          const isActive = pathname === item.href || (item.href !== '/' && pathname.startsWith(item.href));
          return (
            <Link 
              key={item.name} 
              href={item.href}
              className={`flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${
                isActive 
                  ? 'bg-veg-50 text-primary font-semibold' 
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
            >
              <item.icon size={20} className={isActive ? 'text-primary' : 'text-gray-400'} />
              <span>{item.name}</span>
            </Link>
          );
        })}
      </nav>
      
      <div className="p-4 border-t border-gray-100 text-xs text-gray-400 text-center">
        &copy; {new Date().getFullYear()} GTEC College
      </div>
    </div>
  );
}
