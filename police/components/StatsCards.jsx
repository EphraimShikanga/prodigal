import React from 'react';

const StatsCards = ({ stats, successRate }) => {
  const cards = [
    { label: 'ACTIVE ALERTS', value: stats.activeAlerts || 3, icon: 'notifications_active', color: 'error' },
    { label: 'CASE PROFILES', value: stats.total || 8, icon: 'description', color: 'primary' },
    { label: 'ACTIVE CAMERAS', value: stats.activeCameras || 12, icon: 'videocam', color: 'primary' },
    { label: 'SYSTEM UPTIME', value: stats.uptime || '99.9%', icon: 'check_circle', color: 'success' },
  ];

  return (
    <div className="grid grid-cols-2 md:grid-cols-5 gap-4 mb-6">
      {cards.map((card, idx) => (
        <div key={idx} className="bg-surface-container rounded-lg border border-outline-variant p-4">
          <div className="flex items-center justify-between mb-2">
            <span className={`material-symbols-outlined text-${card.color}`}>{card.icon}</span>
            <span className="text-2xl font-data-mono font-bold text-on-surface">{card.value}</span>
          </div>
          <p className="text-label-caps text-outline text-xs">{card.label}</p>
        </div>
      ))}
    </div>
  );
};

export default StatsCards;
