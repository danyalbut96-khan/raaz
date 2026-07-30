# RAAZ - Enterprise PRD Phase 4: Non-Functional Requirements

**Product Name:** RAAZ
**Company:** CloudExify
**Platform:** Android (Future: iOS, Web)
**Frontend:** Flutter
**Backend:** Supabase

---

## 1. Performance Requirements

### Objective
Ensure RAAZ delivers a highly responsive, fluid, and resource-efficient user experience on Android devices, accommodating varying network conditions and hardware specifications.

### Requirements
- **Application Startup Time:** Cold start must complete in < 2.0 seconds; warm start in < 1.0 second.
- **Screen Loading Time:** Screen transitions must occur in < 300ms.
- **Feed Loading:** Initial feed payload must render in < 1.0 second. Subsequent lazy loading must occur without visible blocking.
- **Scrolling Performance:** The feed and scrollable lists must maintain 60 frames per second (fps) under all conditions.
- **Image Loading:** Images must load asynchronously with caching. Low-resolution placeholders (blurhashes) must be displayed while high-resolution assets fetch.
- **Animation Performance:** All UI animations and transitions must be jank-free (zero dropped frames).
- **Offline Performance:** The app must remain responsive and allow cached read access instantly when the network drops.
- **Memory Usage:** The application footprint must not exceed 150MB of RAM during standard usage to prevent OS-level termination.
- **Battery Optimization:** Background processing and location/network polling must be minimized to preserve battery life.
- **Network Optimization:** All API payloads must be gzipped/compressed. Image assets must use WebP formats.
- **Background Tasks:** Non-critical tasks (e.g., analytics syncing, heavy cache cleanup) must run in scheduled background workers during idle/charging states.
- **Performance Targets:** Apdex score of 0.95 or higher for overall application performance.

### Acceptance Criteria
- Firebase Performance Monitoring reports median startup time under 2s on mid-tier Android devices.
- Flutter devtools show 0 dropped frames during scrolling tests.
- App memory usage stays below 150MB after 10 minutes of active use.

### Future Considerations
- iOS Metal rendering optimizations.
- WebAssembly (Wasm) payload reduction for the web client.

### Risks
- Flutter engine initialization overhead on low-end Android devices.
- Heavy media consumption inflating memory footprint.

### Best Practices
- Implement pagination and virtualization (e.g., `ListView.builder` in Flutter).
- Aggressive image caching using dedicated libraries like `cached_network_image`.

---

## 2. Scalability Requirements

### Objective
Architect the backend and frontend to handle a rapidly growing user base with concurrent load, ensuring system stability from launch through enterprise expansion.

### Requirements
- **Expected Users:** Support an initial base of 10,000 active users, scaling to 1,000,000 users without architecture changes.
- **Future Growth:** The architecture must handle 10x spikes in traffic during marketing campaigns.
- **Backend Scalability:** Supabase Edge Functions must automatically scale horizontally based on request volume.
- **Database Scalability:** PostgreSQL on Supabase must utilize connection pooling (PgBouncer) and read replicas as query volume increases.
- **Storage Growth:** Supabase Storage buckets must support petabyte-scale growth without performance degradation.
- **Realtime Scaling:** Supabase Realtime (WebSockets) must handle 100,000+ concurrent connections for live updates.
- **Push Notification Scaling:** FCM integration must process burst delivery of 1,000,000 notifications in under 5 minutes.
- **Analytics Scaling:** Analytics ingestion must be decoupled to prevent blocking core transactional processing.
- **Future Enterprise Expansion:** The system must support multi-tenant isolation and strict data segregation for B2B features.

### Acceptance Criteria
- Load testing (e.g., k6) confirms the API handles 10,000 requests per second (RPS) with < 200ms latency.
- Connection pooling prevents database connection limits from being exhausted under load.

### Future Considerations
- Migration to self-hosted or dedicated Supabase enterprise clusters.
- Sharding PostgreSQL databases for regional scaling.

### Risks
- WebSocket connection limits blocking realtime feature scalability.
- Unoptimized queries causing database bottlenecks at scale.

### Best Practices
- Use database indexing and materialized views for heavy read operations.
- Implement API rate limiting to protect resources.

---

## 3. Reliability Requirements

### Objective
Provide a highly resilient application that gracefully handles failures, prevents data loss, and maintains a consistent user experience.

### Requirements
- **Crash Recovery:** If the app crashes, it must restore the user's last known safe state upon restart.
- **Network Recovery:** Seamlessly detect network restoration and automatically resume paused uploads/requests.
- **Offline Recovery:** Locally queued actions (e.g., likes, comments, draft posts) must sync automatically when the connection is restored.
- **Retry Strategy:** Implement exponential backoff with jitter for all failed network requests to prevent backend thundering herds.
- **Data Consistency:** Ensure atomicity in transactions; partial updates (e.g., media uploaded but post not saved) must be rolled back or reconciled.
- **Draft Recovery:** Unsubmitted posts must be auto-saved to local storage (e.g., Hive/SQLite) to prevent work loss.
- **Application Stability:** Target a crash-free session rate of 99.9%.
- **Error Recovery:** Display user-friendly error boundaries in the UI instead of white screens when a widget fails to render.

### Acceptance Criteria
- Airplane mode testing validates that queued actions succeed upon reconnection.
- Crashlytics dashboard confirms a crash-free session rate > 99.9%.
- Disconnecting mid-upload results in a successful resume or clean failure state.

### Future Considerations
- Background sync APIs for deeper OS integration.
- Conflict resolution strategies (e.g., CRDTs) for offline multi-device usage.

### Risks
- Large offline queues causing sync bottlenecks upon reconnection.
- Edge cases in state management leading to corrupted local caches.

### Best Practices
- Utilize the Repository pattern to abstract network vs. local data logic.
- Implement robust exception handling at both global and widget levels.

---

## 4. Availability Requirements

### Objective
Ensure RAAZ services remain operational and accessible with minimal downtime, even during deployments or partial outages.

### Requirements
- **Application Availability:** The mobile app must remain fully usable for offline capabilities 100% of the time.
- **Backend Availability:** Supabase backend must maintain a 99.99% uptime SLA.
- **Maintenance Behaviour:** Zero-downtime deployments must be utilized. If maintenance is required, users must see a localized, friendly "Under Maintenance" screen.
- **Graceful Degradation:** If non-critical services (e.g., recommendation engine, analytics) fail, the core app (viewing/posting) must continue to function.
- **Offline Behaviour:** Core navigation and cached feed viewing must work completely offline without presenting continuous error dialogues.

### Acceptance Criteria
- Uptime monitoring (e.g., Datadog, Pingdom) verifies 99.99% backend availability over a 30-day period.
- Disabling the analytics endpoint manually does not disrupt core app flows.

### Future Considerations
- Multi-region failover deployments.
- Read-only modes during major database migrations.

### Risks
- Third-party dependency outages bringing down the app.
- DNS or edge routing failures.

### Best Practices
- Circuit breaker patterns for third-party API calls.
- Automated health checks and self-healing infrastructure.

---

## 5. Security Requirements

### Objective
Protect user anonymity, secure all data in transit and at rest, and defend the platform against malicious actors and abuse.

### Requirements
- **Anonymous Identity Protection:** No personally identifiable information (PII) beyond necessary authentication tokens may be exposed in the UI or public APIs.
- **Data Encryption:** All data in transit must use TLS 1.3. Sensitive data at rest must use AES-256 encryption.
- **Secure Communication:** Certificate pinning must be evaluated to prevent Man-in-the-Middle (MitM) attacks.
- **API Security:** All endpoints must require valid JWT authentication. Supabase Row Level Security (RLS) must be strictly enforced.
- **Authentication Security:** Secure handling of access and refresh tokens using Android Keystore.
- **Guest Security:** Guest sessions must be sandboxed with restricted database access and rate limits.
- **Session Protection:** Inactive sessions must be revoked. Refresh tokens must rotate automatically.
- **Device Security:** Detect rooted devices or emulators and disable sensitive features or warn the user.
- **Input Validation:** All user inputs must be sanitized on the client and strictly validated on the backend to prevent SQLi and XSS.
- **Spam Protection:** Implement CAPTCHA or invisible bot detection on authentication and posting endpoints.
- **Abuse Prevention:** Rate limit content creation to prevent flooding (e.g., max 5 posts per minute per user).
- **Moderation Protection:** Moderation actions must be logged and require elevated RBAC (Role-Based Access Control) privileges.
- **Future Multi-Factor Support:** Architecture must support the addition of MFA/2FA for account recovery and sensitive actions.

### Acceptance Criteria
- Penetration testing confirms no bypassing of Supabase RLS policies.
- SSL Labs scan of the API domain returns an A+ rating.
- Tokens are verified to be stored in secure encrypted storage (e.g., `flutter_secure_storage`).

### Future Considerations
- Biometric authentication for app unlock.
- End-to-end encryption (E2EE) for direct messaging.

### Risks
- Misconfigured RLS policies exposing private data.
- Supply chain attacks via compromised Flutter packages.

### Best Practices
- Principle of Least Privilege for all database roles and API keys.
- Regular automated vulnerability scanning of dependencies.

---

## 6. Privacy Requirements

### Objective
Ensure user privacy by adhering to strict data minimization principles, transparent policies, and global privacy standards.

### Requirements
- **Anonymous First Principle:** Default all interactions to the highest level of anonymity. Users must explicitly opt-in to reveal metadata (if applicable).
- **Data Collection Policy:** Clearly articulate what is collected, why, and how long it is kept in a plain-language Privacy Policy accessible within the app.
- **Minimal Data Collection:** Collect only the telemetry and user data strictly necessary for app functionality and security.
- **User Consent:** Require explicit consent for tracking, analytics, and crash reporting upon first launch.
- **Privacy Controls:** Provide in-app toggles to disable non-essential data sharing and analytics.
- **Data Retention:** Automatically purge inactive anonymous accounts and orphaned data after a defined period (e.g., 12 months).
- **Data Deletion:** Provide a clear, immediate "Delete Account and Data" button inside the app settings that executes hard deletions or irreversible anonymization.
- **GDPR Readiness:** Structure data storage to allow for straightforward data export (Right to Access) and deletion (Right to be Forgotten).
- **Future Compliance:** Architecture must support geographic data localization for upcoming regional privacy laws (e.g., CCPA, CPRA, DPDPA).

### Acceptance Criteria
- App passes Google Play privacy policy compliance checks.
- Account deletion completely removes the user record and associated data from Supabase within 30 days.

### Future Considerations
- EU data residency options.
- On-device machine learning to avoid sending user data to the cloud.

### Risks
- Third-party SDKs (e.g., analytics) collecting shadow profiles without consent.
- Accidental logging of sensitive data.

### Best Practices
- Privacy by Design methodology.
- Regular privacy audits and Data Protection Impact Assessments (DPIAs).

---

## 7. Accessibility Requirements

### Objective
Ensure RAAZ is inclusive and fully usable by individuals with varying abilities, adhering to WCAG 2.1 AA standards where applicable.

### Requirements
- **Screen Reader Support:** Full compatibility with Android TalkBack. All UI elements must have descriptive semantic labels.
- **Large Text:** UI must scale gracefully when the user increases the system font size without truncating text or breaking layouts.
- **Color Contrast:** Text and interactive elements must maintain a minimum contrast ratio of 4.5:1 against their backgrounds.
- **Reduced Motion:** Respect system-level "reduce motion" settings by disabling non-essential animations and parallax effects.
- **Touch Target Sizes:** All interactive elements (buttons, icons) must have a minimum touch target size of 48x48 dp.
- **Keyboard Navigation:** Support basic D-pad and Bluetooth keyboard navigation for focus states.
- **Voice Support (Future):** Architecture should accommodate future integration with voice commands and assistants.

### Acceptance Criteria
- Google Accessibility Scanner app reports zero critical violations on core screens.
- QA validates complete user flows using only TalkBack.

### Future Considerations
- High-contrast themes.
- Support for iOS VoiceOver and Web Content Accessibility Guidelines (WCAG) for future platforms.

### Risks
- Complex custom animations breaking screen reader context.
- Overriding system accessibility settings within custom widgets.

### Best Practices
- Use Flutter's `Semantics` widget extensively.
- Test with accessibility services enabled during regular development sprints.

---

## 8. Localization Requirements

### Objective
Provide a seamless experience for users globally by supporting multiple languages and regional formats natively.

### Requirements
- **English:** Primary fallback and development language.
- **Urdu:** Full translation of all UI strings.
- **Arabic:** Full translation of all UI strings.
- **Future Languages:** Architecture must use resource files (e.g., ARB or JSON) to allow rapid addition of new languages via OTA updates or app releases.
- **RTL Support:** Complete Right-to-Left layout mirroring for Arabic and Urdu, including animations and directional icons.
- **Date Formats:** Dates must format dynamically based on the user's locale (e.g., DD/MM/YYYY vs. MM/DD/YYYY).
- **Time Formats:** Support for 12-hour and 24-hour clocks based on system preferences.
- **Regional Preferences:** Support localized number formatting and calendar types (e.g., Gregorian vs. Hijri where applicable).

### Acceptance Criteria
- Changing system language to Arabic automatically flips the app layout to RTL and updates all text.
- No text clipping occurs when translating from English to languages with longer word lengths.

### Future Considerations
- In-app language switcher overriding system language.
- Dynamic translation of user-generated content.

### Risks
- Hardcoded strings bypassing localization files.
- LTR icons failing to mirror in RTL mode.

### Best Practices
- Utilize Flutter's `flutter_localizations` and `intl` packages.
- Implement UI testing specifically for RTL layouts.

---

## 9. Compatibility Requirements

### Objective
Ensure broad compatibility across the Android ecosystem, accommodating various form factors and OS versions.

### Requirements
- **Android Version Support:** Minimum SDK version 24 (Android 7.0 Nougat). Target SDK version must align with the latest Google Play requirements (currently API 34).
- **Tablet Support:** UI must utilize responsive design principles to expand gracefully on tablets (e.g., multi-pane layouts or wider margins), not just stretch mobile views.
- **Different Screen Sizes:** Support aspect ratios ranging from 16:9 to ultra-wide 21:9 devices.
- **Landscape Behaviour:** Core viewing experiences must adapt to landscape orientation, or specific screens may be locked to portrait if required by UX, but handled cleanly.
- **Dark Mode:** Full support for System Light/Dark themes. Must seamlessly switch while the app is running.
- **Future Foldable Devices:** UI should handle dynamic screen resizing (hinge detection, continuity) for foldables.

### Acceptance Criteria
- App installs and runs flawlessly on Android 7.0 through Android 14.
- Switching between light and dark modes instantly updates the UI without requiring an app restart.

### Future Considerations
- Desktop-class UI for ChromeOS compatibility.
- iOS and Web responsive alignment.

### Risks
- Deprecated Android APIs breaking on newer OS versions.
- UI clipping on devices with aggressive display cutouts (notches/punch-holes).

### Best Practices
- Use Flutter's `SafeArea` and `LayoutBuilder` widgets.
- Test heavily on Firebase Test Lab using diverse physical devices.

---

## 10. Logging Requirements

### Objective
Implement comprehensive logging to facilitate rapid debugging, security auditing, and system monitoring without compromising user privacy.

### Requirements
- **Application Logs:** Log non-sensitive state changes and navigation events for debugging. Strip all PII.
- **Error Logs:** Capture caught exceptions and API failures with stack traces and context (OS, app version).
- **Crash Logs:** Automatically capture fatal unhandled exceptions (via Crashlytics/Sentry).
- **Security Logs:** Log authentication failures, token revocations, and unauthorized access attempts on the backend.
- **Moderation Logs:** Maintain an immutable audit trail of all content moderation actions (flags, deletions, bans).
- **Analytics Logs:** Route behavioral events to the analytics engine securely.

### Acceptance Criteria
- Developers can trace a user journey leading up to a non-fatal error via logs without seeing user credentials or private text.
- Backend logs capture request IDs linking API calls to database transactions.

### Future Considerations
- Centralized log aggregation (e.g., ELK stack, Datadog) for advanced querying.
- Realtime alerting based on log patterns.

### Risks
- Accidentally logging JWT tokens or user passwords.
- Excessive logging impacting device storage or backend costs.

### Best Practices
- Use distinct log levels (DEBUG, INFO, WARN, ERROR, FATAL).
- Implement log redaction rules on the client before transmission.

---

## 11. Monitoring Requirements

### Objective
Proactively detect and respond to application issues, performance degradation, and outages before they impact the user base.

### Requirements
- **Crash Monitoring:** Real-time alerting for spikes in crash rates (fatal and non-fatal).
- **Performance Monitoring:** Track app start times, screen renders, and network request latencies (Firebase Performance/Sentry).
- **API Monitoring:** Monitor API response codes (4xx, 5xx rates) and response times.
- **Realtime Monitoring:** Track WebSocket connection stability and drop rates.
- **Database Monitoring:** Monitor Supabase CPU, RAM, connection limits, and slow queries.

### Acceptance Criteria
- An alert is automatically triggered to the engineering team if the API error rate exceeds 2% over a 5-minute window.
- Crashlytics dashboard is fully configured and receiving crash reports from beta testers.

### Future Considerations
- Automated incident creation in Jira/PagerDuty.
- Synthetic monitoring (simulated user traffic to test endpoints).

### Risks
- Alert fatigue from overly sensitive thresholds.
- Blind spots in monitoring specific geographical regions.

### Best Practices
- Establish clear SLAs and SLIs (Service Level Indicators).
- Conduct regular "game days" to test alerting configurations.

---

## 12. Analytics Requirements

### Objective
Gather actionable insights into user behavior, feature adoption, and platform growth to drive data-informed product decisions.

### Requirements
- **Daily Active Users (DAU):** Track unique anonymous sessions per 24 hours.
- **Monthly Active Users (MAU):** Track unique anonymous sessions per 28/30 days.
- **Retention:** Track Day 1, Day 7, Day 30 user retention cohorts.
- **Session Duration:** Measure average time spent per session and sessions per user per day.
- **Post Creation:** Track funnel completion for creating posts (initiate -> draft -> publish).
- **Comments:** Track engagement rates (comments per post, users commenting).
- **Support Actions:** Track frequency of Upvotes/Support actions on content.
- **Bookmarks:** Track usage of save/bookmark functionality.
- **Search Usage:** Monitor search volume, popular keywords, and zero-result queries.
- **Reflection Usage:** Track engagement with daily reflections or prompts.
- **Challenge Usage:** Track participation and completion rates for community challenges.

### Acceptance Criteria
- Analytics events are batched and sent without impacting UI performance.
- PM dashboards successfully display DAU/MAU and core engagement funnels.

### Future Considerations
- A/B testing framework integration.
- Predictive churn analytics.

### Risks
- Ad-blockers or DNS filters dropping analytics payloads.
- Broken tracking funnels due to UI changes.

### Best Practices
- Maintain a centralized analytics tracking plan/schema.
- Separate analytics logic from core business logic (e.g., via Middleware or Observer patterns).

---

## 13. Backup & Recovery

### Objective
Safeguard platform data against accidental deletion, corruption, or catastrophic failure, ensuring rapid recovery capabilities.

### Requirements
- **Database Backup:** Automated daily Point-in-Time Recovery (PITR) backups for the Supabase PostgreSQL database.
- **Media Backup:** Replication or backup strategies for Supabase Storage buckets containing user-uploaded media.
- **Recovery Strategy:** Documented and tested procedures for restoring the database to a specific point in time within < 4 hours.
- **Disaster Recovery:** Ability to deploy backend infrastructure to an alternate region in the event of a total primary region failure.

### Acceptance Criteria
- A test restoration of the production database to a staging environment succeeds within the target time frame.
- Automated backups are verified to run daily without failure.

### Future Considerations
- Active-Active multi-region database architecture.
- Immutable backups to protect against ransomware.

### Risks
- Restoring from backups causing data conflicts with cached client data.
- Storage costs escalating due to aggressive backup retention policies.

### Best Practices
- Follow the 3-2-1 backup rule.
- Regularly audit backup integrity by performing dummy restorations.

---

## 14. Compliance Requirements

### Objective
Ensure RAAZ adheres to legal standards, app store guidelines, and internal safety policies to maintain distribution and brand integrity.

### Requirements
- **Google Play Policies:** Adhere strictly to policies regarding user-generated content (UGC), deceptive behavior, and permissions.
- **Privacy Requirements:** Comply with COPPA (if applicable) and general data protection standards (GDPR/CCPA frameworks).
- **Advertising Policies:** (If applicable) Ensure any future ad integrations comply with ad network safety guidelines.
- **Content Moderation:** Implement robust in-app reporting mechanisms for users to flag inappropriate content. Provide tools for admins to act on flags within 24 hours.
- **Children Safety:** Ensure age-gating if the app is restricted to users 13+ or 18+. Prevent indexation of child-related sensitive data.
- **Community Guidelines:** Display clear terms of service and community guidelines; require agreement upon registration.

### Acceptance Criteria
- App is successfully reviewed and published on the Google Play Store without policy rejections.
- In-app reporting flow successfully alerts backend moderation systems.

### Future Considerations
- Automated AI moderation (e.g., Google Cloud Vision API for NSFW content).
- iOS App Store specific compliance (e.g., mandatory account deletion APIs).

### Risks
- Sudden policy changes by Google leading to app suspension.
- Inadequate moderation leading to legal liability or brand damage.

### Best Practices
- Include terms and policies directly in the app bundle to ensure they are readable offline.
- Keep a legal/compliance checklist updated per release.

---

## 15. Maintainability Requirements

### Objective
Establish an engineering foundation that supports rapid iteration, minimizes technical debt, and allows new developers to onboard easily.

### Requirements
- **Clean Code Expectations:** Enforce strict linting rules (e.g., `flutter_lints`). Code must adhere to SOLID principles.
- **Modular Development:** Architect the Flutter app using feature-driven or domain-driven folder structures (e.g., Clean Architecture).
- **Reusable Components:** Maintain a centralized design system and widget library to ensure UI consistency and reduce duplication.
- **Documentation:** All public APIs, core business logic, and architecture decisions (ADRs) must be documented.
- **Testing Expectations:** Maintain a minimum 70% unit test coverage for business logic. Core user flows must be covered by integration/UI tests.
- **Future Expansion:** The architecture must abstract platform-specific code to facilitate the future iOS and Web ports without rewriting business logic.

### Acceptance Criteria
- CI/CD pipelines block PRs that fail linting or drop test coverage below thresholds.
- A new developer can build and run the project locally within 30 minutes using the README.

### Future Considerations
- Monorepo structure if adding internal admin apps or web clients.
- Automated dependency update management (e.g., Dependabot).

### Risks
- Accumulating technical debt to meet early deadlines.
- Tight coupling to third-party packages making future migrations difficult.

### Best Practices
- Enforce strict PR review policies (min 1 approval).
- Use dependency injection to decouple services and ease testing.

---

## 16. Quality Attributes

### Objective
Define the overarching non-functional characteristics that govern the architecture and user experience of RAAZ.

### Requirements
- **Performance:** System must be highly responsive (see Section 1).
- **Security:** Data and identities must be protected against unauthorized access (see Section 5).
- **Reliability:** System must function correctly under adverse conditions (see Section 3).
- **Maintainability:** Codebase must be easy to understand, modify, and extend (see Section 15).
- **Scalability:** System must handle increased load gracefully (see Section 2).
- **Availability:** Services must be accessible when required by users (see Section 4).
- **Usability:** Interface must be intuitive, engaging, and require zero training.
- **Accessibility:** Platform must be inclusive to users with disabilities (see Section 7).
- **Privacy:** User data must be minimized and protected by default (see Section 6).

### Acceptance Criteria
- All quality attributes are tracked via measurable KPIs.

### Future Considerations
- Continuous measurement of attributes in production.

### Risks
- Over-optimizing one attribute (e.g., security) at the cost of another (e.g., usability).

### Best Practices
- Regular architecture reviews to ensure all attributes remain balanced.

---

## 17. Success Criteria

### Objective
Establish clear, measurable targets for the Version 1 launch to evaluate the technical success of the non-functional requirements.

### Requirements
- Define specific numerical targets across various operational metrics to quantify success.

### Acceptance Criteria
1. **Crash-Free Sessions:** > 99.9% measured via Crashlytics.
2. **App Startup Time:** < 2.0 seconds (Cold Start) on mid-tier Android devices.
3. **API Latency:** 95th percentile (p95) response time < 300ms.
4. **App Store Rating:** Technical stability supports a > 4.5 star rating on Google Play.
5. **Uptime:** 99.9% backend availability in the first 30 days post-launch.
6. **Test Coverage:** > 70% unit test coverage for core business logic.
7. **User Retention:** Technical performance issues account for < 5% of user churn.
8. **Scalability Check:** Backend handles 5,000 concurrent connections during stress testing without degradation.

### Future Considerations
- Adjusting criteria for Version 2 based on real-world usage patterns.

### Risks
- Setting unrealistic goals that delay launch without adding significant value.

### Best Practices
- Review success criteria on a weekly basis post-launch.

---
*End of Document*
