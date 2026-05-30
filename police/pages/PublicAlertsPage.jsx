import React, { useState, useEffect } from 'react';
import { apiService } from '../services/api';
import { mapFrontendCasesArray } from '../services/dataMapper';

const PublicAlertsPage = () => {
  const [alerts, setAlerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchPublicAlerts = async () => {
      try {
        setLoading(true);
        const publicAlerts = await apiService.getPublicAlerts();
        const frontendAlerts = mapFrontendCasesArray(publicAlerts);
        setAlerts(frontendAlerts);
        setError(null);
      } catch (err) {
        console.error('Failed to fetch public alerts:', err);
        setError('Failed to load public alerts.');
      } finally {
        setLoading(false);
      }
    };

    fetchPublicAlerts();
  }, []);

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="font-headline-lg text-headline-lg text-on-surface mb-2">Public Alerts - Verified Missing Persons</h1>
        <p className="font-body-sm text-body-sm text-on-surface-variant">
          Verified missing person alerts visible to the public
        </p>
      </div>

      {loading ? (
        <div className="bg-surface-container rounded-lg p-8 text-center border border-outline-variant">
          <span className="material-symbols-outlined text-4xl text-outline mb-2 animate-spin">refresh</span>
          <p className="text-on-surface-variant">Loading public alerts...</p>
        </div>
      ) : error ? (
        <div className="bg-error-container rounded-lg p-8 text-center border border-error">
          <span className="material-symbols-outlined text-4xl text-error mb-2">error</span>
          <p className="text-on-error-container">{error}</p>
        </div>
      ) : alerts.length === 0 ? (
        <div className="bg-surface-container rounded-lg p-8 text-center border border-outline-variant">
          <span className="material-symbols-outlined text-4xl text-outline mb-2">inbox</span>
          <p className="text-on-surface-variant">No verified public alerts at this time</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {alerts.map((alert) => (
            <div key={alert.id} className="bg-surface border border-primary/50 rounded-lg overflow-hidden">
              <div className="h-48 relative overflow-hidden bg-surface-container-lowest">
                <img
                  src={alert.imageUrl}
                  alt={alert.childName}
                  className="w-full h-full object-cover"
                />
                <div className="absolute top-2 right-2 bg-primary text-on-primary px-2 py-1 rounded text-xs font-label-caps animate-pulse">
                  AMBER ALERT
                </div>
                <div className="absolute bottom-0 left-0 w-full bg-gradient-to-t from-background to-transparent h-24"></div>
              </div>
              <div className="p-4">
                <h3 className="font-headline-md text-headline-md text-on-surface mb-2">{alert.childName}</h3>
                <div className="space-y-2 mb-4">
                  <div className="flex justify-between">
                    <span className="font-body-sm text-body-sm text-outline">Age / Gender</span>
                    <span className="font-data-mono text-data-mono text-on-surface">{alert.age} / {alert.gender}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="font-body-sm text-body-sm text-outline">Last Seen</span>
                    <span className="font-data-mono text-data-mono text-on-surface text-right">{alert.lastSeen}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="font-body-sm text-body-sm text-outline">Reported</span>
                    <span className="font-data-mono text-data-mono text-on-surface text-right">{new Date(alert.reportedAt).toLocaleDateString()}</span>
                  </div>
                </div>
                <p className="text-body-sm text-on-surface-variant mb-4 line-clamp-2">
                  {alert.description}
                </p>
                <div className="bg-primary/10 border border-primary/30 rounded p-3">
                  <div className="flex items-center gap-2 text-primary text-sm">
                    <span className="material-symbols-outlined text-[16px]">warning</span>
                    <span className="font-label-caps text-label-caps">PUBLIC ALERT ACTIVE</span>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default PublicAlertsPage;
