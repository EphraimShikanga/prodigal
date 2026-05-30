# ARGUS-KE (Tafuta Mtoto) Backend API Documentation

This document describes all available API endpoints, validation rules, request payloads, and response structures for the ARGUS-KE missing children recovery platform. 

* **Base URL (Local Dev)**: `http://localhost:3000`

---

## 1. Cases Endpoints (`/cases`)

### 1.1 File a Missing Child Report
Submit a new verification request with nested data fields for the Child, Reporter (Guardian), and Police Abstract.

* **Method**: `POST`
* **Route**: `/cases`
* **Headers**: `Content-Type: application/json`
* **Request Payload (`CreateCaseDto`)**:
  ```json
  {
    "child": {
      "name": "Kamau Mwangi",
      "age": 8,
      "gender": "MALE",
      "description": "Wearing a blue sweater and khaki trousers",
      "photo_url": "https://secure.s3.aws/images/child_kamau.jpg"
    },
    "reporter": {
      "name": "Jane Mwangi",
      "phone": "+254711223344",
      "email": "jane.mwangi@gmail.com",
      "relationship": "MOTHER"
    },
    "police": {
      "police_ob_number": "OB-1024/2026",
      "station_name": "Westlands Police Station",
      "officer_id": "AP_8842",
      "officer_name": "Sgt. Njoroge",
      "abstract_image_url": "https://secure.police.go.ke/abstracts/abs-1024.jpg"
    },
    "last_seen_location": "Nairobi Westlands",
    "last_seen_lat": -1.2682,
    "last_seen_lng": 36.8044,
    "last_seen_time": "2026-05-30T10:00:00Z"
  }
  ```

* **Validation Rules**:
  * **Child**:
    * `name`: Required String.
    * `age`: Required Integer (between 0 and 18).
    * `gender`: Required String.
    * `description`: Required String.
    * `photo_url`: Required Url.
  * **Reporter**:
    * `name`: Required String.
    * `phone`: Required String (e.g. MSISDN standard).
    * `email`: Optional String (must be valid email format if present).
    * `relationship`: Required String (e.g., MOTHER, FATHER, GUARDIAN).
  * **Police**:
    * `police_ob_number`: Required String (must be unique).
    * `station_name`: Required String.
    * `officer_id`: Required String.
    * `officer_name`: Required String.
    * `abstract_image_url`: Required Url.
  * **Case Metadata**:
    * `last_seen_location`: Required String.
    * `last_seen_lat`: Required Float (between -90 and 90).
    * `last_seen_lng`: Required Float (between -180 and 180).
    * `last_seen_time`: Required DateTime ISO String.

* **Response Payload (`201 Created`)**:
  ```json
  {
    "id": "f8b9e278-beac-4039-9c28-dd8497ed3189",
    "child_id": "9ef75114-0664-49c8-ba64-bbb2d8d16ab5",
    "reporter_id": "996f0535-3f8b-4511-b599-afdac677b971",
    "police_abstract_id": "19ce295f-c2b5-430a-8823-2aa62e9590e8",
    "last_seen_location": "Nairobi Westlands",
    "last_seen_lat": -1.2682,
    "last_seen_lng": 36.8044,
    "last_seen_time": "2026-05-30T10:00:00.000Z",
    "status": "PENDING",
    "created_at": "2026-05-30T11:43:25.549Z",
    "child": {
      "id": "9ef75114-0664-49c8-ba64-bbb2d8d16ab5",
      "name": "Kamau Mwangi",
      "age": 8,
      "gender": "MALE",
      "description": "Wearing a blue sweater and khaki trousers",
      "photo_url": "https://secure.s3.aws/images/child_kamau.jpg",
      "created_at": "2026-05-30T11:43:25.537Z"
    },
    "reporter": {
      "id": "996f0535-3f8b-4511-b599-afdac677b971",
      "name": "Jane Mwangi",
      "phone": "+254711223344",
      "email": "jane.mwangi@gmail.com",
      "relationship": "MOTHER",
      "created_at": "2026-05-30T11:43:25.542Z"
    },
    "police_abstract": {
      "id": "19ce295f-c2b5-430a-8823-2aa62e9590e8",
      "police_ob_number": "OB-1024/2026",
      "station_name": "Westlands Police Station",
      "officer_id": "AP_8842",
      "officer_name": "Sgt. Njoroge",
      "abstract_image_url": "https://secure.police.go.ke/abstracts/abs-1024.jpg",
      "stamp_verification_status": "PENDING",
      "created_at": "2026-05-30T11:43:25.545Z"
    }
  }
  ```

---

### 1.2 Fetch Missing Cases List
Retrieve all missing case profiles. Supports filtering by case verification status.

* **Method**: `GET`
* **Route**: `/cases`
* **Query Parameters**:
  * `status` (Optional): Filter by `PENDING`, `APPROVED`, `RESOLVED`, or `REJECTED`.
* **Response Payload (`200 OK`)**:
  ```json
  [
    {
      "id": "f8b9e278-beac-4039-9c28-dd8497ed3189",
      "child_id": "9ef75114-0664-49c8-ba64-bbb2d8d16ab5",
      "reporter_id": "996f0535-3f8b-4511-b599-afdac677b971",
      "police_abstract_id": "19ce295f-c2b5-430a-8823-2aa62e9590e8",
      "last_seen_location": "Nairobi Westlands",
      "last_seen_lat": -1.2682,"last_seen_lng": 36.8044,
      "last_seen_time": "2026-05-30T10:00:00.000Z",
      "status": "APPROVED",
      "created_at": "2026-05-30T11:43:25.549Z",
      "child": { ... },
      "reporter": { ... },
      "police_abstract": { ... },
      "sightings": [],
      "amber_alerts": []
    }
  ]
  ```

---

### 1.3 Fetch Single Case Details
Get the detailed profile of a specific case, including nested child, reporter, police abstract verification, sightings, and dispatched amber alerts.

* **Method**: `GET`
* **Route**: `/cases/:id`
* **Path Parameters**:
  * `id`: UUID of the Case.
* **Response Payload (`200 OK`)**:
  *(Returns single Case object with child, reporter, police abstract, sightings, and amber alerts populated)*

---

### 1.4 Get Police Dashboard Metrics
Retrieve real-time telemetry metrics matching the tactical system overview interface.

* **Method**: `GET`
* **Route**: `/cases/metrics`
* **Response Payload (`200 OK`)**:
  ```json
  {
    "activeAlerts": 1,
    "caseProfiles": 1,
    "activeCameras": 1,
    "systemUptime": "100%",
    "recognitionLatency": "84ms"
  }
  ```

---

### 1.5 Update Case/Abstract Verification Status (Police Moderation)
Allows police officers or administrators to approve or reject a report.

* **Method**: `PATCH`
* **Route**: `/cases/:id/status`
* **Path Parameters**:
  * `id`: UUID of the Case.
* **Request Payload (`UpdateCaseStatusDto`)**:
  ```json
  {
    "status": "APPROVED"
  }
  ```
  *(Supported values: `PENDING`, `APPROVED`, `RESOLVED`, `REJECTED`)*

* **Side Effects**:
  * Setting status to **`APPROVED`** transitions the child's status to active and automatically schedules/logs an simulated **Africa's Talking SMS geofenced alert broadcast** (50km radius) and adds a dispatch log.
* **Response Payload (`200 OK`)**:
  *(Returns the updated Case object with updated status and verified police abstract stamp status)*

---

## 2. Sightings Endpoints (`/sightings`)

### 2.1 Submit Sighting Tip
Allows citizens to record coordinates and photo evidence if they find a lost child. Setting reporter details is optional to support anonymous inputs.

* **Method**: `POST`
* **Route**: `/sightings`
* **Headers**: `Content-Type: application/json`
* **Request Payload (`SubmitSightingDto`)**:
  ```json
  {
    "case_id": "f8b9e278-beac-4039-9c28-dd8497ed3189",
    "latitude": -1.2701,
    "longitude": 36.8122,
    "location_description": "Seen near Sarit Centre entrance",
    "photo_url": "https://secure.s3.aws/tips/tip_kamau.jpg",
    "reporter_name": "John Doe",
    "reporter_phone": "+254700000000"
  }
  ```
  *(Leave `reporter_name` and `reporter_phone` empty or omit them to submit anonymously)*

* **Response Payload (`201 Created`)**:
  ```json
  {
    "id": "217af81f-91db-40de-a8f9-25ee7aa8134c",
    "case_id": "f8b9e278-beac-4039-9c28-dd8497ed3189",
    "latitude": -1.2701,
    "longitude": 36.8122,
    "location_description": "Seen near Sarit Centre entrance",
    "photo_url": "https://secure.s3.aws/tips/tip_kamau.jpg",
    "reporter_name": "John Doe",
    "reporter_phone": "+254700000000",
    "status": "PENDING",
    "created_at": "2026-05-30T11:44:10.714Z"
  }
  ```

---

### 2.2 Fetch Recent Sightings List
Get a feed of all recent sightings (e.g. to populate the sightings screen in the mobile application).

* **Method**: `GET`
* **Route**: `/sightings`
* **Response Payload (`200 OK`)**:
  ```json
  [
    {
      "id": "217af81f-91db-40de-a8f9-25ee7aa8134c",
      "case_id": "f8b9e278-beac-4039-9c28-dd8497ed3189",
      "latitude": -1.2701,
      "longitude": 36.8122,
      "location_description": "Seen near Sarit Centre entrance",
      "photo_url": "https://secure.s3.aws/tips/tip_kamau.jpg",
      "reporter_name": "John Doe",
      "reporter_phone": "+254700000000",
      "status": "PENDING",
      "created_at": "2026-05-30T11:44:10.714Z",
      "case": {
        "id": "f8b9e278-beac-4039-9c28-dd8497ed3189",
        "child_id": "9ef75114-0664-49c8-ba64-bbb2d8d16ab5",
        "reporter_id": "996f0535-3f8b-4511-b599-afdac677b971",
        "police_abstract_id": "19ce295f-c2b5-430a-8823-2aa62e9590e8",
        "last_seen_location": "Nairobi Westlands",
        "last_seen_lat": -1.2682,"last_seen_lng": 36.8044,
        "last_seen_time": "2026-05-30T10:00:00.000Z",
        "status": "APPROVED",
        "created_at": "2026-05-30T11:43:25.549Z",
        "child": {
          "id": "9ef75114-0664-49c8-ba64-bbb2d8d16ab5",
          "name": "Kamau Mwangi",
          "age": 8,
          "gender": "MALE",
          "description": "Wearing a blue sweater...",
          "photo_url": "https://..."
        }
      }
    }
  ]
  ```

---

## 3. Alerts Endpoints (`/alerts`)

### 3.1 Fetch Active Amber Alerts Carousel Feed
Retrieve a feed of currently active alerts to populate the home screen/carousel widget.

* **Method**: `GET`
* **Route**: `/alerts`
* **Response Payload (`200 OK`)**:
  ```json
  [
    {
      "id": "f55211aa-3c25-4b57-9366-6d4e6d6ab2fe",
      "case_id": "f8b9e278-beac-4039-9c28-dd8497ed3189",
      "radius_km": 50,
      "message": "AMBER ALERT: Missing child Kamau Mwangi, age 8, last seen at Nairobi Westlands. If seen, please report on ARGUS-KE. OB Number: OB-1024/2026",
      "dispatch_timestamp": "2026-05-30T11:43:50.834Z",
      "case": {
        "id": "f8b9e278-beac-4039-9c28-dd8497ed3189",
        "child_id": "9ef75114-0664-49c8-ba64-bbb2d8d16ab5",
        "reporter_id": "996f0535-3f8b-4511-b599-afdac677b971",
        "police_abstract_id": "19ce295f-c2b5-430a-8823-2aa62e9590e8",
        "last_seen_location": "Nairobi Westlands",
        "last_seen_lat": -1.2682,"last_seen_lng": 36.8044,
        "last_seen_time": "2026-05-30T10:00:00.000Z",
        "status": "APPROVED",
        "created_at": "2026-05-30T11:43:25.549Z"
      }
    }
  ]
  ```
