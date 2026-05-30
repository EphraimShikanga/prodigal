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
  const [sortBy, setSortBy] = useState('reportedDesc');
  const [selectedCase, setSelectedCase] = useState(null);
  const [showVerifyModal, setShowVerifyModal] = useState(false);
  const [showRejectModal, setShowRejectModal] = useState(false);
  const [showDetailModal, setShowDetailModal] = useState(false);
  const [actionCase, setActionCase] = useState(null);
  const [clickPosition, setClickPosition] = useState(null);

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

    // Sort cases based on sortBy
    filtered.sort((a, b) => {
      switch (sortBy) {
        case 'reportedDesc':
          return new Date(b.reportedAt) - new Date(a.reportedAt);
        case 'reportedAsc':
          return new Date(a.reportedAt) - new Date(b.reportedAt);
        case 'lastSeenDesc':
          return new Date(b.lastSeenDate) - new Date(a.lastSeenDate);
        case 'lastSeenAsc':
          return new Date(a.lastSeenDate) - new Date(b.lastSeenDate);
        default:
          return 0;
      }
    });
    
    setFilteredCases(filtered);
  }, [cases, searchTerm, statusFilter, regionFilter, sortBy]);

  const handleVerify = (caseData, event) => {
    setActionCase(caseData);
    if (event) {
      setClickPosition({ x: event.clientX, y: event.clientY });
    }
    setShowVerifyModal(true);
  };

  const handleReject = (caseData, event) => {
    setActionCase(caseData);
    if (event) {
      setClickPosition({ x: event.clientX, y: event.clientY });
    }
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

          {/* Search and Filters */}
          <SearchFilters 
            searchTerm={searchTerm}
            setSearchTerm={setSearchTerm}
            statusFilter={statusFilter}
            setStatusFilter={setStatusFilter}
            regionFilter={regionFilter}
            setRegionFilter={setRegionFilter}
            sortBy={sortBy}
            setSortBy={setSortBy}
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
        onClose={() => {
          setShowVerifyModal(false);
          setClickPosition(null);
        }}
        onConfirm={confirmVerification}
        caseData={actionCase}
        clickPosition={clickPosition}
      />
      <RejectionModal 
        isOpen={showRejectModal}
        onClose={() => {
          setShowRejectModal(false);
          setClickPosition(null);
        }}
        onConfirm={confirmRejection}
        caseData={actionCase}
        clickPosition={clickPosition}
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