'use client';
import { useEffect, useState } from 'react';

interface NowServingDisplayProps {
  tokenNumber: number;
  slotName?: string;
  className?: string;
}

export default function NowServingDisplay({
  tokenNumber,
  slotName,
  className = '',
}: NowServingDisplayProps) {
  const [pulse, setPulse] = useState(true);

  // Re-trigger pulse animation on token change
  useEffect(() => {
    setPulse(false);
    const t = setTimeout(() => setPulse(true), 50);
    return () => clearTimeout(t);
  }, [tokenNumber]);

  return (
    <div className={`flex flex-col items-center justify-center ${className}`}>
      {slotName && (
        <p className="text-xs font-semibold uppercase tracking-widest text-green-600 mb-1">
          {slotName}
        </p>
      )}
      <p className="text-xs text-gray-500 mb-2 font-medium uppercase tracking-wide">
        Now Serving
      </p>
      <div className="relative flex items-center justify-center">
        {/* Pulsing ring */}
        {pulse && tokenNumber > 0 && (
          <span className="absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-30 animate-ping" />
        )}
        <div className="relative flex items-center justify-center w-28 h-28 rounded-full bg-gradient-to-br from-green-400 to-green-700 shadow-lg shadow-green-300">
          <span className="text-white font-black text-4xl leading-none">
            #{tokenNumber > 0 ? tokenNumber : '—'}
          </span>
        </div>
      </div>
      {tokenNumber === 0 && (
        <p className="text-xs text-gray-400 mt-2">Not started yet</p>
      )}
    </div>
  );
}
