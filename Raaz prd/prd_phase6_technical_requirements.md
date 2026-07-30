# RAAZ - Enterprise PRD Phase 6: Technical Requirements & Integration Blueprint

**Product Name:** RAAZ
**Company:** CloudExify
**Platform:** Android (Version 1)
**Future Platforms:** iOS, Web
**Frontend:** Flutter
**Backend:** Supabase

---

## 1. Technology Stack

### Objective
Define the foundational technologies to ensure a scalable, maintainable, and high-performance architecture for RAAZ across all target platforms.

### Technical Requirements
- **Recommended Flutter Version:** Flutter 3.22 (or latest stable branch) using Dart 3.x to leverage records, pattern matching, and enhanced performance.
- **Programming Language:** Dart (Frontend), SQL (Supabase Database), TypeScript (Supabase Edge Functions).
- **Backend Platform:** Supabase (managed PostgreSQL, Go/Elixir backend services).
- **Database Platform:** PostgreSQL (via Supabase) utilizing Row Level Security (RLS).
- **Authentication Strategy:** Supabase Auth (Anonymous sign-ins for V1).
- **Storage Platform:** Supabase Storage for any future media/asset hosting.
- **Notification Platform:** Firebase Cloud Messaging (FCM) integrated via Supabase Edge Functions.
- **Analytics Platform:** Google Analytics for Firebase (V1), future-proofed for Mixpanel/Amplitude.
- **Advertisement Platform:** Google AdMob (Flutter official packages).
- **Crash Reporting:** Firebase Crashlytics.
- **Future AI Integration:** Abstracted service layer prepared for OpenAI/Vertex AI integration via Edge Functions.

### Dependencies
- Dart SDK, Flutter SDK, Supabase Flutter SDK.

### Constraints
- Must remain fully compatible with Android 7.0 (API 24) and above.

### Risks
- Over-reliance on third-party SDKs increasing the app bundle size.

### Acceptance Criteria
- The project compiles successfully on the defined Flutter SDK version with zero deprecated API warnings.
- The app bundle (AAB) size remains under 30MB for the initial release.

### Future Expansion
- Transitioning edge functions to multi-region deployments for lower latency globally.

---

## 2. Application Architecture Requirements

### Objective
Establish a robust, modular frontend architecture that enforces separation of concerns, facilitating parallel development and automated testing.

### Technical Requirements
- **Architecture Pattern:** Clean Architecture combined with Feature-First folder structuring (e.g., Domain, Data, Presentation layers per feature).
- **Layer Separation:** 
  - *Presentation:* UI and State Management.
  - *Domain:* Entities and Use Cases (Business Logic).
  - *Data:* Repositories, Data Sources (Remote/Local), and DTOs.
- **Module Independence:** Features (e.g., Feed, Reflections, Settings) must not have circular dependencies and should communicate via abstract interfaces or routing arguments.
- **Feature-Based Development:** Each major epic (Daily Reflection, Letters Never Sent) must reside in its own isolated directory.
- **Dependency Rules:** Inner layers (Domain) must not depend on outer layers (Data, Presentation). Dependency Injection (DI) must be used (e.g., `get_it` or `riverpod`).
- **Reusable Components:** Core UI elements (buttons, dialogs, themes) must reside in a shared `core/ui` module.
- **Scalability Expectations:** Architecture must support adding 50+ new features without degrading compilation time or codebase navigability.

### Dependencies
- Dependency injection framework (e.g., `get_it`).

### Constraints
- Strict enforcement of SOLID principles.

### Risks
- Over-engineering the architecture for simple CRUD features leading to boilerplate fatigue.

### Acceptance Criteria
- Code review explicitly verifies that domain logic is entirely decoupled from Flutter UI widgets.

### Future Expansion
- Extracting core modules into separate Dart packages for a Monorepo setup when the Web and iOS clients are developed.

---

## 3. State Management Requirements

### Objective
Implement predictable, testable, and performant state management across the application to handle both synchronous UI changes and asynchronous data streams.

### Technical Requirements
- **Recommended State Management:** Provider, Riverpod, or BLoC. (Riverpod is highly recommended for compile-time safety and modularity).
- **State Separation:** Distinguish clearly between App State (global user identity, theme), Feature State (current feed data), and Ephemeral UI State (text field inputs, scroll positions).
- **Caching Rules:** State providers must implement time-to-live (TTL) logic to refresh stale data in the background without blocking the UI.
- **Memory Management:** State must be disposed of (e.g., `autoDispose` in Riverpod or `close` in BLoC) when navigating away from a feature to prevent memory leaks.
- **State Restoration:** Implement Flutter's `RestorationMixin` or local storage hydration to restore critical state if the OS kills the app in the background.

### Dependencies
- Selected state management package (e.g., `flutter_riverpod`, `bloc`).

### Constraints
- State must never be mutated directly; immutable state classes (e.g., using `freezed`) are mandatory.

### Risks
- Improperly scoping providers, leading to excessive widget rebuilds (jank).

### Acceptance Criteria
- Flutter DevTools confirm that only the specific widgets relying on a piece of state rebuild when that state changes.

### Future Expansion
- Optimistic UI updates across all CRUD operations to provide a zero-latency feel.

---

## 4. Navigation Requirements

### Objective
Provide a seamless, type-safe routing mechanism that handles complex deep linking and cross-platform navigation paradigms.

### Technical Requirements
- **Navigation Strategy:** Use a declarative Router API package (e.g., `go_router` or `auto_route`) over imperative `Navigator.push/pop`.
- **Deep Linking:** Define unique string paths for every major screen. Implement Android App Links to open specific posts or reflections directly from external URLs.
- **Back Navigation:** Explicitly handle hardware back button presses on Android. Ensure nested navigators do not trap the user.
- **Bottom Navigation:** Maintain state across bottom navigation tabs (e.g., Feed, Search, Profile) so users don't lose their place when switching tabs.
- **Dialog Navigation:** Treat dialogs and bottom sheets as separate routes to ensure hardware back buttons dismiss them correctly.

### Dependencies
- Declarative routing package (e.g., `go_router`).

### Constraints
- URL paths must be strictly lower-case and URL-safe.

### Risks
- Complex nested routing causing memory leaks if routes are not popped correctly.

### Acceptance Criteria
- Tapping a simulated deep link from the Android terminal successfully opens the app and navigates to the specific post detail screen.

### Future Expansion
- Web URL synchronization (browser history API integration) for the future Web client.

---

## 5. Data Management Requirements

### Objective
Ensure data availability, consistency, and low-latency access by intelligently orchestrating local caching and remote fetching.

### Technical Requirements
- **Remote Data:** All external data must be fetched asynchronously from Supabase.
- **Local Cache:** Implement a local database (e.g., `sqflite`, `hive`, or `isar`) to cache the main feed, reflections, and user settings.
- **Offline Storage:** "Letters Never Sent" and unsaved drafts must be persisted immediately to local storage.
- **Synchronization:** The Repository layer must implement a "Cache-then-Network" strategy. Serve cached data instantly, fetch from the network, and update the UI if the data changed.
- **Conflict Resolution:** For V1, "Last Write Wins" (based on server timestamp) is sufficient, as anonymous users rarely edit data concurrently from multiple devices.
- **Data Freshness:** Cache TTLs are defined per data type (e.g., Feed = 5 minutes, Settings = Infinite until changed).

### Dependencies
- Local database package (e.g., `hive_flutter` or `isar`).

### Constraints
- Local database schemas must support migrations for future app updates.

### Risks
- Stale cache leading to users seeing old data or deleted posts.
- Local database corruption on low-storage devices.

### Acceptance Criteria
- The app can be launched in Airplane mode, and the previously cached feed is displayed without throwing an exception.

### Future Expansion
- Implementation of CRDTs (Conflict-free Replicated Data Types) for offline multi-device syncing.

---

## 6. Backend Integration Requirements

### Objective
Securely and efficiently interface with Supabase to execute CRUD operations, real-time subscriptions, and authentication.

### Technical Requirements
- **Supabase Connectivity:** Initialize the Supabase client as a singleton using environment variables for URL and Anon Key.
- **Realtime Requirements:** Use Supabase Realtime (WebSockets) strictly for high-engagement screens (e.g., live support counts on trending posts) to conserve battery and connection limits.
- **Authentication Flow:** Utilize `supabase.auth.signInAnonymously()` to generate session JWTs upon first launch.
- **Storage Requirements:** (Future V2) Abstract storage calls behind an interface to allow for pre-signed URLs and secure uploads.
- **Future Edge Functions:** Define a clear API service layer to interface with Supabase Edge Functions for complex operations (e.g., automated moderation).
- **Security Expectations:** The client must NEVER bypass Row Level Security. All business logic enforcing data ownership must reside in Postgres RLS policies, not in the Flutter app.

### Dependencies
- `supabase_flutter`.

### Constraints
- All backend requests must include comprehensive error catching and timeout limits (e.g., 10 seconds).

### Risks
- WebSocket connection drops on mobile data resulting in missed events.

### Acceptance Criteria
- Supabase client successfully authenticates anonymously and retrieves a valid JWT on a clean install.

### Future Expansion
- Custom GraphQL layer via pg_graphql if REST endpoints become too complex.

---

## 7. Notification Requirements

### Objective
Implement a reliable push and local notification system to drive re-engagement without requiring user PII.

### Technical Requirements
- **Push Notifications:** Integrate FCM (Firebase Cloud Messaging) to receive remote data payloads.
- **Local Notifications:** Use `flutter_local_notifications` for scheduled reminders (e.g., Daily Reflection alerts).
- **Reminder Scheduling:** The app must register local OS alarms for user-defined reminder times, ensuring they fire even if the app is killed.
- **Future Segmentation:** The backend must map anonymous UUIDs to FCM tokens to allow for targeted broadcasting.

### Dependencies
- `firebase_messaging`, `flutter_local_notifications`.

### Constraints
- Android 13+ requires explicit runtime permission to post notifications.

### Risks
- OS-level battery optimizations (e.g., Doze mode, strict OEM background limits) killing scheduled local notifications.

### Acceptance Criteria
- User receives a local notification at the exact scheduled time for the Daily Reflection.
- App handles notification tap events and routes the user to the correct screen via deep linking.

### Future Expansion
- Rich push notifications with image attachments and inline action buttons (e.g., "Support Post").

---

## 8. Analytics Requirements

### Objective
Instrument the application to capture anonymized behavioral and performance data for product iteration.

### Technical Requirements
- **Events:** Track discrete events (e.g., `post_created`, `challenge_accepted`) via an abstract `AnalyticsService`.
- **Funnels:** Implement step-by-step event tracking for core flows to identify drop-off points (e.g., `draft_started` -> `draft_published`).
- **Retention Tracking:** Utilize standard SDK lifecycle events to track DAU/MAU securely.
- **Crash Analytics:** Automatically capture unhandled exceptions, native crashes (NDK), and non-fatal logged errors via Crashlytics.
- **Performance Analytics:** Instrument Firebase Performance SDK to track HTTP latencies and screen render times.
- **Advertisement Analytics:** Link AdMob data with Google Analytics to track ARPU (Average Revenue Per User) and ad engagement.

### Dependencies
- `firebase_analytics`, `firebase_crashlytics`, `firebase_performance`.

### Constraints
- Absolutely no raw text from user posts or PII may be attached to analytics parameters.

### Risks
- Missing key conversion events due to improper placement of tracking code.

### Acceptance Criteria
- Analytics dashboard successfully registers an anonymous event when a post is published.
- Crashlytics captures and uploads a stack trace when a forced test crash is triggered.

### Future Expansion
- Custom data warehousing in Supabase for proprietary BI reporting.

---

## 9. Advertisement Integration Requirements

### Objective
Integrate monetization smoothly without disrupting the emotional safety or user experience of the platform.

### Technical Requirements
- **Banner Ads:** Implement inline banner widgets (e.g., `AdWidget`) anchored in non-intrusive locations (e.g., bottom of Discover feed).
- **Native Ads:** Implement Native Advanced ads styled to match the app's custom UI, blended seamlessly into feed `ListViews`.
- **Interstitial Ads:** (Prohibited in V1) Architecture should support them via an abstract manager for future use.
- **Rewarded Ads:** Implement a pre-loading strategy for rewarded video ads so they play instantly upon user opt-in.
- **Loading Strategy:** Ads must load asynchronously in the background. If an ad fails to load in < 3 seconds, the UI must collapse the reserved space.
- **Frequency Rules:** Implement client-side capping logic (e.g., only request 1 native ad per 20 scrolled items).
- **Failure Behaviour:** Silent failure. The user should never see an "Ad failed to load" error message.
- **Google Play Compliance:** Implement AdMob App Set ID and adhere to Google's Families Policy data collection flags.

### Dependencies
- `google_mobile_ads`.

### Constraints
- Ads must not overlay or obscure core application content.

### Risks
- Unoptimized ad rendering causing UI jank during feed scrolling.

### Acceptance Criteria
- Test ads render correctly in development builds without causing layout shifts.
- Memory profiling shows ads are properly disposed of when scrolled off-screen.

### Future Expansion
- Direct programmatic ad bidding integrations (e.g., AppLovin MAX).

---

## 10. Offline Mode Requirements

### Objective
Ensure basic functionality and data safety when the user is in environments with poor or no network connectivity.

### Technical Requirements
- **Offline Reading:** The app must display the most recently cached feed (via local DB) when offline.
- **Offline Drafts:** All text inputs for posts or private letters must save to local storage (e.g., Hive).
- **Offline Settings:** Theme preferences, notification toggles, and language settings must remain accessible and modifiable offline.
- **Retry Strategy:** Network requests triggered offline (e.g., publishing a post) must be placed in a local persistent queue (e.g., `sqflite`) and re-attempted using exponential backoff when connectivity is restored.
- **Synchronization Policy:** Utilize a background worker (e.g., `workmanager`) to silently sync the offline queue upon network reconnection.

### Dependencies
- `connectivity_plus`, `workmanager`, local database SDK.

### Constraints
- The offline queue must have a maximum size (e.g., 50 pending actions) to prevent local storage bloat.

### Risks
- Device battery drain due to aggressive background syncing retries.

### Acceptance Criteria
- Writing a draft in Airplane mode saves it securely; reopening the app in Airplane mode retrieves the draft perfectly.

### Future Expansion
- Background Sync API integration for deep OS-level task scheduling.

---

## 11. Performance Requirements

### Objective
Meet strict performance KPIs to ensure RAAZ feels premium, lightweight, and instantaneous on Android hardware.

### Technical Requirements
- **App Startup Target:** Time to Interactive (TTI) must be < 2 seconds for cold starts. Defer non-critical initializations (e.g., Analytics, AdMob) until after the first frame renders.
- **Screen Rendering:** Target a strict 60 FPS (or 120 FPS on supported devices) for all UI transitions.
- **Scrolling Performance:** Utilize `ListView.builder` or `SliverList` extensively. Avoid deeply nested widget trees or expensive clipping operations (`ClipRRect`) inside scrolling views.
- **Memory Targets:** Peak RAM usage should not exceed 150MB. Implement memory profiling during QA to detect leaks.
- **Battery Usage:** Minimize constant location polling or background WakeLocks. Rely on FCM for updates rather than client-side polling.
- **Network Optimization:** Use HTTP/2. Enable gzip compression for Supabase API requests. Cache images heavily.

### Dependencies
- Flutter DevTools for profiling.

### Constraints
- Heavy computations (e.g., complex JSON parsing) must be offloaded to background isolates (using `compute`).

### Risks
- Animations causing raster thread bottlenecks on low-end GPUs.

### Acceptance Criteria
- The Flutter performance overlay shows no red bars (dropped frames) during a 1-minute continuous scroll test on a mid-range device.

### Future Expansion
- Pre-compiling shaders (Impeller backend) to completely eliminate early-animation jank.

---

## 12. Security Integration Requirements

### Objective
Implement enterprise-grade security protocols at the client level to protect anonymous identities and backend infrastructure.

### Technical Requirements
- **Encrypted Communication:** Enforce HTTPS/TLS 1.3 for all Supabase and third-party API traffic. Disable cleartext traffic in Android Manifest.
- **Secure Storage:** Sensitive data (Auth JWTs, Anonymous UUIDs, Drafts) must be stored in Android Keystore backed storage (e.g., `flutter_secure_storage`).
- **Input Validation:** Client-side form validation must block script tags, SQL syntax, and excessively long inputs before network transmission.
- **Spam Protection:** Integrate invisible reCAPTCHA or device attestation tokens for the post-creation API endpoint.
- **Session Security:** Implement automatic session refresh logic for JWTs to prevent unauthorized persistence.
- **Future MFA Readiness:** Abstract the authentication repository to easily inject standard multi-factor auth challenges in V2.

### Dependencies
- `flutter_secure_storage`, `crypto`.

### Constraints
- Devices with compromised hardware keystores must fallback to software encryption securely.

### Risks
- Reverse engineering of the APK revealing backend API keys (though protected by RLS, still a risk for quota exhaustion).

### Acceptance Criteria
- Code review verifies that API keys are stored in `.env` files and obfuscated during the build process, not hardcoded.
- JWTs are confirmed to be absent from standard SharedPreferences (unencrypted).

### Future Expansion
- RASP (Runtime Application Self-Protection) integration to detect jailbroken/rooted devices.

---

## 13. Logging & Monitoring Requirements

### Objective
Enable comprehensive observability to diagnose production issues swiftly without compromising user anonymity.

### Technical Requirements
- **Crash Logging:** Integrate Firebase Crashlytics to catch fatal exceptions and native crashes.
- **Performance Monitoring:** Use Firebase Performance to track HTTP request success rates, payload sizes, and durations.
- **Error Monitoring:** Implement a global Flutter error handler (`FlutterError.onError`) to route non-fatal UI exceptions to Crashlytics.
- **Security Monitoring:** Ensure backend Supabase logs capture failed authentication attempts and rate-limit triggers.
- **Operational Monitoring:** Create custom logs for critical business logic (e.g., `[INFO] SyncQueue: Successfully processed 5 offline actions`).

### Dependencies
- `logger` package for local debugging; Firebase suite for production.

### Constraints
- Absolutely no PII, user-generated text, or device identifiers may be included in the log payloads.

### Risks
- Excessive logging inflating network usage and Firebase costs.

### Acceptance Criteria
- A simulated unhandled exception in a beta build appears in the Crashlytics dashboard within 5 minutes.

### Future Expansion
- Integration with Datadog or New Relic for unified full-stack observability.

---

## 14. Third-Party Services

### Objective
Define and constrain the external dependencies required to power the RAAZ application infrastructure.

### Technical Requirements
- **Supabase:** Core backend, Database (PostgreSQL), Authentication, Edge Functions.
- **Firebase (V1):** Crashlytics, Analytics, Cloud Messaging (FCM), Performance Monitoring. (Authentication/Database explicitly NOT used).
- **Google Play Services:** Required for FCM and AdMob.
- **Google AdMob:** Monetization network.
- **Future AI Providers:** Architecture must support REST integration with OpenAI API or Google Vertex AI for sentiment analysis and automated moderation.
- **Future Email Service:** Integration with Resend or SendGrid via Supabase Edge Functions (for future premium account recovery).

### Dependencies
- Official Flutter plugins for the respective services.

### Constraints
- Minimize the number of third-party SDKs to reduce binary size and privacy compliance scope.

### Risks
- Vendor lock-in or sudden deprecation of third-party SDKs.

### Acceptance Criteria
- All third-party services are initialized successfully in the `main.dart` sequence without causing startup delays.

### Future Expansion
- Analytics migration from Firebase to an open-source alternative (e.g., PostHog) for absolute data ownership.

---

## 15. Environment Configuration

### Objective
Ensure secure, reproducible builds across different stages of the software development lifecycle.

### Technical Requirements
- **Development:** Uses local or dedicated staging Supabase project. Debug logging enabled. AdMob uses test ad unit IDs.
- **Testing:** CI/CD environment for running unit and integration tests with mocked API responses.
- **Staging:** Exact replica of the Production environment using a separate staging Supabase database. Used for QA and beta distribution.
- **Production:** Live Supabase project. Obfuscation enabled. AdMob uses live ad unit IDs. Strict analytics tracking enabled.
- **Configuration Management:** Use Dart environment variables (`--dart-define` or `flutter_dotenv`) to inject configuration at compile time.
- **Secret Management:** API keys, Supabase URLs, and keystore passwords must be managed securely via GitHub Secrets or CI/CD vault, never committed to source control.

### Dependencies
- `flutter_dotenv` or native `--dart-define-from-file`.

### Constraints
- The app must firmly reject connecting to a production database if compiled in Debug mode.

### Risks
- Accidentally shipping staging API keys in a production release.

### Acceptance Criteria
- Running `flutter run --flavor production` successfully targets the production database and initializes live SDKs.

### Future Expansion
- Integration with a remote configuration service (e.g., Firebase Remote Config) for dynamic environment variable updates.

---

## 16. Deployment Requirements

### Objective
Automate the build, testing, and release processes to ensure rapid, error-free deployments to the Google Play Store.

### Technical Requirements
- **Build Types:** Support Debug, Profile, and Release builds. Release builds must utilize code shrinking (ProGuard/R8) and obfuscation.
- **Versioning:** Semantic versioning (Major.Minor.Patch) tied to the Android `versionCode` and `versionName`.
- **Release Channels:**
  - *Internal Testing:* Daily CI builds distributed via Firebase App Distribution.
  - *Open Beta:* Release candidates distributed via Google Play Console Beta track.
  - *Production:* Final rollout to the public Google Play Store.
- **Internal Testing:** Automated CI pipeline (e.g., GitHub Actions or Codemagic) must run static analysis, unit tests, and build the APK/AAB on every PR merge.
- **Production Release:** CI pipeline generates the final signed App Bundle (.aab) and uploads it to the Google Play Console automatically.
- **Rollback Strategy:** Maintain previous stable artifacts in the CI repository. If a critical P0 bug is discovered, immediately halt the Play Store rollout and deploy the previous stable AAB with an incremented version code.

### Dependencies
- Fastlane, GitHub Actions / Codemagic, Android Keystore.

### Constraints
- All production releases must be signed with the exact same production keystore.

### Risks
- CI/CD pipeline failures delaying critical hotfixes.

### Acceptance Criteria
- Merging a PR into the `main` branch automatically triggers a successful build and deploys an APK to Firebase App Distribution.

### Future Expansion
- Automated UI testing on device farms (Firebase Test Lab) before any production deployment.

---

## 17. Future Technical Expansion

### Objective
Architect the V1 foundation to seamlessly support ambitious platform growth and new form factors over the next 12-24 months.

### Technical Requirements
- **iOS Support:** Ensure all Flutter packages used in V1 are fully iOS compatible. Avoid writing custom Android-only Kotlin code (MethodChannels) unless absolutely necessary.
- **Web Support:** Architecture must decouple local mobile storage (e.g., SQLite) from Web storage (IndexedDB) via abstract repository interfaces.
- **Tablet Support:** UI layers must use responsive grids and LayoutBuilders to support multi-pane navigation on larger screens.
- **Desktop Support:** Future-proof input handling (mouse/keyboard support, hover states) alongside touch inputs.
- **AI Assistant:** Design Edge Functions to securely interface with LLMs for real-time therapeutic feedback generation.
- **Premium Services:** Abstract the authentication layer to eventually support Stripe/Google Play Billing integration for subscriptions.
- **Enterprise APIs:** Build the backend with RESTful best practices to eventually expose B2B APIs for corporate wellness dashboards.

### Dependencies
- N/A (Strategic architectural foresight).

### Constraints
- Do not bloat V1 with unnecessary abstractions for platforms that are not actively in development.

### Risks
- Flutter web performance (CanvasKit) creating a subpar experience if not optimized for early.

### Acceptance Criteria
- V1 codebase requires minimal refactoring (only UI responsive tweaks) to compile and run on an iOS simulator.

### Future Expansion
- Smart watch (Wear OS / watchOS) companion apps for quick mood logging.

---
*End of Document*
