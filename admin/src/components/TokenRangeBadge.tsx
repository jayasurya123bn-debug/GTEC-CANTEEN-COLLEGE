'use client';

interface TokenRangeBadgeProps {
  tokenStart: number;
  tokenEnd: number;
  className?: string;
  size?: 'sm' | 'md' | 'lg';
}

export default function TokenRangeBadge({
  tokenStart,
  tokenEnd,
  className = '',
  size = 'md',
}: TokenRangeBadgeProps) {
  const sizeClasses = {
    sm: 'text-xs px-2 py-0.5',
    md: 'text-sm px-3 py-1',
    lg: 'text-base px-4 py-1.5 font-bold',
  };

  const single = tokenStart === tokenEnd;

  return (
    <span
      className={`inline-flex items-center rounded-full bg-green-100 text-green-800 font-semibold ring-1 ring-green-300 ${sizeClasses[size]} ${className}`}
    >
      {single
        ? `Token #${tokenEnd}`
        : `Token #${tokenStart}–${tokenEnd}`}
    </span>
  );
}
