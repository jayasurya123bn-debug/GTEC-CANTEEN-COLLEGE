import React from 'react';

interface StatsCardProps {
  title: string;
  value: string | number;
  icon: React.ElementType;
  trend?: { value: number; isPositive: boolean };
}

export default function StatsCard({ title, value, icon: Icon, trend }: StatsCardProps) {
  return (
    <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100 flex items-center justify-between">
      <div>
        <p className="text-sm font-medium text-gray-500 mb-1">{title}</p>
        <h3 className="text-2xl font-bold text-gray-900">{value}</h3>
        {trend && (
          <p className={`text-xs mt-2 font-medium ${trend.isPositive ? 'text-green-600' : 'text-red-600'}`}>
            {trend.isPositive ? '↑' : '↓'} {Math.abs(trend.value)}% from last week
          </p>
        )}
      </div>
      <div className="w-12 h-12 rounded-full bg-veg-50 flex items-center justify-center text-primary">
        <Icon size={24} />
      </div>
    </div>
  );
}
