/**
 * Mapper to convert backend data structure to frontend format
 */

export const mapBackendCaseToFrontend = (backendCase) => {
  if (!backendCase) return null;

  const { child, reporter, police_abstract, sightings, amber_alerts, ...caseData } = backendCase;

  return {
    id: caseData.id,
    obNumber: police_abstract?.police_ob_number || '',
    childName: child?.name || '',
    age: child?.age || 0,
    gender: child?.gender || '',
    imageUrl: child?.photo_url || '',
    status: mapBackendStatusToFrontend(caseData.status),
    priority: amber_alerts?.length > 0 ? 'high' : 'normal',
    region: extractRegionFromLocation(caseData.last_seen_location) || 'nairobi',
    description: child?.description || '',
    lastSeen: caseData.last_seen_location || '',
    lastSeenDate: caseData.last_seen_time ? new Date(caseData.last_seen_time).toISOString().split('T')[0] : '',
    reporterName: reporter?.name || '',
    reporterPhone: reporter?.phone || '',
    reporterRelation: reporter?.relationship || '',
    reportedAt: caseData.created_at || new Date().toISOString(),
    verificationHistory: mapVerificationHistory(police_abstract, caseData),
    sightings: mapSightings(sightings),
    verifiedBy: police_abstract?.officer_name || '',
    verifiedAt: police_abstract?.stamp_verification_status === 'VERIFIED' ? caseData.updated_at : null,
    stationName: police_abstract?.station_name || '',
  };
};

export const mapBackendStatusToFrontend = (backendStatus) => {
  const statusMap = {
    'PENDING': 'Pending',
    'APPROVED': 'Verified',
    'RESOLVED': 'Found',
    'REJECTED': 'Rejected',
  };
  return statusMap[backendStatus] || backendStatus;
};

export const mapFrontendStatusToBackend = (frontendStatus) => {
  const statusMap = {
    'Pending': 'PENDING',
    'Verified': 'APPROVED',
    'Found': 'RESOLVED',
    'Rejected': 'REJECTED',
  };
  return statusMap[frontendStatus] || frontendStatus.toUpperCase();
};

const extractRegionFromLocation = (location) => {
  if (!location) return 'nairobi';
  const lowerLocation = location.toLowerCase();
  if (lowerLocation.includes('nairobi')) return 'nairobi';
  if (lowerLocation.includes('mombasa')) return 'mombasa';
  if (lowerLocation.includes('kisumu')) return 'kisumu';
  if (lowerLocation.includes('nakuru')) return 'nakuru';
  if (lowerLocation.includes('eldoret')) return 'eldoret';
  return 'nairobi';
};

const mapVerificationHistory = (policeAbstract, caseData) => {
  const history = [];
  
  if (policeAbstract?.stamp_verification_status === 'VERIFIED') {
    history.push({
      action: 'VERIFIED',
      officerBadge: policeAbstract.officer_id || 'UNKNOWN',
      notes: 'Case verified by police officer',
      timestamp: caseData.updated_at || new Date().toISOString(),
      status: 'Verified'
    });
  } else if (policeAbstract?.stamp_verification_status === 'INVALID') {
    history.push({
      action: 'REJECTED',
      officerBadge: policeAbstract.officer_id || 'UNKNOWN',
      notes: 'Case rejected by police officer',
      timestamp: caseData.updated_at || new Date().toISOString(),
      status: 'Rejected'
    });
  }
  
  return history;
};

const mapSightings = (backendSightings) => {
  if (!backendSightings || !Array.isArray(backendSightings)) return [];
  
  return backendSightings.map(sighting => ({
    id: sighting.id,
    location: sighting.location || '',
    timestamp: sighting.created_at || new Date().toISOString(),
    reporter: sighting.reporter_name || 'Anonymous',
    verified: sighting.verified || false
  }));
};

export const mapFrontendCasesArray = (backendCases) => {
  if (!backendCases || !Array.isArray(backendCases)) return [];
  return backendCases.map(mapBackendCaseToFrontend);
};
