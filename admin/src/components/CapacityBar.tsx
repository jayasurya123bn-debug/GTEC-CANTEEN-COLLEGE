'use client';

interface CapacityBarProps {
  booked: number;
  limit: number;
  showLabel?: boolean;
  className?: string;
}

export default function CapacityBar({
  booked,
  limit,
  showLabel = true,
  className = '',
}: CapacityBarProps) {
  const pct = limit > 0 ? Math.min(100, (booked / limit) * 100) : 100;
  const remaining = Math.max(0, limit - booked);

  let barColor = 'bg-green-500';
  let textColor = 'text-green-700';
  let label = `${remaining} left`;

  if (pct >= 100) {
    barColor = 'bg-red-500';
    textColor = 'text-red-700';
    label = 'Sold Out';
  } else if (pct >= 80) {
    barColor = 'bg-amber-400';
    textColor = 'text-amber-700';
    label = `Only ${remaining} left`;
  }

  return (
    <div className={`w-full ${className}`}>
      <div className="w-full bg-gray-200 rounded-full h-2.5 overflow-hidden">
        <div
          className={`h-2.5 rounded-full transition-all duration-500 ${barColor}`}
          style={{ width: `${pct}%` }}
        />
      </div>
      {showLabel && (
        <div className="flex justify-between mt-0.5">
          <span className={`text-xs font-medium ${textColor}`}>{label}</span>
          <span className="text-xs text-gray-400">
            {booked}/{limit}
          </span>
        </div>
      )}
    </div>
  );
}
