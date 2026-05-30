import React, { useState, useEffect } from 'react';

const TopBar = () => {
  const [showNotifications, setShowNotifications] = useState(false);
  const [currentTime, setCurrentTime] = useState(new Date());

  useEffect(() => {
    const timer = setInterval(() => setCurrentTime(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  return (
    <header className="flex justify-between items-center h-16 px-margin-mobile w-full top-0 sticky bg-background border-b border-outline-variant z-40">
      <button className="md:hidden text-on-surface-variant hover:bg-surface-variant transition-colors p-2 rounded active:scale-95 duration-100">
        <span className="material-symbols-outlined">menu</span>
      </button>
      <div className="hidden md:flex text-on-surface-variant p-2">
        <span className="material-symbols-outlined">security</span>
      </div>
      <div className="font-label-caps text-label-caps tracking-widest text-primary">ARGUS_KE</div>
      
      <div className="flex items-center gap-4">
        <div className="hidden md:flex items-center gap-2 font-data-mono text-data-mono text-primary text-sm">
          <span className="material-symbols-outlined text-sm">schedule</span>
          <span>{currentTime.toLocaleString()}</span>
        </div>
        
        <div className="relative">
          <button 
            onClick={() => setShowNotifications(!showNotifications)}
            className="text-on-surface-variant hover:bg-surface-variant transition-colors p-2 rounded active:scale-95 duration-100 relative"
          >
            <span className="material-symbols-outlined">notifications</span>
            <span className="absolute top-2 right-2 w-2 h-2 bg-secondary-container rounded-full border border-background"></span>
          </button>
          
          {showNotifications && (
            <div className="absolute right-0 mt-2 w-80 bg-surface-container border border-outline-variant rounded-lg shadow-xl z-50">
              <div className="p-3 border-b border-outline-variant">
                <span className="font-label-caps text-label-caps text-on-surface">NOTIFICATIONS</span>
              </div>
              <div className="max-h-96 overflow-y-auto">
                <div className="p-3 border-b border-outline-variant hover:bg-surface-variant transition-colors">
                  <div className="flex items-start gap-2">
                    <span className="material-symbols-outlined text-primary text-sm">assignment_late</span>
                    <div>
                      <p className="text-sm text-on-surface">New report submitted</p>
                      <p className="text-xs text-outline">2 minutes ago</p>
                    </div>
                  </div>
                </div>
                <div className="p-3 border-b border-outline-variant hover:bg-surface-variant transition-colors">
                  <div className="flex items-start gap-2">
                    <span className="material-symbols-outlined text-secondary-container text-sm">warning</span>
                    <div>
                      <p className="text-sm text-on-surface">Amber Alert #KE-2023-894 active</p>
                      <p className="text-xs text-outline">15 minutes ago</p>
                    </div>
                  </div>
                </div>
                <div className="p-3 hover:bg-surface-variant transition-colors">
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
          )}
        </div>
      </div>
    </header>
  );
};

export default TopBar;
