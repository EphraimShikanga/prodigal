import React, { useState } from 'react';

const CaseCard = ({ caseData, onVerify, onReject, onViewDetails }) => {
  const [imageError, setImageError] = useState(false);
  const [showImagePreview, setShowImagePreview] = useState(false);

  const getStatusColor = () => {
    switch (caseData.status) {
      case 'Pending': return 'text-secondary-container bg-secondary-container/10 border-secondary-container/30';
      case 'Verified': return 'text-primary bg-primary/10 border-primary/30';
      case 'Found': return 'text-success bg-success/10 border-success/30';
      case 'Rejected': return 'text-error bg-error/10 border-error/30';
      default: return 'text-outline bg-surface-variant border-outline-variant';
    }
  };

  const getPriorityBadge = () => {
    if (caseData.priority === 'high') {
      return (
        <span className="bg-error/20 text-error border border-error/30 font-label-caps text-[10px] px-2 py-1 rounded-sm flex items-center gap-1 backdrop-blur-sm">
          <span className="material-symbols-outlined text-[12px]">warning</span>
          URGENT
        </span>
      );
    }
    return null;
  };

  return (
    <>
      <article className="bg-surface border border-outline-variant rounded-lg overflow-hidden flex flex-col relative group hover:border-primary/50 transition-all duration-300">
        {caseData.priority === 'high' && (
          <div className="absolute top-2 right-2 z-10 flex gap-2">
            {getPriorityBadge()}
          </div>
        )}
        
        <div className="h-48 relative overflow-hidden bg-surface-container-lowest cursor-pointer" onClick={() => setShowImagePreview(true)}>
          <img 
            src={imageError ? 'https://via.placeholder.com/400x300?text=No+Image' : caseData.imageUrl} 
            alt={caseData.childName}
            className="w-full h-full object-cover opacity-80 group-hover:opacity-100 transition-opacity duration-300"
            onError={() => setImageError(true)}
          />
          <div className="absolute bottom-0 left-0 w-full bg-gradient-to-t from-background to-transparent h-24"></div>
          <div className="absolute inset-0 bg-primary/0 group-hover:bg-primary/5 transition-all duration-300"></div>
        </div>
        
        <div className="p-4 flex-1 flex flex-col">
          <div className="flex justify-between items-start mb-2">
            <h3 className="font-headline-md text-headline-md text-on-surface">{caseData.childName}</h3>
            <span className="font-data-mono text-data-mono text-primary bg-primary/10 px-2 py-0.5 rounded border border-primary/20">
              {caseData.obNumber}
            </span>
          </div>
          
          <div className="flex items-center gap-1 mb-3">
            <span className={`material-symbols-outlined text-[16px] ${caseData.status === 'Verified' ? 'text-primary' : 'text-outline'}`}>
              {caseData.status === 'Verified' ? 'verified_user' : 'pending'}
            </span>
            <span className={`text-body-sm px-2 py-0.5 rounded text-xs ${getStatusColor()}`}>
              {caseData.status}
            </span>
          </div>
          
          <p className="text-body-sm text-on-surface-variant mb-3 line-clamp-2">
            {caseData.description}
          </p>
          
          <div className="space-y-2 mt-auto">
            <div className="flex justify-between border-b border-outline-variant pb-1">
              <span className="font-body-sm text-body-sm text-outline">Age / Gender</span>
              <span className="font-data-mono text-data-mono text-on-surface">{caseData.age} / {caseData.gender}</span>
            </div>
            <div className="flex justify-between border-b border-outline-variant pb-1">
              <span className="font-body-sm text-body-sm text-outline">Last Seen</span>
              <span className="font-data-mono text-data-mono text-on-surface">{caseData.lastSeen}</span>
            </div>
            <div className="flex justify-between border-b border-outline-variant pb-1">
              <span className="font-body-sm text-body-sm text-outline">Sightings</span>
              <span className="font-data-mono text-data-mono text-on-surface">{caseData.sightings?.length || 0}</span>
            </div>
            <div className="flex justify-between pt-1">
              <span className="font-body-sm text-body-sm text-outline">Reporter</span>
              <span className="font-data-mono text-data-mono text-on-surface text-right">{caseData.reporterName}</span>
            </div>
          </div>
        </div>
        
        <div className="p-3 bg-surface-container-low border-t border-outline-variant flex justify-between items-center gap-2">
          <button 
            onClick={() => onViewDetails(caseData)}
            className="font-label-caps text-label-caps text-primary hover:text-primary-fixed transition-colors flex items-center gap-1"
          >
            VIEW DOSSIER <span className="material-symbols-outlined text-[14px]">arrow_forward</span>
          </button>
          
          {caseData.status === 'Pending' && (
            <div className="flex gap-2">
              <button 
                onClick={() => onVerify(caseData)}
                className="bg-primary/20 text-primary font-label-caps text-label-caps px-3 py-1 rounded hover:bg-primary/30 transition-colors flex items-center gap-1 text-xs"
              >
                <span className="material-symbols-outlined text-[14px]">check</span>
                VERIFY
              </button>
              <button 
                onClick={() => onReject(caseData)}
                className="bg-error/20 text-error font-label-caps text-label-caps px-3 py-1 rounded hover:bg-error/30 transition-colors flex items-center gap-1 text-xs"
              >
                <span className="material-symbols-outlined text-[14px]">close</span>
                REJECT
              </button>
            </div>
          )}
        </div>
      </article>

      {/* Image Lightbox */}
      {showImagePreview && (
        <div className="fixed inset-0 bg-black/90 z-[100] flex items-center justify-center p-4" onClick={() => setShowImagePreview(false)}>
          <div className="relative max-w-4xl max-h-[90vh]" onClick={(e) => e.stopPropagation()}>
            <img 
              src={imageError ? 'https://via.placeholder.com/800x600?text=No+Image' : caseData.imageUrl} 
              alt={caseData.childName}
              className="max-w-full max-h-[90vh] object-contain rounded-lg"
            />
            <button 
              onClick={() => setShowImagePreview(false)}
              className="absolute top-2 right-2 bg-black/50 text-white rounded-full p-2 hover:bg-black/70 transition-colors"
            >
              <span className="material-symbols-outlined">close</span>
            </button>
          </div>
        </div>
      )}
    </>
  );
};

export default CaseCard;
