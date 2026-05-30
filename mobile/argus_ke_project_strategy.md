# ARGUS-KE (Tafuta Mtoto) - Product Strategy & Roadmap

## 1. Project Description
ARGUS-KE (Tafuta Mtoto) is a high-integrity missing persons recovery platform engineered for the Kenyan context, combining AI-driven surveillance with rigorous legal verification. Inspired by professional tactical dashboards, the app transforms every smartphone into a node for public safety while maintaining strict adherence to the Data Protection Act of 2019. By mandating Police OB Numbers for all reports and utilizing real-time face matching via Google ML Kit, ARGUS-KE eliminates the noise of unverified social media alerts, providing a secure, moderated, and geo-targeted ecosystem for reuniting families with missing children.

## 2. Suggested Tech Stack & Packages
*   **Frontend:** Flutter (iOS/Android)
    *   `google_ml_kit`: For real-time face detection and feature extraction.
    *   `camera`: For the high-performance live feed.
    *   `google_maps_flutter`: For geo-targeted sightings and Amber Alert visualization.
*   **Backend & Database:** Supabase (PostgreSQL + Auth + Storage)
    *   `supabase_flutter`: For real-time database listeners (essential for matching alerts).
    *   Edge Functions (Deno): To handle heavy logic and moderation triggers.
*   **Messaging & Alerts:** 
    *   `africastalking`: For SMS-based Amber Alerts and notification fallbacks.
    *   `firebase_messaging`: For low-latency push notifications.
*   **AI/ML Logic:**
    *   Google ML Kit (On-device): For face detection to ensure privacy-first processing.
    *   Vector Similarity Search (Supabase/pgvector): For matching detected face embeddings against the verified database.

## 3. High-Level User Flows
1.  **Reporting Flow:** Parent/Guardian → Input Details → Upload Photo → **Mandatory Police OB Number + Abstract Image** → Submission → Moderator Queue → Verified & Live.
2.  **Surveillance Flow:** User opens "Live Camera" → AI detects face in frame → Extracts embedding → Compares against local/cloud DB of verified cases → **Match Found Alert** (Private notification to user + Admin trigger).
3.  **Sighting Flow:** Community User sees child → Submits Anonymous Tip (Photo/Location) → Admin Review → Verified parent notified via private channel.
4.  **Amber Alert Flow:** High-priority case approved → System triggers geo-fence → AfricasTalking SMS + Push sent to all users within 50km radius.

## 4. Key Differentiators
*   **Legal Moat:** Unlike WhatsApp/Facebook groups, every case requires a Police OB Number, preventing malicious false reports or harassment.
*   **Edge AI Privacy:** Face detection happens on-device; only anonymized vectors are compared, ensuring DPA compliance.
*   **Local Infrastructure:** Integrated with AfricasTalking for deep SMS penetration in areas with low data connectivity.
*   **Tactical UI:** A "Dark Ops" dashboard aesthetic that conveys urgency and professionalism, moving away from "charity" vibes to "security" vibes.

## 5. Pitch Deck Outline (8-10 Slides)
1.  **The Hook:** Statistics on missing children in Kenya (The Crisis).
2.  **The Problem:** Fragmented reporting, unverified social media noise, and delayed response times.
3.  **The Solution:** ARGUS-KE (Tafuta Mtoto) – The AI-Powered Recovery Network.
4.  **How it Works:** The "Verified-Only" workflow and the Live Camera matching engine.
5.  **Demo/Mockups:** Showcasing the Dark UI and the AI detection interface.
6.  **Privacy & Ethics:** DPA 2019 compliance, data encryption, and anti-abuse mechanisms.
7.  **Impact/Tech:** Real-time Amber Alerts via AfricasTalking.
8.  **The MVP Roadmap:** 48-hour hackathon execution plan.
9.  **Sustainability:** Partnerships with police and NGOs.
10. **The Team:** Why we are the ones to build this.

## 6. Risks & Mitigations
*   **Risk:** False reports using fake OB numbers.
    *   **Mitigation:** Human moderation layer; system requires an image upload of the physical Police Abstract.
*   **Risk:** Privacy infringement of the public.
    *   **Mitigation:** Faces not in the verified database are immediately discarded; no images of non-missing persons are stored.
*   **Risk:** High battery/data usage for AI.
    *   **Mitigation:** Optimized ML Kit models; Live Camera is user-initiated, not background-persistent.
*   **Risk:** SMS Costs for Amber Alerts.
    *   **Mitigation:** Use Push Notifications as primary; SMS only for high-priority local targets to manage AfricasTalking credits.