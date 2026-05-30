import React, { useState } from 'react';
import { apiService } from '../services/api';

const PostMissingPage = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);
  const [formData, setFormData] = useState({
    childName: '',
    age: '',
    gender: '',
    description: '',
    photoUrl: '',
    reporterName: '',
    reporterPhone: '',
    reporterEmail: '',
    reporterRelationship: '',
    lastSeenLocation: '',
    lastSeenLat: '',
    lastSeenLng: '',
    lastSeenTime: '',
  });

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setSuccess(false);

    try {
      const alertData = {
        child_name: formData.childName,
        age: parseInt(formData.age),
        gender: formData.gender,
        description: formData.description,
        photo_url: formData.photoUrl,
        reporter_name: formData.reporterName,
        reporter_phone: formData.reporterPhone,
        reporter_email: formData.reporterEmail || undefined,
        reporter_relationship: formData.reporterRelationship,
        last_seen_location: formData.lastSeenLocation,
        last_seen_lat: parseFloat(formData.lastSeenLat),
        last_seen_lng: parseFloat(formData.lastSeenLng),
        last_seen_time: new Date(formData.lastSeenTime).toISOString(),
        source: 'police',
      };

      await apiService.createMobileAlert(alertData);
      setSuccess(true);
      setFormData({
        childName: '',
        age: '',
        gender: '',
        description: '',
        photoUrl: '',
        reporterName: '',
        reporterPhone: '',
        reporterEmail: '',
        reporterRelationship: '',
        lastSeenLocation: '',
        lastSeenLat: '',
        lastSeenLng: '',
        lastSeenTime: '',
      });
    } catch (err) {
      console.error('Failed to post missing person:', err);
      setError('Failed to post missing person. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="font-headline-lg text-headline-lg text-on-surface mb-2">Post Missing Person</h1>
        <p className="font-body-sm text-body-sm text-on-surface-variant">
          Report a missing person to the system
        </p>
      </div>

      {success && (
        <div className="bg-success-container rounded-lg p-4 mb-6 border border-success">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-success">check_circle</span>
            <p className="text-on-success-container">Missing person report submitted successfully!</p>
          </div>
        </div>
      )}

      {error && (
        <div className="bg-error-container rounded-lg p-4 mb-6 border border-error">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-error">error</span>
            <p className="text-on-error-container">{error}</p>
          </div>
        </div>
      )}

      <form onSubmit={handleSubmit} className="max-w-2xl">
        {/* Child Information */}
        <div className="bg-surface-container rounded-lg border border-outline-variant p-6 mb-6">
          <h2 className="font-headline-md text-headline-md text-on-surface mb-4">Child Information</h2>
          <div className="space-y-4">
            <div>
              <label className="block font-label-caps text-label-caps text-outline mb-2">Child Name *</label>
              <input
                type="text"
                name="childName"
                value={formData.childName}
                onChange={handleChange}
                required
                className="w-full px-4 py-2 bg-surface border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block font-label-caps text-label-caps text-outline mb-2">Age *</label>
                <input
                  type="number"
                  name="age"
                  value={formData.age}
                  onChange={handleChange}
                  required
                  min="0"
                  max="18"
                  className="w-full px-4 py-2 bg-surface border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                />
              </div>
              <div>
                <label className="block font-label-caps text-label-caps text-outline mb-2">Gender *</label>
                <select
                  name="gender"
                  value={formData.gender}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-2 bg-surface border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
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
                onChange={handleChange}
                required
                rows="3"
                className="w-full px-4 py-2 bg-surface border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
              />
            </div>
            <div>
              <label className="block font-label-caps text-label-caps text-outline mb-2">Photo URL *</label>
              <input
                type="url"
                name="photoUrl"
                value={formData.photoUrl}
                onChange={handleChange}
                required
                className="w-full px-4 py-2 bg-surface border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
              />
            </div>
          </div>
        </div>

        {/* Reporter Information */}
        <div className="bg-surface-container rounded-lg border border-outline-variant p-6 mb-6">
          <h2 className="font-headline-md text-headline-md text-on-surface mb-4">Reporter Information</h2>
          <div className="space-y-4">
            <div>
              <label className="block font-label-caps text-label-caps text-outline mb-2">Reporter Name *</label>
              <input
                type="text"
                name="reporterName"
                value={formData.reporterName}
                onChange={handleChange}
                required
                className="w-full px-4 py-2 bg-surface border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block font-label-caps text-label-caps text-outline mb-2">Phone Number *</label>
                <input
                  type="tel"
                  name="reporterPhone"
                  value={formData.reporterPhone}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-2 bg-surface border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                />
              </div>
              <div>
                <label className="block font-label-caps text-label-caps text-outline mb-2">Email</label>
                <input
                  type="email"
                  name="reporterEmail"
                  value={formData.reporterEmail}
                  onChange={handleChange}
                  className="w-full px-4 py-2 bg-surface border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                />
              </div>
            </div>
            <div>
              <label className="block font-label-caps text-label-caps text-outline mb-2">Relationship to Child *</label>
              <input
                type="text"
                name="reporterRelationship"
                value={formData.reporterRelationship}
                onChange={handleChange}
                required
                className="w-full px-4 py-2 bg-surface border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
              />
            </div>
          </div>
        </div>

        {/* Last Seen Information */}
        <div className="bg-surface-container rounded-lg border border-outline-variant p-6 mb-6">
          <h2 className="font-headline-md text-headline-md text-on-surface mb-4">Last Seen Information</h2>
          <div className="space-y-4">
            <div>
              <label className="block font-label-caps text-label-caps text-outline mb-2">Last Seen Location *</label>
              <input
                type="text"
                name="lastSeenLocation"
                value={formData.lastSeenLocation}
                onChange={handleChange}
                required
                className="w-full px-4 py-2 bg-surface border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block font-label-caps text-label-caps text-outline mb-2">Latitude *</label>
                <input
                  type="number"
                  name="lastSeenLat"
                  value={formData.lastSeenLat}
                  onChange={handleChange}
                  required
                  step="any"
                  min="-90"
                  max="90"
                  className="w-full px-4 py-2 bg-surface border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                />
              </div>
              <div>
                <label className="block font-label-caps text-label-caps text-outline mb-2">Longitude *</label>
                <input
                  type="number"
                  name="lastSeenLng"
                  value={formData.lastSeenLng}
                  onChange={handleChange}
                  required
                  step="any"
                  min="-180"
                  max="180"
                  className="w-full px-4 py-2 bg-surface border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
                />
              </div>
            </div>
            <div>
              <label className="block font-label-caps text-label-caps text-outline mb-2">Last Seen Time *</label>
              <input
                type="datetime-local"
                name="lastSeenTime"
                value={formData.lastSeenTime}
                onChange={handleChange}
                required
                className="w-full px-4 py-2 bg-surface border border-outline-variant rounded text-on-surface focus:outline-none focus:border-primary"
              />
            </div>
          </div>
        </div>

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-primary text-on-primary font-label-caps text-label-caps px-6 py-3 rounded hover:bg-primary-fixed transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
        >
          {loading ? (
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
  );
};

export default PostMissingPage;
