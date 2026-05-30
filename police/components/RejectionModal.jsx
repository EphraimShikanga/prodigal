import React, { useState } from 'react';

const RejectionModal = ({ isOpen, onClose, onConfirm, caseData }) => {
  const [officerBadge, setOfficerBadge] = useState('');
  const [reason, setReason] = useState('');

  if (!isOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    if (officerBadge.trim() && reason.trim()) {
      onConfirm(officerBadge, reason);
      setOfficerBadge('');
      setReason('');
    }
  };

  return (
    <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-[200] p-4">
      <div className="bg-surface-container rounded-lg border border-outline-variant max-w-md w-full">
        <div className="p-4 border-b border-outline-variant flex justify-between items-center">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-error">cancel</span>
            <h3 className="font-headline-md text-headline-md text-on-surface">Reject Case</h3>
          </div>
          <button onClick={onClose} className="text-outline hover:text-on-surface">
            <span className="material-symbols-outlined">close</span>
          </button>
        </div>
        
        <form onSubmit={handleSubmit} className="p-4 space-y-4">
          <div>
            <label className="block font-label-caps text-label-caps text-outline mb-1">
              OB NUMBER
            </label>
            <div className="bg-surface-container-lowest border border-outline-variant rounded p-2 font-data-mono text-data-mono text-on-surface">
              {caseData?.obNumber}
            </div>
          </div>
          
          <div>
            <label className="block font-label-caps text-label-caps text-outline mb-1">
              OFFICER BADGE NUMBER *
            </label>
            <input
              type="text"
              value={officerBadge}
              onChange={(e) => setOfficerBadge(e.target.value)}
              className="w-full bg-surface-container-lowest border border-outline-variant rounded p-2 font-body-sm text-body-sm text-on-surface focus:border-error focus:outline-none focus:ring-1 focus:ring-error"
              placeholder="e.g., BADGE-8472"
              required
            />
          </div>
          
          <div>
            <label className="block font-label-caps text-label-caps text-outline mb-1">
              REJECTION REASON *
            </label>
            <textarea
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              className="w-full bg-surface-container-lowest border border-outline-variant rounded p-2 font-body-sm text-body-sm text-on-surface focus:border-error focus:outline-none focus:ring-1 focus:ring-error"
              rows="3"
              placeholder="Specify reason for rejection..."
              required
            />
          </div>
          
          <div className="flex gap-3 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 border border-outline-variant text-on-surface-variant font-label-caps text-label-caps py-2 rounded hover:bg-surface-variant transition-colors"
            >
              CANCEL
            </button>
            <button
              type="submit"
              className="flex-1 bg-error-container text-on-error-container font-label-caps text-label-caps py-2 rounded hover:bg-error-container/80 transition-colors flex items-center justify-center gap-2"
            >
              <span className="material-symbols-outlined text-sm">cancel</span>
              CONFIRM REJECTION
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default RejectionModal;
