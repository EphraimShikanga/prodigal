import React, { useState } from 'react';

const AddCaseForm = ({ onSubmit, onCancel }) => {
  const [formData, setFormData] = useState({
    childName: '',
    age: '',
    gender: '',
    lastSeen: '',
    lastSeenDate: '',
    description: '',
    reporterName: '',
    reporterPhone: '',
    reporterRelation: '',
    obNumber: '',
    priority: 'normal'
  });
  const [childPhoto, setChildPhoto] = useState(null);
  const [abstractImage, setAbstractImage] = useState(null);
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
      setChildPhoto(file);
    }
  };

  const handleAbstractChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setAbstractImage(file);
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.childName.trim()) newErrors.childName = 'Child name is required';
    if (!formData.age) newErrors.age = 'Age is required';
    if (!formData.gender) newErrors.gender = 'Gender is required';
    if (!formData.lastSeen.trim()) newErrors.lastSeen = 'Last seen location is required';
    if (!formData.lastSeenDate) newErrors.lastSeenDate = 'Date is required';
    if (!formData.description.trim()) newErrors.description = 'Description is required';
    if (!formData.reporterName.trim()) newErrors.reporterName = 'Reporter name is required';
    if (!formData.reporterPhone.trim()) newErrors.reporterPhone = 'Phone number is required';
    if (!formData.obNumber.trim()) newErrors.obNumber = 'Police OB Number is required';
    if (!childPhoto) newErrors.childPhoto = 'Child photo is required';
    if (!abstractImage) newErrors.abstractImage = 'Police abstract image is required';

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    
    if (validateForm()) {
      const newCase = {
        ...formData,
        age: parseInt(formData.age),
        childPhoto,
        abstractImage,
        status: 'Pending',
        reportedAt: new Date().toISOString(),
        verificationHistory: []
      };
      
      onSubmit(newCase);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-[200] p-4 overflow-y-auto">
      <div className="bg-surface-container rounded-lg border border-outline-variant max-w-4xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-surface-container p-4 border-b border-outline-variant flex justify-between items-center">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-primary">person_add</span>
            <h3 className="font-headline-md text-headline-md text-on-surface">Report Missing Person</h3>
          </div>
          <button onClick={onCancel} className="text-outline hover:text-on-surface">
            <span className="material-symbols-outlined">close</span>
          </button>
        </div>
        
        <form onSubmit={handleSubmit} className="p-6 space-y-6">
          {/* Child Information */}
          <div className="space-y-4">
            <h4 className="font-label-caps text-label-caps text-primary mb-4">CHILD INFORMATION</h4>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block font-label-caps text-label-caps text-outline mb-1">
                  CHILD NAME *
                </label>
                <input
                  type="text"
                  name="childName"
                  value={formData.childName}
                  onChange={handleInputChange}
                  className={`w-full bg-surface-container-lowest border ${errors.childName ? 'border-error' : 'border-outline-variant'} rounded p-2 font-body-sm text-body-sm text-on-surface focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary`}
                  placeholder="Enter child's full name"
                />
                {errors.childName && <p className="text-error text-xs mt-1">{errors.childName}</p>}
              </div>
              
              <div>
                <label className="block font-label-caps text-label-caps text-outline mb-1">
                  AGE *
                </label>
                <input
                  type="number"
                  name="age"
                  value={formData.age}
                  onChange={handleInputChange}
                  className={`w-full bg-surface-container-lowest border ${errors.age ? 'border-error' : 'border-outline-variant'} rounded p-2 font-body-sm text-body-sm text-on-surface focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary`}
                  placeholder="Enter age"
                  min="0"
                  max="18"
                />
                {errors.age && <p className="text-error text-xs mt-1">{errors.age}</p>}
              </div>
              
              <div>
                <label className="block font-label-caps text-label-caps text-outline mb-1">
                  GENDER *
                </label>
                <select
                  name="gender"
                  value={formData.gender}
                  onChange={handleInputChange}
                  className={`w-full bg-surface-container-lowest border ${errors.gender ? 'border-error' : 'border-outline-variant'} rounded p-2 font-body-sm text-body-sm text-on-surface focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary appearance-none`}
                >
                  <option value="">Select gender</option>
                  <option value="Male">Male</option>
                  <option value="Female">Female</option>
                </select>
                {errors.gender && <p className="text-error text-xs mt-1">{errors.gender}</p>}
              </div>
              
              <div>
                <label className="block font-label-caps text-label-caps text-outline mb-1">
                  PRIORITY
                </label>
                <select
                  name="priority"
                  value={formData.priority}
                  onChange={handleInputChange}
                  className="w-full bg-surface-container-lowest border border-outline-variant rounded p-2 font-body-sm text-body-sm text-on-surface focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary appearance-none"
                >
                  <option value="normal">Normal</option>
                  <option value="high">High Priority (Amber Alert)</option>
                </select>
              </div>
            </div>
            
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
                placeholder="e.g., Nairobi CBD, Westlands Mall"
              />
              {errors.lastSeen && <p className="text-error text-xs mt-1">{errors.lastSeen}</p>}
            </div>
            
            <div>
              <label className="block font-label-caps text-label-caps text-outline mb-1">
                DATE LAST SEEN *
              </label>
              <input
                type="date"
                name="lastSeenDate"
                value={formData.lastSeenDate}
                onChange={handleInputChange}
                className={`w-full bg-surface-container-lowest border ${errors.lastSeenDate ? 'border-error' : 'border-outline-variant'} rounded p-2 font-body-sm text-body-sm text-on-surface focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary`}
              />
              {errors.lastSeenDate && <p className="text-error text-xs mt-1">{errors.lastSeenDate}</p>}
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
                placeholder="Describe clothing, physical features, any distinguishing marks, circumstances of disappearance..."
              />
              {errors.description && <p className="text-error text-xs mt-1">{errors.description}</p>}
            </div>
          </div>
          
          {/* Photo Upload */}
          <div className="space-y-4">
            <h4 className="font-label-caps text-label-caps text-primary mb-4">PHOTO UPLOAD</h4>
            
            <div>
              <label className="block font-label-caps text-label-caps text-outline mb-1">
                CHILD PHOTO *
              </label>
              <div className={`border-2 border-dashed ${errors.childPhoto ? 'border-error' : 'border-outline-variant'} rounded-lg p-6 text-center hover:border-primary transition-colors`}>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handlePhotoChange}
                  className="hidden"
                  id="childPhoto"
                />
                <label htmlFor="childPhoto" className="cursor-pointer">
                  {childPhoto ? (
                    <div className="space-y-2">
                      <img 
                        src={URL.createObjectURL(childPhoto)} 
                        alt="Preview" 
                        className="max-h-48 mx-auto rounded"
                      />
                      <p className="text-sm text-primary">{childPhoto.name}</p>
                    </div>
                  ) : (
                    <div className="space-y-2">
                      <span className="material-symbols-outlined text-4xl text-outline">add_photo_alternate</span>
                      <p className="text-sm text-on-surface-variant">Click to upload child's photo</p>
                      <p className="text-xs text-outline">JPG, PNG (Max 5MB)</p>
                    </div>
                  )}
                </label>
              </div>
              {errors.childPhoto && <p className="text-error text-xs mt-1">{errors.childPhoto}</p>}
            </div>
          </div>
          
          {/* Reporter Information */}
          <div className="space-y-4">
            <h4 className="font-label-caps text-label-caps text-primary mb-4">REPORTER INFORMATION</h4>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block font-label-caps text-label-caps text-outline mb-1">
                  REPORTER NAME *
                </label>
                <input
                  type="text"
                  name="reporterName"
                  value={formData.reporterName}
                  onChange={handleInputChange}
                  className={`w-full bg-surface-container-lowest border ${errors.reporterName ? 'border-error' : 'border-outline-variant'} rounded p-2 font-body-sm text-body-sm text-on-surface focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary`}
                  placeholder="Your full name"
                />
                {errors.reporterName && <p className="text-error text-xs mt-1">{errors.reporterName}</p>}
              </div>
              
              <div>
                <label className="block font-label-caps text-label-caps text-outline mb-1">
                  PHONE NUMBER *
                </label>
                <input
                  type="tel"
                  name="reporterPhone"
                  value={formData.reporterPhone}
                  onChange={handleInputChange}
                  className={`w-full bg-surface-container-lowest border ${errors.reporterPhone ? 'border-error' : 'border-outline-variant'} rounded p-2 font-body-sm text-body-sm text-on-surface focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary`}
                  placeholder="+254 7XX XXX XXX"
                />
                {errors.reporterPhone && <p className="text-error text-xs mt-1">{errors.reporterPhone}</p>}
              </div>
              
              <div className="md:col-span-2">
                <label className="block font-label-caps text-label-caps text-outline mb-1">
                  RELATIONSHIP TO CHILD *
                </label>
                <select
                  name="reporterRelation"
                  value={formData.reporterRelation}
                  onChange={handleInputChange}
                  className={`w-full bg-surface-container-lowest border ${errors.reporterRelation ? 'border-error' : 'border-outline-variant'} rounded p-2 font-body-sm text-body-sm text-on-surface focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary appearance-none`}
                >
                  <option value="">Select relationship</option>
                  <option value="Parent">Parent</option>
                  <option value="Guardian">Guardian</option>
                  <option value="Relative">Relative</option>
                  <option value="Friend">Friend</option>
                  <option value="Other">Other</option>
                </select>
                {errors.reporterRelation && <p className="text-error text-xs mt-1">{errors.reporterRelation}</p>}
              </div>
            </div>
          </div>
          
          {/* Police Verification */}
          <div className="space-y-4 bg-surface-container-lowest p-4 rounded-lg border border-outline-variant">
            <h4 className="font-label-caps text-label-caps text-secondary-container mb-4 flex items-center gap-2">
              <span className="material-symbols-outlined">verified_user</span>
              POLICE VERIFICATION (REQUIRED)
            </h4>
            
            <div>
              <label className="block font-label-caps text-label-caps text-outline mb-1">
                POLICE OB NUMBER *
              </label>
              <input
                type="text"
                name="obNumber"
                value={formData.obNumber}
                onChange={handleInputChange}
                className={`w-full bg-surface-container-lowest border ${errors.obNumber ? 'border-error' : 'border-outline-variant'} rounded p-2 font-data-mono text-data-mono text-on-surface focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary`}
                placeholder="e.g., OB/2026/00123"
              />
              {errors.obNumber && <p className="text-error text-xs mt-1">{errors.obNumber}</p>}
              <p className="text-xs text-outline mt-1">This number is on the police abstract form from your local police station</p>
            </div>
            
            <div>
              <label className="block font-label-caps text-label-caps text-outline mb-1">
                UPLOAD POLICE ABSTRACT IMAGE *
              </label>
              <div className={`border-2 border-dashed ${errors.abstractImage ? 'border-error' : 'border-outline-variant'} rounded-lg p-6 text-center hover:border-primary transition-colors`}>
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleAbstractChange}
                  className="hidden"
                  id="abstractImage"
                />
                <label htmlFor="abstractImage" className="cursor-pointer">
                  {abstractImage ? (
                    <div className="space-y-2">
                      <img 
                        src={URL.createObjectURL(abstractImage)} 
                        alt="Abstract Preview" 
                        className="max-h-48 mx-auto rounded"
                      />
                      <p className="text-sm text-primary">{abstractImage.name}</p>
                    </div>
                  ) : (
                    <div className="space-y-2">
                      <span className="material-symbols-outlined text-4xl text-outline">description</span>
                      <p className="text-sm text-on-surface-variant">Click to upload police abstract</p>
                      <p className="text-xs text-outline">JPG, PNG (Max 5MB)</p>
                    </div>
                  )}
                </label>
              </div>
              {errors.abstractImage && <p className="text-error text-xs mt-1">{errors.abstractImage}</p>}
              <p className="text-xs text-outline mt-1">Upload a clear photo of the police abstract form for verification</p>
            </div>
          </div>
          
          {/* Privacy Notice */}
          <div className="bg-primary/10 border border-primary/30 rounded-lg p-4">
            <div className="flex items-start gap-2">
              <span className="material-symbols-outlined text-primary text-sm">info</span>
              <div>
                <p className="text-sm text-on-surface font-semibold">Privacy & Data Protection</p>
                <p className="text-xs text-on-surface-variant mt-1">
                  By submitting this report, you agree to ARGUS-KE's data protection policies. 
                  All information is encrypted and stored securely in compliance with the Data Protection Act of 2019. 
                  Your information will only be shared with authorized personnel and law enforcement agencies.
                </p>
              </div>
            </div>
          </div>
          
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
              <span className="material-symbols-outlined text-sm">send</span>
              SUBMIT REPORT
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default AddCaseForm;
