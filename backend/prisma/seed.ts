import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed...');

  // Clean existing data
  await prisma.amberAlert.deleteMany();
  await prisma.sighting.deleteMany();
  await prisma.case.deleteMany();
  await prisma.policeAbstract.deleteMany();
  await prisma.reporter.deleteMany();
  await prisma.child.deleteMany();

  console.log('✅ Cleaned existing data');

  // Create sample Kenyan cases
  const sampleCases = [
    // PENDING CASE 1
    {
      child: {
        name: 'Maya Wanjiku',
        age: 8,
        gender: 'Female',
        description: 'Wearing a red jacket, blue jeans, and light up sneakers. Known to wander near wooded areas.',
        photo_url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuByW4XzhLKhiCXxINmS3GxJU9en2VeRnxC_3Q5Rkrm1GJDCsEfKehGfOMSrc6PeMTQCxrAidE8f5wvh50ht7rLlSE6id8OXSM3i3A-fWkmB5qw3QWh9buQ8G09lqrKqlfRzQzh-Bd2zhG1qYv1x6biR-pq8tzU5TFGmmc1cQTyEcQRNc1R4Sc19npBcKvGKNEb2MIrgGbhWpbAihv4tMm48hPuwg0QYv5g3cvibEPQlwGirFxLera3C0GCTqge7JlQf7eQKid5PR_Mf',
      },
      reporter: {
        name: 'Sarah Wanjiku',
        phone: '+254 712 345 678',
        email: 'sarah.wanjiku@email.com',
        relationship: 'Mother',
      },
      police: {
        police_ob_number: 'OB/2026/00123',
        station_name: 'Nairobi Central Police Station',
        officer_id: 'BADGE-001',
        officer_name: 'Officer Kamau',
        abstract_image_url: 'https://example.com/abstract1.jpg',
      },
      case: {
        last_seen_location: 'Nairobi National Park Perimeter, Nairobi',
        last_seen_lat: -1.3614,
        last_seen_lng: 36.8449,
        last_seen_time: '2026-05-28T10:30:00Z',
        status: 'PENDING',
      },
    },
    // PENDING CASE 2
    {
      child: {
        name: 'Aisha Abdullahi',
        age: 3,
        gender: 'Female',
        description: 'Toddler wandered from home. Wearing yellow dress and black shoes. Has a small birthmark on left cheek.',
        photo_url: 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?w=400&h=300&fit=crop',
      },
      reporter: {
        name: 'Fatima Abdullahi',
        phone: '+254 745 678 901',
        email: 'fatima.abdullahi@email.com',
        relationship: 'Mother',
      },
      police: {
        police_ob_number: 'OB/2026/00127',
        station_name: 'Eastleigh Police Station',
        officer_id: 'BADGE-002',
        officer_name: 'Officer Ochieng',
        abstract_image_url: 'https://example.com/abstract2.jpg',
      },
      case: {
        last_seen_location: 'Eastleigh, Nairobi',
        last_seen_lat: -1.2624,
        last_seen_lng: 36.8569,
        last_seen_time: '2026-05-28T12:15:00Z',
        status: 'PENDING',
      },
    },
    // VERIFIED CASE 1
    {
      child: {
        name: 'David Chen',
        age: 15,
        gender: 'Male',
        description: 'Last seen wearing a dark hoodie and black backpack. Was heading towards Central Station.',
        photo_url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBvPuinuWo65wcN5g2DY8MYL8TB8MR0aMilaCpnusmX5VTCXPQwTlPwNhzna7vjMTszbXkq4dWr6_GYiQ9Jyol_iMzLYCvSpa1ymbVtZhx-lXGvmq7zJybJ7PE80wKm7hNYKQeKxnug5CrS6S6XIpnPTayteRBzvnS2jnswH3oMpynk692JZz8zLxjRE2GvxyNSPLHvjkel0MdqGeYxh6Bqa6TBMpTcLSI6wYTNKxYsj1Zd25-jpadG8ntqG5ewU6JCE4X0Rt8TTqfI',
      },
      reporter: {
        name: 'Michael Chen',
        phone: '+254 723 456 789',
        email: 'michael.chen@email.com',
        relationship: 'Father',
      },
      police: {
        police_ob_number: 'OB/2026/00124',
        station_name: 'Nairobi Central Police Station',
        officer_id: 'BADGE-003',
        officer_name: 'Officer Njoroge',
        abstract_image_url: 'https://example.com/abstract3.jpg',
      },
      case: {
        last_seen_location: 'Central Station, Nairobi',
        last_seen_lat: -1.2864,
        last_seen_lng: 36.8219,
        last_seen_time: '2026-05-27T15:20:00Z',
        status: 'APPROVED',
      },
    },
    // VERIFIED CASE 2
    {
      child: {
        name: 'Grace Wanjiku',
        age: 7,
        gender: 'Female',
        description: 'Missing from school playground. Wearing green uniform with white socks. Has a small scar on forehead.',
        photo_url: 'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb?w=400&h=300&fit=crop',
      },
      reporter: {
        name: 'John Wanjiku',
        phone: '+254 711 234 567',
        email: 'john.wanjiku@email.com',
        relationship: 'Father',
      },
      police: {
        police_ob_number: 'OB/2026/00129',
        station_name: 'Westlands Police Station',
        officer_id: 'BADGE-004',
        officer_name: 'Officer Mwangi',
        abstract_image_url: 'https://example.com/abstract4.jpg',
      },
      case: {
        last_seen_location: 'Westlands Primary School',
        last_seen_lat: -1.2654,
        last_seen_lng: 36.8089,
        last_seen_time: '2026-05-29T08:00:00Z',
        status: 'APPROVED',
      },
    },
    // REJECTED CASE 1
    {
      child: {
        name: 'Samuel Mwangi',
        age: 16,
        gender: 'Male',
        description: 'Teenager left home after argument. Last seen wearing black jeans and red hoodie.',
        photo_url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=300&fit=crop',
      },
      reporter: {
        name: 'Grace Mwangi',
        phone: '+254 756 789 012',
        email: 'grace.mwangi@email.com',
        relationship: 'Mother',
      },
      police: {
        police_ob_number: 'OB/2026/00128',
        station_name: 'Kasarani Police Station',
        officer_id: 'BADGE-005',
        officer_name: 'Officer Kipkorir',
        abstract_image_url: 'https://example.com/abstract5.jpg',
      },
      case: {
        last_seen_location: 'Thika Road, Nairobi',
        last_seen_lat: -1.2214,
        last_seen_lng: 36.8869,
        last_seen_time: '2026-05-25T14:30:00Z',
        status: 'REJECTED',
      },
    },
    // RESOLVED/FOUND CASE 1
    {
      child: {
        name: 'James Otieno',
        age: 12,
        gender: 'Male',
        description: 'Missing after school. Wearing blue school uniform. Last seen heading home.',
        photo_url: 'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=400&h=300&fit=crop',
      },
      reporter: {
        name: 'Mary Otieno',
        phone: '+254 734 567 890',
        email: 'mary.otieno@email.com',
        relationship: 'Mother',
      },
      police: {
        police_ob_number: 'OB/2026/00126',
        station_name: 'Kibera Police Station',
        officer_id: 'BADGE-006',
        officer_name: 'Officer Atieno',
        abstract_image_url: 'https://example.com/abstract6.jpg',
      },
      case: {
        last_seen_location: 'Kibera Area, Nairobi',
        last_seen_lat: -1.3114,
        last_seen_lng: 36.7879,
        last_seen_time: '2026-05-26T18:00:00Z',
        status: 'RESOLVED',
      },
    },
  ];

  for (const sample of sampleCases) {
    // Create child
    const child = await prisma.child.create({
      data: sample.child,
    });

    // Create reporter
    const reporter = await prisma.reporter.create({
      data: sample.reporter,
    });

    // Create police abstract
    const police = await prisma.policeAbstract.create({
      data: {
        ...sample.police,
        stamp_verification_status: sample.case.status === 'APPROVED' ? 'VERIFIED' : 
                                   sample.case.status === 'REJECTED' ? 'INVALID' : 'PENDING',
      },
    });

    // Create case
    const caseRecord = await prisma.case.create({
      data: {
        child_id: child.id,
        reporter_id: reporter.id,
        police_abstract_id: police.id,
        last_seen_location: sample.case.last_seen_location,
        last_seen_lat: sample.case.last_seen_lat,
        last_seen_lng: sample.case.last_seen_lng,
        last_seen_time: new Date(sample.case.last_seen_time),
        status: sample.case.status,
      },
    });

    // Add sighting for some cases
    if (sample.child.name === 'Maya Wanjiku') {
      await prisma.sighting.create({
        data: {
          case_id: caseRecord.id,
          latitude: -1.2644,
          longitude: 36.7984,
          location_description: 'Karen Shopping Mall',
          photo_url: 'https://example.com/sighting1.jpg',
          reporter_name: 'Anonymous',
          status: 'PENDING',
        },
      });
    }

    if (sample.child.name === 'James Otieno') {
      await prisma.sighting.create({
        data: {
          case_id: caseRecord.id,
          latitude: -1.3044,
          longitude: 36.7679,
          location_description: 'Dagoretti Market',
          photo_url: 'https://example.com/sighting2.jpg',
          reporter_name: 'Community Member',
          status: 'VERIFIED',
        },
      });
    }

    console.log(`✅ Created case: ${sample.child.name} (${sample.case.status})`);
  }

  console.log('🎉 Database seed completed successfully!');
}

main()
  .catch((e) => {
    console.error('❌ Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
