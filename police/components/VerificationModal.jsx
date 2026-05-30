import React, { useState } from 'react';

const VerificationModal = ({ isOpen, onClose, onConfirm, caseData }) => {
  const [officerBadge, setOfficerBadge] = useState('');
  const [notes, setNotes] = useState('');

  if (!isOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    if (officerBadge.trim()) {
      onConfirm(officerBadge, notes);
      setOfficerBadge('');
      setNotes('');
    }
  };

  return (
    <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-[200] p-4">
      <div className="bg-surface-container rounded-lg border border-outline-variant max-w-md w-full">
        <div className="p-4 border-b border-outline-variant flex justify-between items-center">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-primary">verified</span>
            <h3 className="font-headline-md text-headline-md text-on-surface">Verify Case</h3>
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
              className="w-full bg-surface-container-lowest border border-outline-variant rounded p-2 font-body-sm text-body-sm text-on-surface focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary"
              placeholder="e.g., BADGE-8472"
              required
            />
          </div>
          
          <div>
            <label className="block font-label-caps text-label-caps text-outline mb-1">
              VERIFICATION NOTES
            </label>
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              className="w-full bg-surface-container-lowest border border-outline-variant rounded p-2 font-body-sm text-body-sm text-on-surface focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary"
              rows="3"
              placeholder="Additional verification notes..."
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
              className="flex-1 bg-primary text-on-primary font-label-caps text-label-caps py-2 rounded hover:bg-primary-fixed transition-colors flex items-center justify-center gap-2"
            >
              <span className="material-symbols-outlined text-sm">verified</span>
              CONFIRM VERIFICATION
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default VerificationModal;
