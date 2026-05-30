import React, { useState } from 'react';

const UpdateCaseFiles = ({ caseData, onUpdate, onCancel }) => {
  const [formData, setFormData] = useState({
    status: caseData?.status || 'Pending',
    description: caseData?.description || '',
    lastSeen: caseData?.lastSeen || '',
    notes: ''
  });
  const [newPhoto, setNewPhoto] = useState(null);
  const [newAbstract, setNewAbstract] = useState(null);
  const [errors, setErrors] = useState({});

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handlePhotoChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setNewPhoto(file);
    }
  };

  const handleAbstractChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setNewAbstract(file);
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.status) newErrors.status = 'Status is required';
    if (!formData.description.trim()) newErrors.description = 'Description is required';
    if (!formData.lastSeen.trim()) newErrors.lastSeen = 'Last seen location is required';

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    
    if (validateForm()) {
      const updatedData = {
        ...formData,
        newPhoto,
        newAbstract,
        updatedAt: new Date().toISOString()
      };
      
      onUpdate(updatedData);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-[200] p-4 overflow-y-auto">
      <div className="bg-surface-container rounded-lg border border-outline-variant max-w-3xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-surface-container p-4 border-b border-outline-variant flex justify-between items-center">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-primary">upload_file</span>
            <h3 className="font-headline-md text-headline-md text-on-surface">Update Case Files</h3>
          </div>
          <button onClick={onCancel} className="text-outline hover:text-on-surface">
            <span className="material-symbols-outlined">close</span>
          </button>
        </div>
        
        <form onSubmit={handleSubmit} className="p-6 space-y-6">
          {/* Case Information */}
          <div className="bg-surface-container-lowest p-4 rounded-lg border border-outline-variant">
            <h4 className="font-label-caps text-label-caps text-primary mb-4">CASE INFORMATION</h4>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-label-caps text-outline text-xs">OB NUMBER</p>
                <p className="font-data-mono text-data-mono text-on-surface">{caseData?.obNumber}</p>
              </div>
              <div>
                <p className="text-label-caps text-outline text-xs">CHILD NAME</p>
                <p className="text-body-lg text-on-surface">{caseData?.childName}</p>
              </div>
              <div>
                <p className="text-label-caps text-outline text-xs">CURRENT STATUS</p>
                <span className={`px-2 py-0.5 rounded text-xs font-label-caps ${
                  caseData?.status === 'Pending' ? 'bg-secondary-container/20 text-secondary-container' :
                  caseData?.status === 'Verified' ? 'bg-primary/20 text-primary' :
                  caseData?.status === 'Found' ? 'bg-success/20 text-success' :
                  'bg-error/20 text-error'
                }`}>
                  {caseData?.status}
                </span>
              </div>
              <div>
                <p className="text-label-caps text-outline text-xs">REPORTED DATE</p>
                <p className="text-body-sm text-on-surface">{new Date(caseData?.reportedAt).toLocaleDateString()}</p>
              </div>
            </div>
          </div>
          
          {/* Update Status */}
          <div className="space-y-4">
            <h4 className="font-label-caps text-label-caps text-primary mb-4">UPDATE STATUS</h4>
            
            <div>
              <label className="block font-label-caps text-label-caps text-outline mb-1">
                CASE STATUS *
              </label>
              <select
                name="status"
                value={formData.status}
                onChange={handleInputChange}
                className={`w-full bg-surface-container-lowest border ${errors.status ? 'border-error' : 'border-outline-variant'} rounded p-2 font-body-sm text-body-sm text-on-surface focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary appearance-none`}
              >
                <option value="Pending">Pending</option>
                <option value="Verified">Verified</option>
                <option value="Found">Found</option>
                <option value="Rejected">Rejected</option>
              </select>
              {errors.status && <p className="text-error text-xs mt-1">{errors.status}</p>}
            </div>
          </div>
          
          {/* Update Details */}
          <div className="space-y-4">
            <h4 className="font-label-caps text-label-caps text-primary mb-4">UPDATE DETAILS</h4>
            
            <div>
              <label className="block font-label-caps text-label-caps text-outline mb-1">
                LAST SEEN LOCATION *
              </label>
              <input
                type="text"
                name="lastSeen"
                value={formData.lastSeen}
                onChange={handleInputChange}
                className={`w-full bg-surface-container-lowest border ${errors.lastSeen ? 'border-error' : 'border-outline-variant'} rounded p-2 font-body-sm text-body-sm text-on-surface focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary`}
                placeholder="Update last known location"
              />
              {errors.lastSeen && <p className="text-error text-xs mt-1">{errors.lastSeen}</p>}
            </div>
            
            <div>
              <label className="block font-label-caps text-label-caps text-outline mb-1">
                DESCRIPTION *
              </label>
              <textarea
                name="description"
                value={formData.description}
                onChange={handleInputChange}
                className={`w-full bg-surface-container-lowest border ${errors.description ? 'border-error' : 'border-outline-variant'} rounded p-2 font-body-sm text-body-sm text-on-surface focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary`}
                rows="4"
                placeholder="Update description with new information..."
              />
              {errors.description && <p className="text-error text-xs mt-1">{errors.description}</p>}
            </div>
            
            <div>
              <label className="block font-label-caps text-label-caps text-outline mb-1">
                UPDATE NOTES
              </label>
              <textarea
                name="notes"
                value={formData.notes}
                onChange={handleInputChange}
                className="w-full bg-surface-container-lowest border border-outline-variant rounded p-2 font-body-sm text-body-sm text-on-surface focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary"
                rows="3"
                placeholder="Add any additional notes about this update..."
              />
            </div>
          </div>
          
          {/* Upload New Files */}
          <div className="space-y-4">
            <h4 className="font-label-caps text-label-caps text-primary mb-4">UPLOAD NEW FILES</h4>
            
            <div>
              <label className="block font-label-caps text-label-caps text-outline mb-1">
                NEW CHILD PHOTO (OPTIONAL)
              </label>
              <div className="border-2 border-dashed border-outline-variant rounded-lg p-6 text-center hover:border-primary transition-colors">
                <input
                  type="file"
                  accept="image/*"
                  onChange={handlePhotoChange}
                  className="hidden"
                  id="newPhoto"
                />
                <label htmlFor="newPhoto" className="cursor-pointer">
                  {newPhoto ? (
                    <div className="space-y-2">
                      <img 
                        src={URL.createObjectURL(newPhoto)} 
                        alt="New Photo Preview" 
                        className="max-h-48 mx-auto rounded"
                      />
                      <p className="text-sm text-primary">{newPhoto.name}</p>
                    </div>
                  ) : (
                    <div className="space-y-2">
                      <span className="material-symbols-outlined text-4xl text-outline">add_photo_alternate</span>
                      <p className="text-sm text-on-surface-variant">Click to upload new photo</p>
                      <p className="text-xs text-outline">JPG, PNG (Max 5MB)</p>
                    </div>
                  )}
                </label>
              </div>
            </div>
            
            <div>
              <label className="block font-label-caps text-label-caps text-outline mb-1">
                UPDATED POLICE ABSTRACT (OPTIONAL)
              </label>
              <div className="border-2 border-dashed border-outline-variant rounded-lg p-6 text-center hover:border-primary transition-colors">
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleAbstractChange}
                  className="hidden"
                  id="newAbstract"
                />
                <label htmlFor="newAbstract" className="cursor-pointer">
                  {newAbstract ? (
                    <div className="space-y-2">
                      <img 
                        src={URL.createObjectURL(newAbstract)} 
                        alt="New Abstract Preview" 
                        className="max-h-48 mx-auto rounded"
                      />
                      <p className="text-sm text-primary">{newAbstract.name}</p>
                    </div>
                  ) : (
                    <div className="space-y-2">
                      <span className="material-symbols-outlined text-4xl text-outline">description</span>
                      <p className="text-sm text-on-surface-variant">Click to upload updated abstract</p>
                      <p className="text-xs text-outline">JPG, PNG (Max 5MB)</p>
                    </div>
                  )}
                </label>
              </div>
            </div>
          </div>
          
          {/* Audit Trail Preview */}
          {caseData?.verificationHistory && caseData.verificationHistory.length > 0 && (
            <div className="bg-surface-container-lowest p-4 rounded-lg border border-outline-variant">
              <h4 className="font-label-caps text-label-caps text-outline mb-3">RECENT ACTIVITY</h4>
              <div className="space-y-2 max-h-40 overflow-y-auto">
                {caseData.verificationHistory.slice(-3).reverse().map((entry, idx) => (
                  <div key={idx} className="flex items-start gap-2 p-2 bg-surface-container rounded border border-outline-variant">
                    <span className={`material-symbols-outlined text-sm ${
                      entry.action === 'VERIFIED' ? 'text-primary' : 
                      entry.action === 'REJECTED' ? 'text-error' : 'text-success'
                    }`}>
                      {entry.action === 'VERIFIED' ? 'verified' : 
                       entry.action === 'REJECTED' ? 'cancel' : 'check_circle'}
                    </span>
                    <div className="flex-1">
                      <p className="font-data-mono text-data-mono text-xs text-on-surface">{entry.action}</p>
                      <p className="text-xs text-outline">{new Date(entry.timestamp).toLocaleString()}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
          
          {/* Submit Buttons */}
          <div className="flex gap-3 pt-4 border-t border-outline-variant">
            <button
              type="button"
              onClick={onCancel}
              className="flex-1 border border-outline-variant text-on-surface-variant font-label-caps text-label-caps py-3 rounded hover:bg-surface-variant transition-colors"
            >
              CANCEL
            </button>
            <button
              type="submit"
              className="flex-1 bg-primary text-on-primary font-label-caps text-label-caps py-3 rounded hover:bg-primary-fixed transition-colors flex items-center justify-center gap-2"
            >
              <span className="material-symbols-outlined text-sm">save</span>
              UPDATE CASE
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default UpdateCaseFiles;
