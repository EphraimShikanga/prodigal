import React, { useState } from 'react';

const Sidebar = () => {
  const [activeItem, setActiveItem] = useState('dashboard');

  const navItems = [
    { id: 'alerts', label: 'Alerts', icon: 'notifications_active' },
    { id: 'dashboard', label: 'Dashboard', icon: 'dashboard' },
    { id: 'find-matches', label: 'Find Matches', icon: 'search' },
    { id: 'ai-aging', label: 'AI Aging Detection', icon: 'face_retouching_natural' },
    { id: 'live-camera', label: 'Live Camera', icon: 'videocam' },
    { id: 'activity-log', label: 'Activity Log', icon: 'history' },
  ];

  return (
    <>
      {/* Desktop Sidebar */}
      <nav className="hidden md:flex flex-col items-center py-4 gap-stack-gap fixed left-0 top-0 h-full w-sidebar-width bg-surface-container-lowest border-r border-outline-variant z-50">
        <div className="mb-8 font-label-caps text-label-caps text-primary rotate-[-90deg] whitespace-nowrap mt-12 tracking-widest">
          ARGUS_KE
        </div>
        
        {navItems.map(item => (
          <a
            key={item.id}
            href="#"
            onClick={() => setActiveItem(item.id)}
            className={`w-full flex justify-center py-3 group relative transition-all duration-200 ease-in-out ${
              activeItem === item.id
                ? 'text-primary border-l-4 border-primary bg-surface-variant'
                : 'text-outline border-l-4 border-transparent hover:text-on-surface hover:bg-surface-container'
            }`}
          >
            <span className="material-symbols-outlined">{item.icon}</span>
            <div className="absolute left-full ml-2 px-2 py-1 bg-surface-container-highest text-on-surface text-label-caps font-label-caps rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none z-50">
              {item.label}
            </div>
          </a>
        ))}

        <div className="mt-auto w-full">
          <a href="#" className="text-outline w-full flex justify-center py-3 group relative hover:text-on-surface hover:bg-surface-container transition-all duration-200 ease-in-out">
            <span className="material-symbols-outlined">settings</span>
          </a>
        </div>
      </nav>

      {/* Mobile Bottom Navigation */}
      <nav className="md:hidden flex justify-around items-center px-margin-mobile w-full bg-surface-container border-t border-outline-variant fixed bottom-0 z-50 h-16">
        {navItems.map(item => (
          <a
            key={item.id}
            href="#"
            onClick={() => setActiveItem(item.id)}
            className={`flex flex-col items-center justify-center p-2 transition-transform ${
              activeItem === item.id
                ? 'bg-secondary-container text-on-secondary-container rounded-lg'
                : 'text-on-surface-variant hover:bg-surface-container-high'
            }`}
          >
            <span className="material-symbols-outlined">{item.icon}</span>
            <span className="font-label-caps text-label-caps sr-only">{item.label}</span>
          </a>
        ))}
      </nav>
    </>
  );
};

export default Sidebar;
