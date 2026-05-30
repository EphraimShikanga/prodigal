import React, { useState, useEffect } from 'react';
import { apiService } from '../services/api';
import { mapFrontendCasesArray } from '../services/dataMapper';

const FoundPage = () => {
  const [foundCases, setFoundCases] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchFoundCases = async () => {
      try {
        setLoading(true);
        const cases = await apiService.getFoundCases();
        const frontendCases = mapFrontendCasesArray(cases);
        setFoundCases(frontendCases);
        setError(null);
      } catch (err) {
        console.error('Failed to fetch found cases:', err);
        setError('Failed to load found cases.');
      } finally {
        setLoading(false);
      }
    };

    fetchFoundCases();
  }, []);

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="font-headline-lg text-headline-lg text-on-surface mb-2">Found & Resolved Cases</h1>
        <p className="font-body-sm text-body-sm text-on-surface-variant">
          Successfully located missing persons
        </p>
      </div>

      {loading ? (
        <div className="bg-surface-container rounded-lg p-8 text-center border border-outline-variant">
          <span className="material-symbols-outlined text-4xl text-outline mb-2 animate-spin">refresh</span>
          <p className="text-on-surface-variant">Loading found cases...</p>
        </div>
      ) : error ? (
        <div className="bg-error-container rounded-lg p-8 text-center border border-error">
          <span className="material-symbols-outlined text-4xl text-error mb-2">error</span>
          <p className="text-on-error-container">{error}</p>
        </div>
      ) : foundCases.length === 0 ? (
        <div className="bg-surface-container rounded-lg p-8 text-center border border-outline-variant">
          <span className="material-symbols-outlined text-4xl text-outline mb-2">inbox</span>
          <p className="text-on-surface-variant">No found cases recorded yet</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {foundCases.map((foundCase) => (
            <div key={foundCase.id} className="bg-surface border border-success/50 rounded-lg overflow-hidden">
              <div className="h-48 relative overflow-hidden bg-surface-container-lowest">
                <img
                  src={foundCase.imageUrl}
                  alt={foundCase.childName}
                  className="w-full h-full object-cover"
                />
                <div className="absolute top-2 right-2 bg-success text-on-success px-2 py-1 rounded text-xs font-label-caps">
                  FOUND
                </div>
                <div className="absolute bottom-0 left-0 w-full bg-gradient-to-t from-background to-transparent h-24"></div>
              </div>
              <div className="p-4">
                <h3 className="font-headline-md text-headline-md text-on-surface mb-2">{foundCase.childName}</h3>
                <div className="space-y-2 mb-4">
                  <div className="flex justify-between">
                    <span className="font-body-sm text-body-sm text-outline">Age / Gender</span>
                    <span className="font-data-mono text-data-mono text-on-surface">{foundCase.age} / {foundCase.gender}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="font-body-sm text-body-sm text-outline">Last Seen</span>
                    <span className="font-data-mono text-data-mono text-on-surface text-right">{foundCase.lastSeen}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="font-body-sm text-body-sm text-outline">Reporter</span>
                    <span className="font-data-mono text-data-mono text-on-surface text-right">{foundCase.reporterName}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="font-body-sm text-body-sm text-outline">OB Number</span>
                    <span className="font-data-mono text-data-mono text-on-surface text-right">{foundCase.obNumber}</span>
                  </div>
                </div>
                <p className="text-body-sm text-on-surface-variant mb-4 line-clamp-2">
                  {foundCase.description}
                </p>
                <div className="bg-success/10 border border-success/30 rounded p-3">
                  <div className="flex items-center gap-2 text-success text-sm">
                    <span className="material-symbols-outlined text-[16px]">check_circle</span>
                    <span className="font-label-caps text-label-caps">SUCCESSFULLY LOCATED</span>
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

export default FoundPage;
