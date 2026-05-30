import React from 'react';

const DetailModal = ({ isOpen, onClose, caseData }) => {
  if (!isOpen || !caseData) return null;

  return (
    <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-[200] p-4 overflow-y-auto">
      <div className="bg-surface-container rounded-lg border border-outline-variant max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-surface-container p-4 border-b border-outline-variant flex justify-between items-center">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-primary">assignment</span>
            <h3 className="font-headline-md text-headline-md text-on-surface">Case Dossier</h3>
          </div>
          <button onClick={onClose} className="text-outline hover:text-on-surface">
            <span className="material-symbols-outlined">close</span>
          </button>
        </div>
        
        <div className="p-4 space-y-6">
          {/* Header Section */}
          <div className="flex flex-col md:flex-row gap-4">
            <div className="md:w-1/3">
              <div className="bg-surface-container-lowest rounded-lg overflow-hidden border border-outline-variant">
                <img 
                  src={caseData.imageUrl} 
                  alt={caseData.childName}
                  className="w-full h-auto object-cover"
                  onError={(e) => e.target.src = 'https://via.placeholder.com/300x300?text=No+Image'}
                />
              </div>
            </div>
            <div className="md:w-2/3 space-y-3">
              <div>
                <h4 className="font-headline-lg text-headline-lg text-on-surface">{caseData.childName}</h4>
                <div className="flex items-center gap-2 mt-1">
                  <span className="font-data-mono text-data-mono text-primary bg-primary/10 px-2 py-0.5 rounded">
                    {caseData.obNumber}
                  </span>
                  <span className={`px-2 py-0.5 rounded text-xs font-label-caps ${
                    caseData.status === 'Pending' ? 'bg-secondary-container/20 text-secondary-container' :
                    caseData.status === 'Verified' ? 'bg-primary/20 text-primary' :
                    caseData.status === 'Found' ? 'bg-success/20 text-success' :
                    'bg-error/20 text-error'
                  }`}>
                    {caseData.status}
                  </span>
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <p className="text-label-caps text-outline text-xs">AGE</p>
                  <p className="text-body-lg text-on-surface">{caseData.age} years</p>
                </div>
                <div>
                  <p className="text-label-caps text-outline text-xs">GENDER</p>
                  <p className="text-body-lg text-on-surface">{caseData.gender}</p>
                </div>
                <div>
                  <p className="text-label-caps text-outline text-xs">LAST SEEN</p>
                  <p className="text-body-sm text-on-surface">{caseData.lastSeen}</p>
                </div>
                <div>
                  <p className="text-label-caps text-outline text-xs">DATE LAST SEEN</p>
                  <p className="text-body-sm text-on-surface">{caseData.lastSeenDate || 'N/A'}</p>
                </div>
                <div>
                  <p className="text-label-caps text-outline text-xs">REPORTED</p>
                  <p className="text-body-sm text-on-surface">{new Date(caseData.reportedAt).toLocaleDateString()}</p>
                </div>
                <div>
                  <p className="text-label-caps text-outline text-xs">PRIORITY</p>
                  <p className="text-body-sm text-on-surface capitalize">{caseData.priority}</p>
                </div>
              </div>
            </div>
          </div>
          
          {/* Description */}
          <div className="border-t border-outline-variant pt-4">
            <h5 className="font-label-caps text-label-caps text-primary mb-2">DESCRIPTION</h5>
            <p className="text-body-sm text-on-surface-variant">{caseData.description}</p>
          </div>
          
          {/* Reporter Information */}
          <div className="border-t border-outline-variant pt-4">
            <h5 className="font-label-caps text-label-caps text-primary mb-2">REPORTER INFORMATION</h5>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <p className="text-label-caps text-outline text-xs">NAME</p>
                <p className="text-body-sm text-on-surface">{caseData.reporterName}</p>
              </div>
              <div>
                <p className="text-label-caps text-outline text-xs">PHONE</p>
                <p className="text-body-sm text-on-surface">{caseData.reporterPhone}</p>
              </div>
              <div className="col-span-2">
                <p className="text-label-caps text-outline text-xs">RELATIONSHIP</p>
                <p className="text-body-sm text-on-surface">{caseData.reporterRelation}</p>
              </div>
            </div>
          </div>
          
          {/* Sightings */}
          {caseData.sightings && caseData.sightings.length > 0 && (
            <div className="border-t border-outline-variant pt-4">
              <h5 className="font-label-caps text-label-caps text-primary mb-3">SIGHTINGS ({caseData.sightings.length})</h5>
              <div className="space-y-3">
                {caseData.sightings.map((sighting, idx) => (
                  <div key={idx} className="flex items-start gap-3 p-3 bg-surface-container-lowest rounded-lg border border-outline-variant">
                    <span className={`material-symbols-outlined text-sm ${sighting.verified ? 'text-success' : 'text-secondary-container'}`}>
                      {sighting.verified ? 'verified' : 'visibility'}
                    </span>
                    <div className="flex-1">
                      <div className="flex justify-between items-start">
                        <p className="font-data-mono text-data-mono text-sm text-on-surface">{sighting.location}</p>
                        <p className="text-label-caps text-outline text-xs">{new Date(sighting.timestamp).toLocaleString()}</p>
                      </div>
                      <p className="text-body-sm text-outline mt-1">
                        Reported by: {sighting.reporter}
                      </p>
                      {sighting.verified && (
                        <span className="text-xs text-success font-label-caps">VERIFIED</span>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
          
          {/* Verification History / Audit Trail */}
          {caseData.verificationHistory && caseData.verificationHistory.length > 0 && (
            <div className="border-t border-outline-variant pt-4">
              <h5 className="font-label-caps text-label-caps text-primary mb-3">AUDIT TRAIL</h5>
              <div className="space-y-3">
                {caseData.verificationHistory.map((entry, idx) => (
                  <div key={idx} className="flex items-start gap-3 p-3 bg-surface-container-lowest rounded-lg border border-outline-variant">
                    <span className={`material-symbols-outlined text-sm ${
                      entry.action === 'VERIFIED' ? 'text-primary' : 'text-error'
                    }`}>
                      {entry.action === 'VERIFIED' ? 'verified' : 'cancel'}
                    </span>
                    <div className="flex-1">
                      <div className="flex justify-between items-start">
                        <p className="font-data-mono text-data-mono text-sm text-on-surface">{entry.action}</p>
                        <p className="text-label-caps text-outline text-xs">{new Date(entry.timestamp).toLocaleString()}</p>
                      </div>
                      <p className="text-body-sm text-outline mt-1">
                        Officer: {entry.officerBadge}
                      </p>
                      {entry.notes && (
                        <p className="text-body-sm text-on-surface-variant mt-1 text-xs">Note: {entry.notes}</p>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default DetailModal;
