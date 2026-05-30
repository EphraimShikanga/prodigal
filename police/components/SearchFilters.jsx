import React from 'react';

const SearchFilters = ({ searchTerm, setSearchTerm, statusFilter, setStatusFilter }) => {
  const statuses = [
    { value: 'all', label: 'ALL' },
    { value: 'pending', label: 'PENDING' },
    { value: 'verified', label: 'VERIFIED' },
    { value: 'found', label: 'FOUND' },
    { value: 'rejected', label: 'REJECTED' },
  ];

  return (
    <div className="glass-panel rounded-lg p-4 flex flex-col lg:flex-row gap-4 items-start lg:items-center justify-between mb-6">
      <div className="flex bg-surface-container rounded-DEFAULT p-1 w-full lg:w-auto">
        {statuses.map(status => (
          <button
            key={status.value}
            onClick={() => setStatusFilter(status.value)}
            className={`flex-1 lg:flex-none px-6 py-2 rounded font-label-caps text-label-caps transition-colors ${
              statusFilter === status.value
                ? 'bg-surface-variant text-primary border border-outline-variant shadow-sm'
                : 'text-on-surface-variant hover:text-on-surface hover:bg-surface-container-high'
            }`}
          >
            {status.label}
          </button>
        ))}
      </div>
      
      <div className="flex flex-col sm:flex-row gap-4 w-full lg:w-auto">
        <div className="relative w-full sm:w-64">
          <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-outline text-sm">search</span>
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full bg-surface-container-lowest border border-outline-variant rounded-DEFAULT py-2 pl-9 pr-3 font-body-sm text-body-sm text-on-surface placeholder:text-outline focus:border-primary focus:ring-1 focus:ring-primary focus:outline-none transition-all"
            placeholder="Search OB Number or Name..."
          />
        </div>
        
        <div className="flex items-center gap-2 w-full sm:w-auto">
          <span className="material-symbols-outlined text-outline">sort</span>
          <select className="w-full sm:w-auto bg-surface-container-lowest border border-outline-variant rounded-DEFAULT py-2 px-3 pr-8 font-body-sm text-body-sm text-on-surface focus:border-primary focus:ring-1 focus:ring-primary focus:outline-none appearance-none">
            <option>High Priority</option>
            <option>Recent</option>
            <option>Nearby</option>
          </select>
        </div>
      </div>
    </div>
  );
};

export default SearchFilters;
