'use client';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { LayoutDashboard, Utensils, Star, Leaf, Users } from 'lucide-react';

const navItems = [
  { name: 'Dashboard', href: '/', icon: LayoutDashboard },
  { name: 'Menu', href: '/menu', icon: Utensils },
  { name: 'Reviews', href: '/reviews', icon: Star },
  { name: 'Students', href: '/students', icon: Users },
];

export default function Sidebar() {
  const pathname = usePathname();

  return (
    <div className="w-64 bg-card shadow-md h-full min-h-screen flex flex-col border-r border-border">
      <div className="p-6 border-b border-border flex items-center space-x-2">
        <Leaf className="text-primary" size={24} />
        <span className="font-bold text-xl text-white tracking-tight">Pure Veg Admin</span>
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
                  ? 'bg-primary/10 text-primary font-semibold border border-primary/20' 
                  : 'text-gray-400 hover:bg-elevated hover:text-white'
              }`}
            >
              <item.icon size={20} className={isActive ? 'text-primary' : 'text-gray-500'} />
              <span>{item.name}</span>
            </Link>
          );
        })}
      </nav>
      
      <div className="p-4 border-t border-border text-xs text-gray-500 text-center">
        &copy; {new Date().getFullYear()} GTEC College
      </div>
    </div>
  );
}
