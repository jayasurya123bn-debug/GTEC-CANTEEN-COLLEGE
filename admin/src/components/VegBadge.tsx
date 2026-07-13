export default function VegBadge({ type = 'veg' }: { type?: 'veg' | 'vegan' }) {
  return (
    <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-veg-50 text-primary border border-primary/20">
      <span className="mr-1 text-[10px]">🌿</span>
      {type === 'vegan' ? 'Vegan' : 'Veg'}
    </span>
  );
}
