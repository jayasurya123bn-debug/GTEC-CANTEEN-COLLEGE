import React from 'react';

interface StatusToggleProps {
  isOpen: boolean;
  onChange: (isOpen: boolean) => void;
  disabled?: boolean;
}

export default function StatusToggle({ isOpen, onChange, disabled = false }: StatusToggleProps) {
  return (
    <button
      type="button"
      className={`${
        isOpen ? 'bg-primary' : 'bg-border'
      } relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 ${disabled ? 'opacity-50 cursor-not-allowed' : ''}`}
      role="switch"
      aria-checked={isOpen}
      onClick={() => !disabled && onChange(!isOpen)}
      disabled={disabled}
    >
      <span className="sr-only">Toggle canteen status</span>
      <span
        aria-hidden="true"
        className={`${
          isOpen ? 'translate-x-5' : 'translate-x-0'
        } pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out`}
      />
    </button>
  );
}
