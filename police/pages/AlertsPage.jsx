import React, { useState, useEffect } from 'react';
import { apiService } from '../services/api';
import { mapFrontendCasesArray } from '../services/dataMapper';

const AlertsPage = () => {
  const [alerts, setAlerts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showPostModal, setShowPostModal] = useState(false);
  const [postLoading, setPostLoading] = useState(false);
  const [postSuccess, setPostSuccess] = useState(false);
  const [postError, setPostError] = useState(null);
  const [formData, setFormData] = useState({
    childName: '',
    age: '',
    gender: '',
    description: '',
    photoUrl: '',
    photoFile: null,
    obNumber: '',
    reporterName: '',
    reporterPhone: '',
    reporterEmail: '',
    reporterRelationship: '',
    lastSeenLocation: '',
    lastSeenTime: '',
  });

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
      const pendingAlerts = await apiService.getPendingAlerts();
      const frontendAlerts = mapFrontendCasesArray(pendingAlerts);
      setAlerts(frontendAlerts);
    } catch (err) {
      console.error('Failed to reject alert:', err);
      alert('Failed to reject alert. Please try again.');
    }
  };

  const handlePostSubmit = async (e) => {
    e.preventDefault();
    setPostLoading(true);
    setPostError(null);
    setPostSuccess(false);

    try {
      const alertData = {
        child_name: formData.childName,
        age: parseInt(formData.age),
        gender: formData.gender,
        description: formData.description,
        photo_url: formData.photoUrl || undefined,
        reporter_name: formData.reporterName || 'Unknown',
        reporter_phone: formData.reporterPhone || '0000000000',
        reporter_email: formData.reporterEmail || undefined,
        reporter_relationship: formData.reporterRelationship || 'Unknown',
        last_seen_location: formData.lastSeenLocation,
        last_seen_lat: -1.286389, // Default Nairobi coordinates
        last_seen_lng: 36.817223,
        last_seen_time: new Date(formData.lastSeenTime).toISOString(),
        source: 'police',
      };

      await apiService.createMobileAlert(alertData, formData.photoFile);
      setPostSuccess(true);
      setFormData({
        childName: '',
        age: '',
        gender: '',
        description: '',
        photoUrl: '',
        photoFile: null,
        obNumber: '',
        reporterName: '',
        reporterPhone: '',
        reporterEmail: '',
        reporterRelationship: '',
        lastSeenLocation: '',
        lastSeenTime: '',
      });
      setTimeout(() => {
        setShowPostModal(false);
        setPostSuccess(false);
      }, 2000);
    } catch (err) {
      console.error('Failed to post missing person:', err);
      setPostError('Failed to post missing person. Please try again.');
    } finally {
      setPostLoading(false);
    }
  };

  const handlePostChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setFormData({
        ...formData,
        photoFile: file,
        photoUrl: '', // Clear URL when file is selected
      });
    }
  };

  return (
    <div className="p-6">
      <div className="mb-6 flex flex-col items-center gap-4">
        <div className="text-center">
          <h1 className="font-headline-lg text-headline-lg text-on-surface mb-2">Alerts - Pending Verification</h1>
          <p className="font-body-sm text-body-sm text-on-surface-variant">
            Review and verify missing person reports
          </p>
        </div>
        <button
          onClick={() => setShowPostModal(true)}
          className="bg-primary text-on-primary font-label-caps text-label-caps px-4 py-2 rounded hover:bg-primary-fixed transition-colors flex items-center gap-2"
        >
          <span className="material-symbols-outlined">add</span>
          Post Missing Person
        </button>
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
          <p className="text-on-surface-variant">No pending reports to verify</p>
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
                  PENDING
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

      {/* Post Missing Person Modal */}
      {showPostModal && (
        <div className="fixed inset-0 bg-black/50 z-[100] flex items-center justify-center p-4" onClick={() => setShowPostModal(false)}>
          <div className="bg-surface-container border border-outline-variant rounded-lg shadow-xl w-full max-w-2xl max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="flex justify-between items-center p-4 border-b border-outline-variant">
              <span className="font-label-caps text-label-caps text-on-surface">POST MISSING PERSON</span>
              <button onClick={() => setShowPostModal(false)} className="text-on-surface-variant hover:text-on-surface">
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>

            {postSuccess && (
              <div className="bg-success-container rounded-lg p-4 m-4 border border-success">
                <div className="flex items-center gap-2">
                  <span className="material-symbols-outlined text-success">check_circle</span>
                  <p className="text-on-success-container">Missing person report submitted successfully!</p>
                </div>
              </div>
            )}

            {postError && (
              <div className="bg-error-container rounded-lg p-4 m-4 border border-error">
                <div className="flex items-center gap-2">
                  <span className="material-symbols-outlined text-error">error</span>
                  <p className="text-on-error-container">{postError}</p>
                </div>
              </div>
            )}

            <form onSubmit={handlePostSubmit} className="p-4 space-y-6">
              {/* Child Information */}
              <div>
                <h3 className="font-headline-md text-headline-md text-on-surface mb-4">Child Information</h3>
                <div className="space-y-4">
                  <div>
                    <label className="block font-label-caps text-label-caps text-outline mb-2">Child Name *</label>
                    <input
                      type="text"
                      name="childName"
                      value={formData.childName}
                      onChange={handlePostChange}
                      required
                      className="w-full px-4 py-2 bg-surface-container border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                    />
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block font-label-caps text-label-caps text-outline mb-2">Age *</label>
                      <input
                        type="number"
                        name="age"
                        value={formData.age}
                        onChange={handlePostChange}
                        required
                        min="0"
                        max="18"
                        className="w-full px-4 py-2 bg-surface-container border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                      />
                    </div>
                    <div>
                      <label className="block font-label-caps text-label-caps text-outline mb-2">Gender *</label>
                      <select
                        name="gender"
                        value={formData.gender}
                        onChange={handlePostChange}
                        required
                        className="w-full px-4 py-2 bg-surface-container border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                      >
                        <option value="">Select Gender</option>
                        <option value="Male">Male</option>
                        <option value="Female">Female</option>
                      </select>
                    </div>
                  </div>
                  <div>
                    <label className="block font-label-caps text-label-caps text-outline mb-2">Description *</label>
                    <textarea
                      name="description"
                      value={formData.description}
                      onChange={handlePostChange}
                      required
                      rows="3"
                      className="w-full px-4 py-2 bg-surface-container border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                    />
                  </div>
                  <div>
                    <label className="block font-label-caps text-label-caps text-outline mb-2">Photo (Upload or URL)</label>
                    <div className="space-y-3">
                      <div>
                        <label className="block font-body-sm text-body-sm text-outline mb-1">Upload Image</label>
                        <input
                          type="file"
                          name="photoFile"
                          onChange={handleFileChange}
                          accept="image/jpeg,image/jpg,image/png,image/webp"
                          className="w-full px-4 py-2 bg-surface-container border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                        />
                      </div>
                      <div className="text-center font-body-sm text-body-sm text-on-surface-variant">or</div>
                      <div>
                        <label className="block font-body-sm text-body-sm text-outline mb-1">Image URL</label>
                        <input
                          type="url"
                          name="photoUrl"
                          value={formData.photoUrl}
                          onChange={handlePostChange}
                          placeholder="https://example.com/photo.jpg"
                          disabled={formData.photoFile !== null}
                          className="w-full px-4 py-2 bg-surface-container border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary disabled:opacity-50 disabled:cursor-not-allowed"
                        />
                      </div>
                    </div>
                  </div>
                  <div>
                    <label className="block font-label-caps text-label-caps text-outline mb-2">OB Number</label>
                    <input
                      type="text"
                      name="obNumber"
                      value={formData.obNumber}
                      onChange={handlePostChange}
                      className="w-full px-4 py-2 bg-surface-container border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                    />
                  </div>
                </div>
              </div>

              {/* Reporter Information */}
              <div>
                <h3 className="font-headline-md text-headline-md text-on-surface mb-4">Reporter Information (Optional)</h3>
                <div className="space-y-4">
                  <div>
                    <label className="block font-label-caps text-label-caps text-outline mb-2">Reporter Name</label>
                    <input
                      type="text"
                      name="reporterName"
                      value={formData.reporterName}
                      onChange={handlePostChange}
                      className="w-full px-4 py-2 bg-surface-container border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                    />
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block font-label-caps text-label-caps text-outline mb-2">Phone Number</label>
                      <input
                        type="tel"
                        name="reporterPhone"
                        value={formData.reporterPhone}
                        onChange={handlePostChange}
                        className="w-full px-4 py-2 bg-surface-container border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                      />
                    </div>
                    <div>
                      <label className="block font-label-caps text-label-caps text-outline mb-2">Email</label>
                      <input
                        type="email"
                        name="reporterEmail"
                        value={formData.reporterEmail}
                        onChange={handlePostChange}
                        className="w-full px-4 py-2 bg-surface-container border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                      />
                    </div>
                  </div>
                  <div>
                    <label className="block font-label-caps text-label-caps text-outline mb-2">Relationship to Child</label>
                    <input
                      type="text"
                      name="reporterRelationship"
                      value={formData.reporterRelationship}
                      onChange={handlePostChange}
                      className="w-full px-4 py-2 bg-surface-container border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                    />
                  </div>
                </div>
              </div>

              {/* Last Seen Information */}
              <div>
                <h3 className="font-headline-md text-headline-md text-on-surface mb-4">Last Seen Information</h3>
                <div className="space-y-4">
                  <div>
                    <label className="block font-label-caps text-label-caps text-outline mb-2">Last Seen Location *</label>
                    <input
                      type="text"
                      name="lastSeenLocation"
                      value={formData.lastSeenLocation}
                      onChange={handlePostChange}
                      required
                      className="w-full px-4 py-2 bg-surface-container border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                    />
                  </div>
                  <div>
                    <label className="block font-label-caps text-label-caps text-outline mb-2">Last Seen Time *</label>
                    <input
                      type="datetime-local"
                      name="lastSeenTime"
                      value={formData.lastSeenTime}
                      onChange={handlePostChange}
                      required
                      className="w-full px-4 py-2 bg-surface-container border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                    />
                  </div>
                </div>
              </div>

              <button
                type="submit"
                disabled={postLoading}
                className="w-full bg-primary text-on-primary font-label-caps text-label-caps px-6 py-3 rounded hover:bg-primary-fixed transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                {postLoading ? (
                  <>
                    <span className="material-symbols-outlined animate-spin">refresh</span>
                    Submitting...
                  </>
                ) : (
                  <>
                    <span className="material-symbols-outlined">send</span>
                    Submit Report
                  </>
                )}
              </button>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default AlertsPage;
