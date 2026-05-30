export const mockCases = [
  {
    id: 1,
    obNumber: "OB/2026/00123",
    childName: "Maya Lin",
    age: 8,
    gender: "Female",
    imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuByW4XzhLKhiCXxINmS3GxJU9en2VeRnxC_3Q5Rkrm1GJDCsEfKehGfOMSrc6PeMTQCxrAidE8f5wvh50ht7rLlSE6id8OXSM3i3A-fWkmB5qw3QWh9buQ8G09lqrKqlfRzQzh-Bd2zhG1qYv1x6biR-pq8tzU5TFGmmc1cQTyEcQRNc1R4Sc19npBcKvGKNEb2MIrgGbhWpbAihv4tMm48hPuwg0QYv5g3cvibEPQlwGirFxLera3C0GCTqge7JlQf7eQKid5PR_Mf",
    status: "Pending",
    priority: "high",
    region: "nairobi",
    description: "Wearing a red jacket, blue jeans, and light up sneakers. Known to wander near wooded areas. Last seen near Nairobi National Park Perimeter.",
    lastSeen: "Nairobi National Park Perimeter, Nairobi",
    lastSeenDate: "2026-05-28",
    reporterName: "Sarah Lin",
    reporterPhone: "+254 712 345 678",
    reporterRelation: "Mother",
    reportedAt: "2026-05-28T10:30:00Z",
    verificationHistory: [],
    sightings: [
      {
        id: 1,
        location: "Karen Shopping Mall",
        timestamp: "2026-05-28T14:30:00Z",
        reporter: "Anonymous",
        verified: false
      }
    ]
  },
  {
    id: 2,
    obNumber: "OB/2026/00124",
    childName: "David Chen",
    age: 15,
    gender: "Male",
    imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuBvPuinuWo65wcN5g2DY8MYL8TB8MR0aMilaCpnusmX5VTCXPQwTlPwNhzna7vjMTszbXkq4dWr6_GYiQ9Jyol_iMzLYCvSpa1ymbVtZhx-lXGvmq7zJybJ7PE80wKm7hNYKQeKxnug5CrS6S6XIpnPTayteRBzvnS2jnswH3oMpynk692JZz8zLxjRE2GvxyNSPLHvjkel0MdqGeYxh6Bqa6TBMpTcLSI6wYTNKxYsj1Zd25-jpadG8ntqG5ewU6JCE4X0Rt8TTqfI",
    status: "Verified",
    priority: "normal",
    region: "nairobi",
    description: "Last seen wearing a dark hoodie and black backpack. Was heading towards Central Station.",
    lastSeen: "Central Station, Nairobi",
    lastSeenDate: "2026-05-27",
    reporterName: "Michael Chen",
    reporterPhone: "+254 723 456 789",
    reporterRelation: "Father",
    reportedAt: "2026-05-27T15:20:00Z",
    verificationHistory: [
      {
        action: "VERIFIED",
        officerBadge: "BADGE-001",
        notes: "Information confirmed with reporting station",
        timestamp: "2026-05-28T09:15:00Z",
        status: "Verified"
      }
    ],
    sightings: []
  },
  {
    id: 3,
    obNumber: "OB/2026/00125",
    childName: "Unknown Child",
    age: 5,
    gender: "Female",
    imageUrl: "",
    status: "Pending",
    priority: "normal",
    region: "nairobi",
    description: "Child found wandering alone near Pine Ridge Park. Unable to communicate clearly. Wearing pink dress and white sandals.",
    lastSeen: "Pine Ridge Park, Nairobi",
    lastSeenDate: "2026-05-28",
    reporterName: "Officer Kamau",
    reporterPhone: "+254 701 234 567",
    reporterRelation: "Police Officer",
    reportedAt: "2026-05-28T08:45:00Z",
    verificationHistory: [],
    sightings: []
  },
  {
    id: 4,
    obNumber: "OB/2026/00126",
    childName: "James Otieno",
    age: 12,
    gender: "Male",
    imageUrl: "https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=400&h=300&fit=crop",
    status: "Found",
    priority: "normal",
    region: "nairobi",
    description: "Missing after school. Wearing blue school uniform. Last seen heading home.",
    lastSeen: "Kibera Area, Nairobi",
    lastSeenDate: "2026-05-26",
    reporterName: "Mary Otieno",
    reporterPhone: "+254 734 567 890",
    reporterRelation: "Mother",
    reportedAt: "2026-05-26T18:00:00Z",
    verificationHistory: [
      {
        action: "VERIFIED",
        officerBadge: "BADGE-042",
        notes: "Case verified. Search initiated.",
        timestamp: "2026-05-26T19:30:00Z",
        status: "Verified"
      },
      {
        action: "RECOVERED",
        officerBadge: "BADGE-042",
        notes: "Child found safe with relatives.",
        timestamp: "2026-05-27T22:15:00Z",
        status: "Found"
      }
    ],
    sightings: [
      {
        id: 1,
        location: "Dagoretti Market",
        timestamp: "2026-05-27T10:00:00Z",
        reporter: "Community Member",
        verified: true
      }
    ]
  },
  {
    id: 5,
    obNumber: "OB/2026/00127",
    childName: "Aisha Abdullahi",
    age: 3,
    gender: "Female",
    imageUrl: "https://images.unsplash.com/photo-1516627145497-ae6968895b74?w=400&h=300&fit=crop",
    status: "Pending",
    priority: "high",
    region: "nairobi",
    description: "Toddler wandered from home. Wearing yellow dress and black shoes. Has a small birthmark on left cheek.",
    lastSeen: "Eastleigh, Nairobi",
    lastSeenDate: "2026-05-28",
    reporterName: "Fatima Abdullahi",
    reporterPhone: "+254 745 678 901",
    reporterRelation: "Mother",
    reportedAt: "2026-05-28T12:15:00Z",
    verificationHistory: [],
    sightings: [
      {
        id: 1,
        location: "Pangani area",
        timestamp: "2026-05-28T16:00:00Z",
        reporter: "Anonymous",
        verified: false
      },
      {
        id: 2,
        location: "Eastleigh Shopping Centre",
        timestamp: "2026-05-28T18:30:00Z",
        reporter: "Shopkeeper",
        verified: false
      }
    ]
  },
  {
    id: 6,
    obNumber: "OB/2026/00128",
    childName: "Samuel Mwangi",
    age: 16,
    gender: "Male",
    imageUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=300&fit=crop",
    status: "Rejected",
    priority: "normal",
    region: "nairobi",
    description: "Teenager left home after argument. Last seen wearing black jeans and red hoodie.",
    lastSeen: "Thika Road, Nairobi",
    lastSeenDate: "2026-05-25",
    reporterName: "Grace Mwangi",
    reporterPhone: "+254 756 789 012",
    reporterRelation: "Mother",
    reportedAt: "2026-05-25T14:30:00Z",
    verificationHistory: [
      {
        action: "REJECTED",
        officerBadge: "BADGE-089",
        notes: "Insufficient information provided. Reporter contacted but no additional details.",
        timestamp: "2026-05-26T10:00:00Z",
        status: "Rejected"
      }
    ],
    sightings: []
  },
  {
    id: 7,
    obNumber: "OB/2026/00129",
    childName: "Grace Wanjiku",
    age: 7,
    gender: "Female",
    imageUrl: "https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?w=400&h=300&fit=crop",
    status: "Verified",
    priority: "normal",
    region: "nakuru",
    description: "Missing from school playground. Wearing green uniform with white socks. Has a small scar on forehead.",
    lastSeen: "Westlands Primary School",
    lastSeenDate: "2026-05-29",
    reporterName: "John Wanjiku",
    reporterPhone: "+254 711 234 567",
    reporterRelation: "Father",
    reportedAt: "2026-05-29T08:00:00Z",
    verificationHistory: [
      {
        action: "VERIFIED",
        officerBadge: "BADGE-156",
        notes: "School confirmed child missing. Parents verified.",
        timestamp: "2026-05-29T10:30:00Z",
        status: "Verified"
      }
    ],
    sightings: []
  },
  {
    id: 8,
    obNumber: "OB/2026/00130",
    childName: "Brian Omondi",
    age: 11,
    gender: "Male",
    imageUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop",
    status: "Pending",
    priority: "high",
    region: "kisumu",
    description: "Last seen playing football near estate gate. Wearing red jersey and black shorts. Very friendly child.",
    lastSeen: "Kawangware Estate, Nairobi",
    lastSeenDate: "2026-05-29",
    reporterName: "Mercy Omondi",
    reporterPhone: "+254 722 345 678",
    reporterRelation: "Mother",
    reportedAt: "2026-05-29T17:00:00Z",
    verificationHistory: [],
    sightings: [
      {
        id: 1,
        location: "Dagoretti Corner",
        timestamp: "2026-05-29T18:15:00Z",
        reporter: "Matatu driver",
        verified: false
      }
    ]
  },
  {
    id: 9,
    obNumber: "OB/2026/00131",
    childName: "Fatuma Hassan",
    age: 9,
    gender: "Female",
    imageUrl: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=300&fit=crop",
    status: "Pending",
    priority: "high",
    region: "mombasa",
    description: "Last seen near Old Town area. Wearing blue hijab and white dress. Speaks Swahili and Arabic.",
    lastSeen: "Old Town, Mombasa",
    lastSeenDate: "2026-05-29",
    reporterName: "Hassan Ali",
    reporterPhone: "+254 733 456 789",
    reporterRelation: "Father",
    reportedAt: "2026-05-29T14:00:00Z",
    verificationHistory: [],
    sightings: []
  },
  {
    id: 10,
    obNumber: "OB/2026/00132",
    childName: "Peter Kipkorir",
    age: 14,
    gender: "Male",
    imageUrl: "https://images.unsplash.com/photo-1504257432389-52343af06ae3?w=400&h=300&fit=crop",
    status: "Verified",
    priority: "normal",
    region: "eldoret",
    description: "Missing after basketball practice. Wearing red jersey and black shorts. Athletic build.",
    lastSeen: "Eldoret Sports Club",
    lastSeenDate: "2026-05-28",
    reporterName: "David Kipkorir",
    reporterPhone: "+254 744 567 890",
    reporterRelation: "Father",
    reportedAt: "2026-05-28T16:30:00Z",
    verificationHistory: [
      {
        action: "VERIFIED",
        officerBadge: "BADGE-203",
        notes: "Coach confirmed child missing from practice.",
        timestamp: "2026-05-28T18:00:00Z",
        status: "Verified"
      }
    ],
    sightings: []
  }
];
