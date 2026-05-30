class SightingModel {
  final String type;
  final String time;
  final String description;
  final String severity; // 'UNVERIFIED', 'USER_REPORT', 'VERIFIED'

  const SightingModel({
    required this.type,
    required this.time,
    required this.description,
    required this.severity,
  });
}

class AmberAlertModel {
  final String id;
  final String name;
  final int age;
  final String height;
  final String weight;
  final String description;
  final String lastSeenLocation;
  final String coordinates;
  final String timeElapsed;
  final String photoUrl;
  final List<SightingModel> sightings;

  const AmberAlertModel({
    required this.id,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.description,
    required this.lastSeenLocation,
    required this.coordinates,
    required this.timeElapsed,
    required this.photoUrl,
    required this.sightings,
  });
}

class MockData {
  static const List<AmberAlertModel> activeAlerts = [
    AmberAlertModel(
      id: "KE-2023-894",
      name: "Maya Lin",
      age: 7,
      height: "4'2\"",
      weight: "55 lbs",
      description: "Last seen wearing a red jacket, blue jeans, and light up sneakers. Known to wander near wooded areas.",
      lastSeenLocation: "Nairobi National Park Perimeter",
      coordinates: "1.3733° S, 36.8583° E",
      timeElapsed: "04:12:38",
      photoUrl: "https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?auto=format&fit=crop&q=80&w=400",
      sightings: [
        SightingModel(
          type: "UNVERIFIED_MATCH",
          time: "T-14 MINS",
          description: "Traffic Cam #402, Ngong Road. Partial facial match (62%).",
          severity: "UNVERIFIED",
        ),
        SightingModel(
          type: "USER_REPORT",
          time: "T-38 MINS",
          description: "Citizen reported seeing child matching description at local market.",
          severity: "USER_REPORT",
        ),
        SightingModel(
          type: "VERIFIED_TRACK",
          time: "T-52 MINS",
          description: "CCTV feed confirmed direction of travel North-West.",
          severity: "VERIFIED",
        ),
      ],
    ),
    AmberAlertModel(
      id: "KE-2023-902",
      name: "Kamau Mwangi",
      age: 8,
      height: "4'5\"",
      weight: "62 lbs",
      description: "Wearing a blue sweater, khaki trousers, and black sports shoes. Last seen near Westlands Market entrance.",
      lastSeenLocation: "Nairobi Westlands",
      coordinates: "1.2682° S, 36.8044° E",
      timeElapsed: "01:22:15",
      photoUrl: "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&q=80&w=400",
      sightings: [
        SightingModel(
          type: "USER_REPORT",
          time: "T-5 MINS",
          description: "Security guard at Westlands Mall reported boy matching profile near parking lot.",
          severity: "USER_REPORT",
        ),
        SightingModel(
          type: "UNVERIFIED_MATCH",
          time: "T-20 MINS",
          description: "Store front camera flagged high-probability matching height and clothing.",
          severity: "UNVERIFIED",
        ),
        SightingModel(
          type: "VERIFIED_TRACK",
          time: "T-1 HOUR",
          description: "CCTV from Westlands bus station confirmed boarding of a route 105 bus.",
          severity: "VERIFIED",
        ),
      ],
    ),
    AmberAlertModel(
      id: "KE-2023-774",
      name: "Faith Mutua",
      age: 5,
      height: "3'8\"",
      weight: "44 lbs",
      description: "Wearing a bright yellow dress and white sandals. Speaks in rapid Kiswahili/English. Shy around strangers.",
      lastSeenLocation: "Mombasa Road Perimeter",
      coordinates: "1.3210° S, 36.8920° E",
      timeElapsed: "02:45:10",
      photoUrl: "https://images.unsplash.com/photo-1503919545889-aef636e10ad4?auto=format&fit=crop&q=80&w=400",
      sightings: [
        SightingModel(
          type: "VERIFIED_TRACK",
          time: "T-10 MINS",
          description: "Highway patrol camera verified child sitting on roadside grass near Mombasa Road.",
          severity: "VERIFIED",
        ),
        SightingModel(
          type: "USER_REPORT",
          time: "T-45 MINS",
          description: "Boda-boda driver reported talking to a lost little girl near the roundabout.",
          severity: "USER_REPORT",
        ),
        SightingModel(
          type: "UNVERIFIED_MATCH",
          time: "T-2 HOURS",
          description: "Commercial CCTV captured partial face match near petroleum station.",
          severity: "UNVERIFIED",
        ),
      ],
    ),
  ];
}
