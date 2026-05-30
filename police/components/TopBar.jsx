import React, { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';

const TopBar = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [showNotifications, setShowNotifications] = useState(false);
  const [currentTime, setCurrentTime] = useState(new Date());

  useEffect(() => {
    const timer = setInterval(() => setCurrentTime(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  const navItems = [
    { id: 'dashboard', label: 'Dashboard', path: '/' },
    { id: 'alerts', label: 'Alerts', path: '/alerts' },
  ];

  return (
    <header className="flex flex-col items-center w-full top-0 sticky bg-background border-b border-outline-variant z-40">
      {/* Top row with logo and time */}
      <div className="flex justify-between items-center w-full h-12 px-margin-mobile">
        <div className="font-label-caps text-label-caps tracking-widest text-primary">ARGUS_KE</div>
        <div className="flex items-center gap-2 font-data-mono text-data-mono text-primary text-sm">
          <span className="material-symbols-outlined text-sm">schedule</span>
          <span>{currentTime.toLocaleString()}</span>
        </div>
      </div>

      {/* Navigation row */}
      <div className="flex justify-center items-center w-full h-14 bg-surface-container border-b border-outline-variant">
        <div className="flex gap-2 px-4">
          {navItems.map(item => (
            <button
              key={item.id}
              onClick={() => navigate(item.path)}
              className={`font-label-caps text-label-caps px-4 py-2 rounded transition-colors ${
                location.pathname === item.path
                  ? 'bg-primary text-on-primary'
                  : 'text-on-surface-variant hover:bg-surface-variant hover:text-on-surface'
              }`}
            >
              {item.label}
            </button>
          ))}
        </div>

        {/* Notifications button */}
        <div className="ml-4">
          <button 
            onClick={() => setShowNotifications(!showNotifications)}
            className="text-on-surface-variant hover:bg-surface-variant transition-colors p-2 rounded active:scale-95 duration-100 relative"
          >
            <span className="material-symbols-outlined">notifications</span>
            <span className="absolute top-2 right-2 w-2 h-2 bg-secondary-container rounded-full border border-background"></span>
          </button>
        </div>
      </div>

      {/* Notifications Popup Modal */}
      {showNotifications && (
        <div className="fixed inset-0 bg-black/50 z-[100] flex items-center justify-center p-4" onClick={() => setShowNotifications(false)}>
          <div className="bg-surface-container border border-outline-variant rounded-lg shadow-xl w-full max-w-2xl max-h-[80vh] overflow-hidden" onClick={(e) => e.stopPropagation()}>
            <div className="flex justify-between items-center p-4 border-b border-outline-variant">
              <span className="font-label-caps text-label-caps text-on-surface">NOTIFICATIONS</span>
              <button onClick={() => setShowNotifications(false)} className="text-on-surface-variant hover:text-on-surface">
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>
            <div className="max-h-96 overflow-y-auto p-4">
              <div className="p-3 border-b border-outline-variant hover:bg-surface-variant transition-colors rounded">
                <div className="flex items-start gap-2">
                  <span className="material-symbols-outlined text-primary text-sm">assignment_late</span>
                  <div>
                    <p className="text-sm text-on-surface">New report submitted</p>
                    <p className="text-xs text-outline">2 minutes ago</p>
                  </div>
                </div>
              </div>
              <div className="p-3 border-b border-outline-variant hover:bg-surface-variant transition-colors rounded">
                <div className="flex items-start gap-2">
                  <span className="material-symbols-outlined text-secondary-container text-sm">warning</span>
                  <div>
                    <p className="text-sm text-on-surface">Amber Alert #KE-2023-894 active</p>
                    <p className="text-xs text-outline">15 minutes ago</p>
                  </div>
                </div>
              </div>
              <div className="p-3 hover:bg-surface-variant transition-colors rounded">
                <div className="flex items-start gap-2">
                  <span className="material-symbols-outlined text-success text-sm">check_circle</span>
                  <div>
                    <p className="text-sm text-on-surface">Case OB-7488B verified</p>
                    <p className="text-xs text-outline">1 hour ago</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </header>
  );
};

export default TopBar;
