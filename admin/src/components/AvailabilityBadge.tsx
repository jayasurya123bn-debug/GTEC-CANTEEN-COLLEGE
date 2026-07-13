export default function AvailabilityBadge({ status }: { status: 'available' | 'limited' | 'sold_out' }) {
  const config = {
    available: { bg: 'bg-green-100', text: 'text-green-800', label: 'Available' },
    limited: { bg: 'bg-amber-100', text: 'text-amber-800', label: 'Limited' },
    sold_out: { bg: 'bg-red-100', text: 'text-red-800', label: 'Sold Out' },
  };

  const { bg, text, label } = config[status] || config.available;

  return (
    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${bg} ${text}`}>
      {label}
    </span>
  );
}
