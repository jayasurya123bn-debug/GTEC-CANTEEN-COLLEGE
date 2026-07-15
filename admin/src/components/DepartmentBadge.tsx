'use client';

type Department = 'CSE' | 'ECE' | 'EEE' | 'MECH' | 'CIVIL' | 'IT' | 'AI&DS' | 'BME' | 'CHEM';

interface DepartmentBadgeProps {
  department: string;
  className?: string;
}

const DEPT_COLORS: Record<Department, { bg: string; text: string; ring: string }> = {
  CSE:    { bg: 'bg-blue-100',    text: 'text-blue-800',    ring: 'ring-blue-300' },
  ECE:    { bg: 'bg-purple-100',  text: 'text-purple-800',  ring: 'ring-purple-300' },
  EEE:    { bg: 'bg-yellow-100',  text: 'text-yellow-800',  ring: 'ring-yellow-300' },
  MECH:   { bg: 'bg-orange-100',  text: 'text-orange-800',  ring: 'ring-orange-300' },
  CIVIL:  { bg: 'bg-stone-100',   text: 'text-stone-800',   ring: 'ring-stone-300' },
  IT:     { bg: 'bg-cyan-100',    text: 'text-cyan-800',    ring: 'ring-cyan-300' },
  'AI&DS':{ bg: 'bg-pink-100',    text: 'text-pink-800',    ring: 'ring-pink-300' },
  BME:    { bg: 'bg-rose-100',    text: 'text-rose-800',    ring: 'ring-rose-300' },
  CHEM:   { bg: 'bg-teal-100',    text: 'text-teal-800',    ring: 'ring-teal-300' },
};

const DEFAULT_COLORS = { bg: 'bg-gray-100', text: 'text-gray-800', ring: 'ring-gray-300' };

export default function DepartmentBadge({ department, className = '' }: DepartmentBadgeProps) {
  const colors = DEPT_COLORS[department as Department] || DEFAULT_COLORS;

  return (
    <span
      className={`inline-flex items-center rounded-md text-xs font-bold px-2 py-0.5 ring-1 ${colors.bg} ${colors.text} ${colors.ring} ${className}`}
    >
      {department}
    </span>
  );
}
