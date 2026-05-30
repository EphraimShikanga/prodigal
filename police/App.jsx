import React, { useState, useEffect } from 'react';
import TopBar from './components/TopBar';
import StatsCards from './components/StatsCards';
import CaseCard from './components/CaseCard';
import VerificationModal from './components/VerificationModal';
import RejectionModal from './components/RejectionModal';
import DetailModal from './components/DetailModal';
import SearchFilters from './components/SearchFilters';
import { mockCases } from './data/mockData';

const App = () => {
  const [cases, setCases] = useState(mockCases);
  const [filteredCases, setFilteredCases] = useState(mockCases);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [regionFilter, setRegionFilter] = useState('all');
  const [selectedCase, setSelectedCase] = useState(null);
  const [showVerifyModal, setShowVerifyModal] = useState(false);
  const [showRejectModal, setShowRejectModal] = useState(false);
  const [showDetailModal, setShowDetailModal] = useState(false);
  const [actionCase, setActionCase] = useState(null);

  // Filter cases based on search, status, and region
  useEffect(() => {
    let filtered = [...cases];
    
    if (searchTerm) {
      filtered = filtered.filter(c => 
        c.obNumber.toLowerCase().includes(searchTerm.toLowerCase()) ||
        c.childName.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
    
    if (statusFilter !== 'all') {
      filtered = filtered.filter(c => c.status.toLowerCase() === statusFilter.toLowerCase());
    }
    
    if (regionFilter !== 'all') {
      filtered = filtered.filter(c => c.region === regionFilter);
    }
    
    setFilteredCases(filtered);
  }, [cases, searchTerm, statusFilter, regionFilter]);

  const handleVerify = (caseData) => {
    setActionCase(caseData);
    setShowVerifyModal(true);
  };

  const handleReject = (caseData) => {
    setActionCase(caseData);
    setShowRejectModal(true);
  };

  const handleViewDetails = (caseData) => {
    setSelectedCase(caseData);
    setShowDetailModal(true);
  };

  const confirmVerification = (officerBadge, notes) => {
    if (!actionCase) return;
    
    const updatedCases = cases.map(c => {
      if (c.id === actionCase.id) {
        const newHistory = [...(c.verificationHistory || []), {
          action: 'VERIFIED',
          officerBadge,
          notes,
          timestamp: new Date().toISOString(),
          status: 'Verified'
        }];
        return {
          ...c,
          status: 'Verified',
          verificationHistory: newHistory,
          verifiedBy: officerBadge,
          verifiedAt: new Date().toISOString()
        };
      }
      return c;
    });
    
    setCases(updatedCases);
    setShowVerifyModal(false);
    setActionCase(null);
  };

  const confirmRejection = (officerBadge, reason) => {
    if (!actionCase) return;
    
    const updatedCases = cases.map(c => {
      if (c.id === actionCase.id) {
        const newHistory = [...(c.verificationHistory || []), {
          action: 'REJECTED',
          officerBadge,
          notes: reason,
          timestamp: new Date().toISOString(),
          status: 'Rejected'
        }];
        return {
          ...c,
          status: 'Rejected',
          verificationHistory: newHistory,
          rejectedBy: officerBadge,
          rejectedAt: new Date().toISOString(),
          rejectionReason: reason
        };
      }
      return c;
    });
    
    setCases(updatedCases);
    setShowRejectModal(false);
    setActionCase(null);
  };

  const getStats = () => ({
    total: cases.length,
    pending: cases.filter(c => c.status === 'Pending').length,
    verified: cases.filter(c => c.status === 'Verified').length,
    recovered: cases.filter(c => c.status === 'Found').length,
    rejected: cases.filter(c => c.status === 'Rejected').length,
    sightings: cases.filter(c => c.sightings && c.sightings.length > 0).length,
    activeAlerts: cases.filter(c => c.status === 'Pending' && c.priority === 'high').length,
    activeCameras: 12,
    uptime: '99.9%'
  });

  const stats = getStats();
  const successRate = stats.total > 0 ? ((stats.verified + stats.recovered) / stats.total * 100).toFixed(1) : 0;
  const [currentTime, setCurrentTime] = useState(new Date());

  useEffect(() => {
    const timer = setInterval(() => setCurrentTime(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  return (
    <div className="flex min-h-screen bg-background">
      <div className="flex-1 pb-20 md:pb-0">
        <TopBar />
        <main className="p-margin-mobile md:p-gutter max-w-7xl mx-auto w-full">
          {/* System Overview Header */}
          <div className="mb-6">
            <h1 className="font-headline-lg text-headline-lg text-on-surface mb-2">Dashboard</h1>
            <p className="font-body-sm text-body-sm text-on-surface-variant mb-4">System Overview and Metrics</p>
            <div className="flex items-center gap-4 font-data-mono text-data-mono text-primary text-sm">
              <span className="material-symbols-outlined text-sm">schedule</span>
              <span>{currentTime.toLocaleString()}</span>
            </div>
          </div>

          {/* Stats Cards */}
          <StatsCards stats={stats} successRate={successRate} />

          {/* System Modules & Latency */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
            <div className="md:col-span-3">
              <h3 className="font-label-caps text-label-caps text-outline mb-4">SYSTEM MODULES</h3>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div className="bg-surface-container rounded-lg border border-outline-variant p-4">
                  <div className="flex items-center justify-between mb-2">
                    <span className="material-symbols-outlined text-primary">videocam</span>
                    <span className="w-2 h-2 bg-success rounded-full animate-pulse"></span>
                  </div>
                  <p className="font-body-sm text-body-sm text-on-surface">Live Camera</p>
                  <p className="text-xs text-success font-label-caps">ONLINE</p>
                </div>
                <div className="bg-surface-container rounded-lg border border-outline-variant p-4">
                  <div className="flex items-center justify-between mb-2">
                    <span className="material-symbols-outlined text-primary">face_retouching_natural</span>
                    <span className="w-2 h-2 bg-success rounded-full animate-pulse"></span>
                  </div>
                  <p className="font-body-sm text-body-sm text-on-surface">AI Aging</p>
                  <p className="text-xs text-success font-label-caps">ONLINE</p>
                </div>
                <div className="bg-surface-container rounded-lg border border-outline-variant p-4">
                  <div className="flex items-center justify-between mb-2">
                    <span className="material-symbols-outlined text-primary">face</span>
                    <span className="w-2 h-2 bg-success rounded-full animate-pulse"></span>
                  </div>
                  <p className="font-body-sm text-body-sm text-on-surface">Face Matcher</p>
                  <p className="text-xs text-success font-label-caps">ONLINE</p>
                </div>
                <div className="bg-surface-container rounded-lg border border-outline-variant p-4">
                  <div className="flex items-center justify-between mb-2">
                    <span className="material-symbols-outlined text-primary">description</span>
                    <span className="w-2 h-2 bg-success rounded-full animate-pulse"></span>
                  </div>
                  <p className="font-body-sm text-body-sm text-on-surface">Case Profiles</p>
                  <p className="text-xs text-success font-label-caps">ONLINE</p>
                </div>
              </div>
            </div>
            <div>
              <h3 className="font-label-caps text-label-caps text-outline mb-4">LATENCY</h3>
              <div className="bg-surface-container rounded-lg border border-outline-variant p-4 h-full flex flex-col justify-center">
                <div className="flex items-center gap-2 mb-2">
                  <span className="material-symbols-outlined text-primary">speed</span>
                  <span className="font-label-caps text-label-caps text-outline text-xs">RECOGNITION</span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="font-data-mono text-data-mono text-2xl text-success">42ms</span>
                  <span className="text-xs text-success font-label-caps">OPTIMAL</span>
                </div>
              </div>
            </div>
          </div>

          {/* Active Amber Alert Section - Show highest priority case */}
          {cases.filter(c => c.status === 'Pending' && c.priority === 'high').length > 0 && (
            <section className="bg-[#121212] border border-[#ffffff1a] rounded relative overflow-hidden flex flex-col md:flex-row shadow-lg mb-6">
              <div className="absolute left-0 top-0 bottom-0 w-1 bg-secondary-container"></div>
              <div className="p-4 flex flex-col gap-2 bg-secondary-container/10 border-b md:border-b-0 md:border-r border-[#ffffff1a] md:w-1/3 z-10 relative">
                <div className="flex items-center gap-2">
                  <span className="font-label-caps text-label-caps text-secondary-container px-2 py-0.5 bg-secondary-container/20 border border-secondary-container/30 rounded inline-flex items-center gap-1">
                    <span className="w-1.5 h-1.5 rounded-full bg-secondary-container animate-pulse"></span>
                    ACTIVE AMBER ALERT
                  </span>
                  <span className="font-data-mono text-data-mono text-outline text-xs">
                    {cases.find(c => c.status === 'Pending' && c.priority === 'high')?.obNumber}
                  </span>
                </div>
                <h2 className="font-headline-lg-mobile md:font-headline-lg text-headline-lg-mobile md:text-headline-lg text-on-surface mt-2">
                  {cases.find(c => c.status === 'Pending' && c.priority === 'high')?.childName}
                </h2>
                <div className="flex gap-4 mt-1 font-data-mono text-data-mono text-on-surface-variant text-sm">
                  <span>Age: {cases.find(c => c.status === 'Pending' && c.priority === 'high')?.age}</span>
                  <span>Gender: {cases.find(c => c.status === 'Pending' && c.priority === 'high')?.gender}</span>
                </div>
                <p className="font-body-sm text-body-sm text-on-surface-variant mt-2 border-t border-[#ffffff1a] pt-2">
                  {cases.find(c => c.status === 'Pending' && c.priority === 'high')?.description?.substring(0, 100)}...
                </p>
              </div>
              <div className="flex-1 flex flex-col md:flex-row">
                <div className="md:w-1/2 p-4 relative group">
                  <div className="aspect-square md:aspect-auto md:h-full bg-surface-container-highest rounded border border-outline-variant overflow-hidden relative">
                    <img 
                      src={cases.find(c => c.status === 'Pending' && c.priority === 'high')?.imageUrl} 
                      alt="Child" 
                      className="w-full h-full object-cover mix-blend-luminosity opacity-80"
                    />
                    <div className="absolute inset-0 bg-primary/10 mix-blend-overlay"></div>
                  </div>
                </div>
                <div className="md:w-1/2 p-4 flex flex-col justify-center gap-4">
                  <div>
                    <div className="font-label-caps text-label-caps text-outline mb-1">LAST KNOWN LOCATION</div>
                    <div className="font-body-lg text-body-lg text-on-surface flex items-center gap-2">
                      <span className="material-symbols-outlined text-secondary-container text-sm">location_on</span>
                      <span>{cases.find(c => c.status === 'Pending' && c.priority === 'high')?.lastSeen}</span>
                    </div>
                  </div>
                  <div>
                    <div className="font-label-caps text-label-caps text-outline mb-1">REPORTED BY</div>
                    <div className="font-body-lg text-body-lg text-on-surface">
                      {cases.find(c => c.status === 'Pending' && c.priority === 'high')?.reporterName}
                    </div>
                  </div>
                  <button 
                    onClick={() => handleVerify(cases.find(c => c.status === 'Pending' && c.priority === 'high'))}
                    className="mt-2 bg-primary text-on-primary-fixed font-label-caps text-label-caps py-2 px-4 rounded hover:bg-primary-fixed transition-colors flex items-center justify-center gap-2 w-full shadow-[0_0_10px_rgba(152,203,255,0.3)]"
                  >
                    <span className="material-symbols-outlined text-sm">verified</span>
                    VERIFY CASE
                  </button>
                </div>
              </div>
            </section>
          )}

          {/* Search and Filters */}
          <SearchFilters 
            searchTerm={searchTerm}
            setSearchTerm={setSearchTerm}
            statusFilter={statusFilter}
            setStatusFilter={setStatusFilter}
            regionFilter={regionFilter}
            setRegionFilter={setRegionFilter}
          />

          {/* Cases Grid */}
          <div className="mt-6">
            <h3 className="font-label-caps text-label-caps text-outline mb-4">ACTIVE CASES</h3>
            {filteredCases.length === 0 ? (
              <div className="bg-surface-container rounded-lg p-8 text-center border border-outline-variant">
                <span className="material-symbols-outlined text-4xl text-outline mb-2">search_off</span>
                <p className="text-on-surface-variant">No cases found matching your criteria.</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {filteredCases.map(caseItem => (
                  <CaseCard
                    key={caseItem.id}
                    caseData={caseItem}
                    onVerify={handleVerify}
                    onReject={handleReject}
                    onViewDetails={handleViewDetails}
                  />
                ))}
              </div>
            )}
          </div>

          {/* Load More Button */}
          <div className="mt-8 flex justify-center pb-8">
            <button className="px-6 py-2 border border-outline-variant text-on-surface-variant font-label-caps text-label-caps rounded hover:bg-surface-variant hover:text-on-surface transition-colors flex items-center gap-2">
              <span className="material-symbols-outlined text-sm">refresh</span>
              LOAD MORE CASES
            </button>
          </div>
        </main>
      </div>

      {/* Modals */}
      <VerificationModal 
        isOpen={showVerifyModal}
        onClose={() => setShowVerifyModal(false)}
        onConfirm={confirmVerification}
        caseData={actionCase}
      />
      <RejectionModal 
        isOpen={showRejectModal}
        onClose={() => setShowRejectModal(false)}
        onConfirm={confirmRejection}
        caseData={actionCase}
      />
      <DetailModal 
        isOpen={showDetailModal}
        onClose={() => setShowDetailModal(false)}
        caseData={selectedCase}
      />
    </div>
  );
};

export default App;