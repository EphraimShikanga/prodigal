import React, { useState, useEffect } from 'react';
import { apiService } from '../services/api';
import { mapFrontendCasesArray } from '../services/dataMapper';

const AlertsPage = () => {
  const [alerts, setAlerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchPendingAlerts = async () => {
      try {
        setLoading(true);
        const pendingAlerts = await apiService.getPendingAlerts();
        const frontendAlerts = mapFrontendCasesArray(pendingAlerts);
        setAlerts(frontendAlerts);
        setError(null);
      } catch (err) {
        console.error('Failed to fetch pending alerts:', err);
        setError('Failed to load pending alerts.');
      } finally {
        setLoading(false);
      }
    };

    fetchPendingAlerts();
  }, []);

  const handleVerify = async (alertId) => {
    try {
      await apiService.verifyAlert(alertId);
      // Refresh the alerts list
      const pendingAlerts = await apiService.getPendingAlerts();
      const frontendAlerts = mapFrontendCasesArray(pendingAlerts);
      setAlerts(frontendAlerts);
    } catch (err) {
      console.error('Failed to verify alert:', err);
      alert('Failed to verify alert. Please try again.');
    }
  };

  const handleReject = async (alertId) => {
    try {
      await apiService.updateCaseStatus(alertId, 'REJECTED');
      // Refresh the alerts list
      const pendingAlerts = await apiService.getPendingAlerts();
      const frontendAlerts = mapFrontendCasesArray(pendingAlerts);
      setAlerts(frontendAlerts);
    } catch (err) {
      console.error('Failed to reject alert:', err);
      alert('Failed to reject alert. Please try again.');
    }
  };

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="font-headline-lg text-headline-lg text-on-surface mb-2">Mobile Reports - Pending Verification</h1>
        <p className="font-body-sm text-body-sm text-on-surface-variant">
          Review and verify missing person reports submitted via mobile app
        </p>
      </div>

      {loading ? (
        <div className="bg-surface-container rounded-lg p-8 text-center border border-outline-variant">
          <span className="material-symbols-outlined text-4xl text-outline mb-2 animate-spin">refresh</span>
          <p className="text-on-surface-variant">Loading pending alerts...</p>
        </div>
      ) : error ? (
        <div className="bg-error-container rounded-lg p-8 text-center border border-error">
          <span className="material-symbols-outlined text-4xl text-error mb-2">error</span>
          <p className="text-on-error-container">{error}</p>
        </div>
      ) : alerts.length === 0 ? (
        <div className="bg-surface-container rounded-lg p-8 text-center border border-outline-variant">
          <span className="material-symbols-outlined text-4xl text-outline mb-2">inbox</span>
          <p className="text-on-surface-variant">No pending mobile reports to verify</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {alerts.map((alert) => (
            <div key={alert.id} className="bg-surface border border-outline-variant rounded-lg overflow-hidden">
              <div className="h-48 relative overflow-hidden bg-surface-container-lowest">
                <img
                  src={alert.imageUrl}
                  alt={alert.childName}
                  className="w-full h-full object-cover"
                />
                <div className="absolute top-2 right-2 bg-secondary-container text-on-secondary-container px-2 py-1 rounded text-xs font-label-caps">
                  MOBILE REPORT
                </div>
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
                    <span className="font-body-sm text-body-sm text-outline">Reporter</span>
                    <span className="font-data-mono text-data-mono text-on-surface text-right">{alert.reporterName}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="font-body-sm text-body-sm text-outline">Phone</span>
                    <span className="font-data-mono text-data-mono text-on-surface text-right">{alert.reporterPhone}</span>
                  </div>
                </div>
                <p className="text-body-sm text-on-surface-variant mb-4 line-clamp-2">
                  {alert.description}
                </p>
                <div className="flex gap-2">
                  <button
                    onClick={() => handleVerify(alert.id)}
                    className="flex-1 bg-primary/20 text-primary font-label-caps text-label-caps px-3 py-2 rounded hover:bg-primary/30 transition-colors flex items-center justify-center gap-1"
                  >
                    <span className="material-symbols-outlined text-[16px]">check</span>
                    VERIFY
                  </button>
                  <button
                    onClick={() => handleReject(alert.id)}
                    className="flex-1 bg-error/20 text-error font-label-caps text-label-caps px-3 py-2 rounded hover:bg-error/30 transition-colors flex items-center justify-center gap-1"
                  >
                    <span className="material-symbols-outlined text-[16px]">close</span>
                    REJECT
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default AlertsPage;
