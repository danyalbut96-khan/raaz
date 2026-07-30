# RAAZ - Enterprise PRD Phase 5: Business Rules, Moderation & Policies

**Product Name:** RAAZ
**Company:** CloudExify
**Platform:** Android (Future: iOS, Web)
**Frontend:** Flutter
**Backend:** Supabase

---

## 1. Anonymous Identity Rules

### Objective
Provide a robust, secure, and privacy-preserving anonymous identity system that allows users to engage freely without compromising their real-world identity.

### Business Rules
- **Device-based anonymous identity:** Identities must be tied to a securely generated unique device identifier (e.g., UUID mapped to Android Keystore), completely disassociated from email, phone numbers, or social logins for Version 1.
- **Anonymous display names:** Users are assigned randomized or system-generated anonymous display names (e.g., "Silent Echo"). Users cannot type custom display names to prevent PII leakage.
- **Anonymous avatars:** Avatars are restricted to a pre-defined set of vector graphics or algorithmic patterns (e.g., Identicons) provided by the system. Custom image uploads for avatars are strictly prohibited.
- **Identity persistence:** The anonymous identity persists locally on the device across app sessions unless the app data is cleared or the user requests a reset.
- **Identity reset policy:** Users can manually trigger a "Reset Identity" action, which permanently deprecates the current identity and generates a new one. Old posts become completely orphaned from the user's active session.
- **Future account linking strategy:** Architecture must support future opt-in linking to abstract authentication methods (e.g., passkeys or zero-knowledge proofs) for cross-device syncing without revealing PII.

### Validation Rules
- The system must verify the device UUID is correctly formatted and unique within the backend database.
- Avatar selections must validate against the strict whitelist of approved asset IDs.

### Exceptions
- N/A - Identity generation is mandatory for interaction.

### Failure Behaviour
- If device identity generation fails (e.g., Keystore error), the user is gracefully downgraded to a read-only Guest User and informed of the limitation.

### User Notifications
- Inform users clearly upon first launch: "Your identity is hidden. No personal data is collected."
- Warning prompt upon "Reset Identity" confirming that past interactions will no longer be editable or linked to them.

### Administrative Controls
- Admins can globally ban a specific device ID if severe abuse is detected, revoking all privileges for that identity.

### Future Expansion
- Implementation of cross-device anonymous syncing using cryptographic recovery phrases (similar to crypto wallets).

---

## 2. Guest User Rules

### Objective
Allow new users to experience the core value proposition of RAAZ with zero friction before committing to generating an anonymous identity.

### Business Rules
- **Guest capabilities:** Guest users can read the public feed, view comments, and search content.
- **Guest limitations:** Guest users cannot create posts, comment, support/like posts, participate in challenges, or bookmark content.
- **Local preferences:** Guest users can set local preferences (e.g., Dark Mode) which persist via local storage (e.g., SharedPreferences).
- **Local draft storage:** Guest users cannot save drafts, as drafting requires an established anonymous session.
- **Future account migration:** Guest users who opt to participate will instantly transition to an Anonymous Identity without losing local session context (e.g., scroll position).

### Validation Rules
- Backend APIs must validate the presence of a valid Anonymous Identity JWT; Guest requests lacking this token are rejected for all write operations.

### Exceptions
- Reading public content is explicitly permitted without authentication tokens.

### Failure Behaviour
- Attempting a write action as a guest triggers an unobtrusive prompt to "Join Anonymously to Participate."

### User Notifications
- A subtle persistent banner for guests: "You are browsing anonymously. Tap here to join the conversation."

### Administrative Controls
- Admins can enforce global read-only mode, essentially treating all users as guests during major database migrations.

### Future Expansion
- Allow guest users to bookmark items locally before migrating to a full anonymous identity.

---

## 3. Post Creation Rules

### Objective
Govern the creation of user-generated content to maintain high quality, prevent spam, and enforce platform safety standards.

### Business Rules
- **Minimum and maximum character limits:** Posts must contain a minimum of 10 characters and a maximum of 2,000 characters.
- **Supported categories:** Every post must be assigned to exactly one predefined category (e.g., Confessions, Advice, Venting).
- **Mood selection:** Users can optionally append a single mood tag (e.g., 🌧️ Sad, 🔥 Angry, 🧘 Calm) to their post.
- **Templates:** The system provides predefined text templates (e.g., "I wish I could tell them...") to lower the barrier to entry.
- **Draft behaviour:** Users can save up to 10 unsubmitted posts locally. Drafts are never synced to the cloud.
- **Publishing validation:** Posts undergo local sanitization and cloud-based automated moderation before becoming publicly visible.
- **Rate limiting:** Users are restricted to creating a maximum of 3 posts per hour and 10 posts per day.
- **Duplicate prevention:** Exact string matches of previously submitted posts by the same user within 24 hours are blocked.

### Validation Rules
- Character count validation must strip leading/trailing whitespace before calculation.
- Category IDs must match the backend active category enum.

### Exceptions
- Rate limits do not apply to saving local drafts.

### Failure Behaviour
- If publishing fails due to network issues, the post is automatically saved as a draft with a retry prompt.
- If rejected by moderation, the user receives an ambiguous error to prevent reverse-engineering of the filter.

### User Notifications
- Toast notification: "Draft saved securely on your device."
- SnackBar: "Post published anonymously."

### Administrative Controls
- Admins can dynamically update the list of active Categories and Moods without an app update.
- Admins can throttle global post creation rates during spam attacks.

### Future Expansion
- Image/audio uploads with strict algorithmic blurring/voice-distortion for absolute anonymity.

---

## 4. Community Interaction Rules

### Objective
Foster a supportive, engaging, and safe environment for users to interact with each other's content.

### Business Rules
- **Comments:** Anonymous users can comment on active posts. Comments are limited to 500 characters.
- **Replies:** Users can reply to specific comments (1-level deep threading only to maintain simplicity).
- **Support reactions:** Users can tap a "Support" button (equivalent to a Like/Upvote) once per post/comment.
- **Bookmarks:** Users can save posts to a private, locally stored "Bookmarks" list.
- **Sharing:** Users can generate an anonymous text snapshot or deep link to share posts outside the app (stripping all app metadata).
- **Reporting:** Every post and comment must have a highly visible "Report" button.
- **Positive community behaviour:** Posts with high support-to-view ratios are prioritized in the trending feed.
- **Anti-spam behaviour:** Identical comments posted across multiple threads by the same user within 5 minutes trigger a shadowban on commenting for 24 hours.

### Validation Rules
- Users cannot support their own posts/comments.
- Comments must pass the same profanity/abuse filters as posts.

### Exceptions
- Bookmarking is allowed even if the user is offline (syncs when online).

### Failure Behaviour
- If a comment fails to post, the text remains in the input field so the user does not lose their work.

### User Notifications
- "You've sent support!" (Appears when reacting to a post).
- Push notification (if enabled) when a user's post receives a comment.

### Administrative Controls
- Admins can lock a post, preventing new comments while retaining existing ones.

### Future Expansion
- Richer reaction types (e.g., Hug, Relate, Listen).

---

## 5. Daily Reflection Rules

### Objective
Drive daily engagement and user retention through curated, community-wide prompt exercises.

### Business Rules
- **Publishing schedule:** A new Daily Reflection prompt is published automatically at 00:00 UTC every day.
- **Visibility:** The active Daily Reflection is pinned to the top of the main feed for all users.
- **Participation rules:** Users can submit only one answer per Daily Reflection. Answers cannot be edited once submitted.
- **Community answers:** Answers are displayed in a dedicated randomized feed associated with the prompt to prevent early-responder bias.
- **Moderation:** Reflection answers are subject to the strictest tier of automated moderation due to high visibility.
- **Archive policy:** After 24 hours, the reflection moves to the Archive, where past prompts and answers are read-only.

### Validation Rules
- Answers must be between 5 and 500 characters.

### Exceptions
- Users can delete their own answer, but cannot submit a replacement.

### Failure Behaviour
- If the backend fails to fetch the new daily reflection, the app falls back to a locally cached default prompt.

### User Notifications
- Local push notification at a user-defined time: "Today's reflection is waiting for you."

### Administrative Controls
- Admins can queue up to 30 days of Daily Reflections in the backend CMS.
- Admins can manually override and replace the active reflection in real-time.

### Future Expansion
- Thematic week-long reflection series (e.g., "Mental Health Awareness Week").

---

## 6. Daily Challenge Rules

### Objective
Encourage positive offline behaviors and mental well-being through actionable community tasks.

### Business Rules
- **Challenge lifecycle:** Challenges are published daily (e.g., "Compliment a stranger today"). They last for 24 hours.
- **Participation rules:** Users opt-in by tapping "Accept Challenge".
- **Completion rules:** Users mark the challenge as completed by tapping "I did it". No proof is required; relies on the honor system.
- **Future reward strategy:** Challenges build a local "Streak" counter, but do not offer public badges in Version 1 to prevent gamification of mental health.

### Validation Rules
- Users cannot mark a challenge complete without first accepting it.

### Exceptions
- N/A

### Failure Behaviour
- Offline acceptances are queued locally and synced when the device reconnects.

### User Notifications
- Reminder notification 12 hours after accepting if not marked complete: "How is today's challenge going?"

### Administrative Controls
- Admins define the pool of challenges and the randomization logic in the backend.

### Future Expansion
- Unlockable anonymous avatar accessories based on challenge streaks.

---

## 7. Letters Never Sent Rules

### Objective
Provide a dedicated, highly private space for therapeutic journaling and processing unresolved emotions.

### Business Rules
- **Privacy expectations:** By default, "Letters Never Sent" are completely private and stored only on the local device.
- **Publishing rules:** Users have the option to "Release into the void" (publish anonymously to a dedicated public feed). Once released, it cannot be undone.
- **Saving drafts:** Letters auto-save to local storage every 30 seconds while typing.
- **Editing:** Private letters can be edited indefinitely. Publicly released letters cannot be edited.
- **Deletion:** Users can delete private letters locally. Users can delete their public letters, which removes them from the backend.
- **Community visibility:** Released letters appear in a specific, un-commentable feed designed purely for reading and passive support (no replies allowed).

### Validation Rules
- Released letters must pass automated moderation to ensure they do not contain self-harm or violent threats.

### Exceptions
- Letters containing restricted keywords trigger an intercept providing mental health hotline resources rather than publishing.

### Failure Behaviour
- If "Release into the void" fails due to connectivity, the letter remains safely stored as a private draft.

### User Notifications
- Interstitial prompt upon releasing: "Once released, this letter becomes part of the public void. Are you sure?"

### Administrative Controls
- Admins monitor the "Void" feed with automated sentiment analysis to detect macro-trends in community distress.

### Future Expansion
- End-to-end encrypted cloud backup for private letters.

---

## 8. Content Moderation Rules

### Objective
Ensure RAAZ remains a safe, legal, and non-toxic environment, protecting users from harm while respecting anonymous expression.

### Business Rules
- **Prohibited content:** Hate speech, targeted harassment, self-harm promotion, doxxing, and explicit sexual content are strictly banned.
- **Abusive language:** A dynamic, backend-managed dictionary of profanity and slurs automatically blocks or obfuscates offending text.
- **Harassment:** Repeated targeted replies containing negative sentiment toward a single anonymous ID trigger automatic review.
- **Bullying:** Peer-to-peer bullying is prohibited and will result in post removal.
- **Threats:** Threats of real-world violence trigger immediate account shadowbanning and content removal.
- **Illegal content:** Any content violating local or international laws (e.g., terrorism, CSAM) is permanently purged and reported to authorities if applicable (though anonymous).
- **Adult content:** Strictly prohibited. Text-based erotica or highly explicit descriptions will be blocked.
- **Sensitive topics:** Discussions of self-harm or suicide trigger an automated overlay with crisis support resources and hide the post from the general feed.
- **Misinformation handling:** Not heavily policed in Version 1 due to the emotional/confessional nature of the app, unless it relates to urgent public safety.
- **Moderator escalation:** Automated flags that lack high confidence are routed to a human Trust & Safety queue.
- **Appeal process (future):** Version 1 does not support appeals due to absolute anonymity. Future versions may allow token-based anonymous appeals.

### Validation Rules
- All text submissions must pass through a RegEx filter and an AI sentiment/toxicity analysis API (e.g., Google Perspective API) before database insertion.

### Exceptions
- Nuanced venting that contains strong language but is not directed at individuals may bypass standard profanity filters if categorized under "Venting."

### Failure Behaviour
- If the moderation API is down, the system defaults to strict RegEx filtering and queues the post for retrospective AI review.

### User Notifications
- Warning: "Your post contains language that violates our community guidelines. Please revise."
- Support: "You are not alone. If you need help, please contact [Crisis Line]."

### Administrative Controls
- Admins can instantly purge content, shadowban devices, and update the banned word list in real-time.

### Future Expansion
- Automated community moderation (e.g., a "Jury" system of high-reputation anonymous users).

---

## 9. Report Handling Rules

### Objective
Provide an efficient, SLA-driven workflow for handling user-generated reports to maintain community trust.

### Business Rules
- **Report reasons:** Users must select a reason: Hate Speech, Harassment, Self-Harm, Spam, or Illegal Content.
- **Priority levels:** 
  - *P0 (Critical):* Self-Harm, Illegal Content, Threats (Reviewed < 1 hour).
  - *P1 (High):* Hate Speech, Harassment (Reviewed < 12 hours).
  - *P2 (Low):* Spam, Off-topic (Reviewed < 24 hours).
- **Review workflow:** Reports enter a Supabase queue. 3+ unique user reports on a single item automatically hide it pending manual review.
- **Resolution states:** Reports are marked as Approved (content removed, user warned/banned) or Rejected (content restored).
- **False reporting policy:** Users who submit >5 rejected reports in 48 hours lose their reporting privileges for 7 days.

### Validation Rules
- Users cannot report the same piece of content more than once.

### Exceptions
- Content flagged by the automated AI system bypasses the 3-user threshold and enters the queue immediately.

### Failure Behaviour
- If the reporting endpoint fails, the app locally caches the report and retries silently in the background.

### User Notifications
- "Thank you. Your report has been submitted for review." (No follow-up notifications are sent to protect anonymity).

### Administrative Controls
- Admins utilize a dedicated web dashboard to view reported content alongside the reporter's trust score and historical context.

### Future Expansion
- Automated report resolution based on historical ML training data.

---

## 10. Notification Rules

### Objective
Re-engage users efficiently without becoming intrusive or contributing to digital fatigue.

### Business Rules
- **Reflection reminders:** Daily local push notification for the new Reflection (default: 09:00 AM local time).
- **Challenge reminders:** Local push notification for accepted challenges.
- **Replies:** Remote FCM push notification when a user receives a direct reply to their comment.
- **Support received:** Remote push notification batched hourly (e.g., "Your post received 5 new supports").
- **Announcements:** Remote push notifications for critical app updates or community milestones.
- **System notifications:** In-app only notifications for moderation warnings or shadowban notices.
- **Notification frequency:** Users receive a maximum of 3 remote push notifications per 24 hours.
- **User controls:** Users can toggle individual notification categories ON/OFF in the Settings menu.

### Validation Rules
- Notification payloads must not contain PII or the raw text of sensitive replies on the lock screen (e.g., display "Someone replied to your post" instead of the message content).

### Exceptions
- System/Admin announcements bypass the 3-per-day frequency limit.

### Failure Behaviour
- If FCM token registration fails, the app falls back to an in-app badge notification system.

### User Notifications
- Standard OS-level permission prompts for push notifications during onboarding.

### Administrative Controls
- Admins can broadcast targeted segments (e.g., "All Android Users") via the backend FCM integration.

### Future Expansion
- Smart delivery times based on the user's historical engagement patterns.

---

## 11. Search Rules

### Objective
Allow users to easily discover relevant topics, specific emotions, or shared experiences within the anonymous community.

### Business Rules
- **Ranking:** Search results prioritize exact keyword matches, followed by post support volume, and recency.
- **Filtering:** Users can filter search results by Category, Mood, and Timeframe (e.g., Past 24h, Past Week).
- **Trending:** The search landing page displays the top 5 trending keywords updated hourly.
- **Recent:** The app stores the last 5 search queries locally on the device.
- **Category search:** Tapping a Category chip initiates a predefined search for all posts in that category.
- **No-result behaviour:** If no posts match, display a highly empathetic empty state (e.g., "Be the first to share your thoughts on this.").

### Validation Rules
- Search queries are limited to 50 characters to prevent database abuse.
- Search queries are stripped of special characters and SQL injection attempts.

### Exceptions
- The "Letters Never Sent" private feed is strictly excluded from all search indexing.

### Failure Behaviour
- If the search database (e.g., Algolia or Postgres Full Text) is unreachable, display a "Search is currently resting" graceful error.

### User Notifications
- N/A

### Administrative Controls
- Admins can pin specific topics or resources to the top of search results for specific keywords (e.g., searching "depressed" pins mental health resources).

### Future Expansion
- Semantic/vector search utilizing AI embeddings to find conceptually similar posts without exact keyword matches.

---

## 12. AdMob Rules

### Objective
Monetize the platform sustainably while rigorously protecting the user experience and maintaining the app's emotional safety.

### Business Rules
- **Banner placement policy:** Small, non-intrusive banners may appear at the bottom of the Discover feed. Banners are never placed inside the "Letters Never Sent" or "Daily Reflection" views.
- **Native ad placement policy:** Native ads may be injected into the main feed at a fixed interval (e.g., every 15th post), styled to clearly indicate they are sponsored.
- **Interstitial trigger policy:** Interstitial (full-screen) ads are STRICTLY PROHIBITED in Version 1 to prevent jarring disruptions during emotional reading.
- **Rewarded ad policy:** Users may optionally watch a rewarded video ad to unlock a cosmetic feature (e.g., a special temporary avatar frame).
- **Maximum ad frequency:** Users will see a maximum of 1 native ad per session and banner ads rotate every 60 seconds.
- **User experience protection:** Ads related to dating, weight loss, gambling, or politics are strictly blocked at the AdMob network level to preserve the app's safe space environment.
- **Google Play compliance:** Ads must comply with Google Play's Families Policy and general monetization guidelines.

### Validation Rules
- The app must initialize the AdMob SDK only after explicit user consent is granted regarding tracking (if applicable).

### Exceptions
- Premium users (future) are entirely exempt from all ad placements.

### Failure Behaviour
- If ad inventory fails to load, the UI collapses the ad container gracefully without leaving a blank space.

### User Notifications
- Ad labels must be prominent (e.g., "Sponsored" or "Ad").

### Administrative Controls
- Admins can remotely toggle AdMob IDs or disable ads entirely via backend feature flags in case of a rogue ad campaign.

### Future Expansion
- Direct native sponsorships from mental wellness brands.

---

## 13. Privacy Rules

### Objective
Operationalize the principle of privacy-by-design, ensuring RAAZ collects the absolute minimum data required to function.

### Business Rules
- **Minimal data collection:** The app explicitly does not request Contacts, Location, Camera, or Microphone permissions in Version 1.
- **Anonymous-first policy:** IP addresses are hashed and salted before logging; raw IPs are never stored in the primary database.
- **Local storage usage:** Highly sensitive data (drafts, private letters, bookmarks) are stored exclusively in local encrypted databases (e.g., Hive AES-256).
- **Cloud storage usage:** Only data intended for public consumption (Posts, Comments, Support counts) is synced to Supabase.
- **Data deletion:** The "Delete My Data" function immediately drops the user's UUID record and cascades deletion to all associated cloud data.
- **Consent requirements:** Clear, non-technical consent forms must be accepted before any crash reporting or analytics telemetry is transmitted.

### Validation Rules
- Backend database schemas must strictly lack columns for Email, Name, or Phone Number for the core user table.

### Exceptions
- Temporary server logs may hold raw IPs for up to 7 days purely for DDoS mitigation and security auditing, after which they are purged.

### Failure Behaviour
- If encrypted local storage fails to initialize, the app terminates to prevent storing unencrypted drafts.

### User Notifications
- A dedicated "Privacy Snapshot" screen in Settings summarizing exactly what data is stored locally vs. in the cloud.

### Administrative Controls
- Admins have no technical mechanism to trace a specific public post back to a specific physical device or IP address.

### Future Expansion
- Implementation of Zero-Knowledge proofs for verifying age without revealing identity.

---

## 14. Security Rules

### Objective
Defend the platform's infrastructure and the community against automated attacks, spam, and malicious exploitation.

### Business Rules
- **Session protection:** JWT tokens have a strict 1-hour expiration. Refresh tokens are rotated upon every use.
- **Input validation:** All client-side input is treated as untrusted. Supabase Edge Functions sanitize HTML/JS tags before database insertion.
- **Spam protection:** Account creation velocity is monitored. >10 accounts created from the same IP subnet within 1 hour triggers a temporary IP ban.
- **Abuse prevention:** Users rapidly tapping the "Support" button will have their actions debounced on the client and rate-limited on the server.
- **Rate limiting:** API endpoints strictly limit requests (e.g., 60 requests per minute per UUID for read operations; 10 for write operations).
- **Future verification:** Architecture must support future device attestation (e.g., Google Play Integrity API) to block emulated/rooted devices from writing to the database.

### Validation Rules
- Supabase Row Level Security (RLS) ensures `user_uuid` matches the JWT `sub` claim for all update/delete operations.

### Exceptions
- Read-only endpoints for the trending feed have higher rate limits to accommodate heavy traffic.

### Failure Behaviour
- Rate-limited users receive an HTTP 429 status and a polite UI message: "You're doing that too fast. Take a breath and try again."

### User Notifications
- "Session expired. Reconnecting securely..."

### Administrative Controls
- Admins can instantly revoke all active JWTs (forcing global re-authentication) in the event of a suspected security breach.

### Future Expansion
- Integration of advanced bot mitigation networks (e.g., Cloudflare Turnstile).

---

## 15. Analytics Rules

### Objective
Capture essential product usage metrics to guide product iteration without violating the core tenet of user anonymity.

### Business Rules
- **Events to track:** App Open, Screen View, Post Created, Comment Created, Support Given, Challenge Accepted, Ad Click.
- **Anonymous analytics:** All analytics events are tied to a rotating Session ID, NOT the persistent device UUID. Events cannot be stitched together across different days to profile a user.
- **Performance metrics:** Track API latencies, crash stack traces, and rendering times.
- **Retention metrics:** Track generic cohort retention (e.g., "100 users joined Monday, 40 returned Tuesday") without tracking *which* specific users returned.
- **Community metrics:** Aggregate data on most popular categories, highest-grossing moods, and peak traffic hours.
- **Ad performance metrics:** Track ad impressions, clicks, and eCPM compliantly via AdMob SDK.

### Validation Rules
- Telemetry payloads are strictly audited via CI/CD pipelines to ensure no text payload (e.g., post content, search terms) is accidentally included in analytics events.

### Exceptions
- Opt-out users generate zero analytics events; their actions are completely invisible to telemetry.

### Failure Behaviour
- Analytics calls are "fire-and-forget" and must never block UI rendering or core app functionality if the analytics server is down.

### User Notifications
- A clear opt-in/opt-out toggle for "Help Improve RAAZ" in the Settings menu.

### Administrative Controls
- Product Managers access analytics via aggregated dashboards (e.g., Google Analytics 4 / Mixpanel); raw event streams are obfuscated.

### Future Expansion
- A/B testing framework utilizing anonymous cohort bucketing.

---

## 16. Business Policies

### Objective
Outline the commercial and strategic rules governing the rollout, growth, and eventual monetization of RAAZ.

### Business Rules
- **Version 1 limitations:** V1 focuses strictly on core loops (Posting, Reading, Supporting). No complex features like direct messaging or image sharing will be included.
- **Future premium strategy:** RAAZ will remain fundamentally free. Future monetization may include "RAAZ Plus" for cosmetic features (custom app icons, exclusive avatar themes, extended draft limits).
- **Future subscription policy:** Subscriptions will be handled entirely via Google Play Billing. No external payment processors will be used to ensure trust.
- **Feature rollout strategy:** Features will be deployed using a phased rollout approach (e.g., 10% of users -> 50% -> 100%) to monitor stability.
- **Community growth strategy:** V1 growth will rely on organic word-of-mouth and the "Anonymous Share" feature, prioritizing a high-quality community over rapid, unmoderated virality.

### Validation Rules
- N/A

### Exceptions
- Critical security patches bypass phased rollouts and are deployed to 100% immediately.

### Failure Behaviour
- N/A

### User Notifications
- Subtle in-app announcements for major new features.

### Administrative Controls
- Business stakeholders govern feature flags and rollout percentages via the backend config.

### Future Expansion
- B2B partnerships offering white-labeled anonymous feedback spaces for corporate wellness programs.

---

## 17. Operational Policies

### Objective
Define the internal procedures for maintaining the application, handling incidents, and managing the product lifecycle.

### Business Rules
- **Maintenance mode:** The system must support a remote toggle to place the app in "Maintenance Mode," disabling write actions while preserving read access if possible, or displaying a friendly blockade screen.
- **Incident handling:** Any P0 issue (e.g., database outage, moderation failure allowing illegal content) triggers an immediate paging of the on-call engineering team with a 15-minute response SLA.
- **Bug reporting:** Users can shake their device (or use a settings menu option) to submit an anonymous bug report containing basic device OS metadata.
- **Feature flags:** All new major UI components and backend integrations must be wrapped in feature flags (e.g., using Supabase Remote Config) for rapid rollback without app store reviews.
- **Version compatibility:** The backend must support the current app version and the two immediately preceding major versions.
- **Deprecation policy:** Users on unsupported, deprecated versions will receive a hard block screen forcing them to update via the Google Play Store.

### Validation Rules
- Client apps must pass their `app_version` in API headers for compatibility checking.

### Exceptions
- Emergency hotfixes may temporarily break backward compatibility if they address a critical vulnerability.

### Failure Behaviour
- If the feature flag endpoint is down, the app defaults to the safest known configuration (usually turning new features OFF).

### User Notifications
- "RAAZ is taking a brief rest for maintenance. We'll be back shortly."
- "A new version of RAAZ is required to continue. Please update."

### Administrative Controls
- Dev/Ops teams have a centralized dashboard to toggle feature flags, enter maintenance mode, and set minimum required app versions.

### Future Expansion
- Automated canary deployments based on real-time error rate monitoring.

---
*End of Document*
