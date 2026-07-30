# ENTERPRISE PRODUCT REQUIREMENTS DOCUMENT (PRD)
## PHASE 3: FUNCTIONAL REQUIREMENTS

**Product Name:** RAAZ  
**Company:** CloudExify  
**Target Platform:** Android (Version 1)  
**Backend:** Supabase  
**Frontend:** Flutter  
**State Management:** BLoC  
**Document Version:** 3.0.0  
**Date:** July 14, 2026  

---

## Document Schema Definition

To ensure absolute rigor and avoid ambiguity, every feature in this document is specified using the following schema:

* **Feature Overview:** High-level summary of the functional capability.
* **Purpose:** The business or user objective this feature fulfills.
* **Description:** Detailed explanation of what the feature does.
* **Actors:** The users or systems initiating or interacting with the feature.
* **Preconditions:** System states or user permissions required before execution.
* **Trigger:** The action or event that initiates the feature.
* **Inputs:** Data, files, tokens, or configuration items supplied.
* **Outputs:** Data changes, screen transitions, state updates, or logs emitted.
* **Functional Behaviour:** Step-by-step description of system execution.
* **Validation Rules:** Cryptographic, length, formatting, or lexical checks.
* **Business Rules:** Policy logic, limits, rates, or moderation rules.
* **Success Scenario:** Step-by-step description of the happy path.
* **Alternative Scenarios:** Valid secondary pathways or user decisions.
* **Failure Scenarios:** Step-by-step resolution of network, system, or input failures.
* **Edge Cases:** Behavior under extreme conditions (e.g., database concurrency, storage limits).
* **User Feedback:** Toasts, banners, dialogs, or sounds presented to the user.
* **Logging Requirements:** Log levels, message formats, and sensitive data sanitization details.
* **Analytics Events:** Event names and custom parameter sets recorded.
* **Future Roadmap:** Multi-version scope mapping (V1 Support, Exclusions, V2 Plans, V3 Plans).

---

## 1. Splash Screen

* **Feature Overview:** Initial application startup screen.
* **Purpose:** Initializes application state, checks configuration, and routes the user.
* **Description:** Displays the RAAZ logo while verifying connection and credentials in the background.
* **Actors:** System, User.
* **Preconditions:** Application process is launched.
* **Trigger:** User taps the application icon on Android.
* **Inputs:** Local SharedPreferences configuration flags, Secure Keystore credentials.
* **Outputs:** Navigation routing command (to Onboarding or Home Feed), initialized local database.
* **Functional Behaviour:** 
  1. Bootstraps the Flutter environment.
  2. Queries the Secure Keystore for user credentials.
  3. Checks local storage for onboarding completion flags.
  4. Resolves navigation paths based on configuration parameters.
* **Validation Rules:** Keystore tokens must be structurally valid UUID strings.
* **Business Rules:** The splash screen must remain visible for a minimum of 1.5 seconds to ensure brand exposure.
* **Success Scenario:** Application boots, validates the token, and navigates to the Home Feed in under 2.5 seconds.
* **Alternative Scenarios:** First-time launch navigates to Onboarding instead of the Home Feed.
* **Failure Scenarios:** Keystore read errors fallback to token regeneration, routing the user to the onboarding flow.
* **Edge Cases:** Launch during low memory conditions must prevent background tasks from crashing the initialization process.
* **User Feedback:** Animated logo presentation.
* **Logging Requirements:** Info logs for initialization timings; Error logs for keystore access issues.
* **Analytics Events:** `app_open` (Parameters: `is_first_launch` boolean).
* **Future Roadmap:**
  * **Version 1:** Basic animated logo, static routing logic.
  * **Exclusions:** Dynamic remote-config driven assets.
  * **Version 2:** Remote-config assets, A/B routing paths.
  * **Version 3:** Background sync pre-fetching during launch.

---

## 2. Onboarding

* **Feature Overview:** Explains core platform values to new users.
* **Purpose:** Sets user expectations regarding anonymity and safety rules.
* **Description:** A swipeable carousel outlining platform features and the community agreement.
* **Actors:** Guest User.
* **Preconditions:** Splash screen completes, and no valid token is found in the Keystore.
* **Trigger:** System detects a first-time launch state.
* **Inputs:** Swipe gestures, tap actions.
* **Outputs:** `onboarding_completed = true` flag stored in local preferences.
* **Functional Behaviour:**
  1. Displays three carousel slides explaining features.
  2. Presents the final slides detailing safety regulations.
  3. Enables the "Agree & Enter" action only after the user reaches the final slide.
* **Validation Rules:** Swipe gestures must register a threshold of 100dp delta to trigger page transitions.
* **Business Rules:** The user must explicitly view the safety regulations slide before entering the platform.
* **Success Scenario:** User views slides, taps agree, and the system saves the onboarding flag and routes to the feed.
* **Alternative Scenarios:** User taps "Import Key" to restore a backup instead of proceeding with onboarding.
* **Failure Scenarios:** SharedPreferences write failure prompts a fallback retry dialog: *"Unable to save settings."*
* **Edge Cases:** Swift, rapid swiping must not cause layout overflow or navigation overlaps.
* **User Feedback:** Active indicator dots, disabled buttons enabled on the final slide.
* **Logging Requirements:** Info logs for onboarding navigation transitions.
* **Analytics Events:** `onboarding_viewed` (Parameters: `slide_index` int), `onboarding_complete`.
* **Future Roadmap:**
  * **Version 1:** Three slides, static terms layout.
  * **Exclusions:** Interactive video tutorials.
  * **Version 2:** Animated illustrations, localization updates.
  * **Version 3:** Interactive guided walkthrough of the workspace interface.

---

## 3. Guest Authentication

* **Feature Overview:** Secure anonymous account creation.
* **Purpose:** Authenticates requests with the backend without requesting PII.
* **Description:** Generates cryptographic credentials stored locally in the Android Secure Keystore.
* **Actors:** System, Supabase.
* **Preconditions:** Onboarding slides are accepted.
* **Trigger:** User taps "Agree & Enter" on onboarding.
* **Inputs:** Cryptographic random entropy from Android Secure Random generator.
* **Outputs:** Cryptographic private token stored in the Keystore, public token stored in Supabase Auth.
* **Functional Behaviour:**
  1. Generates a secure authentication key on the device.
  2. Registers the public credentials with the Supabase anonymous auth database.
  3. Receives session validation headers.
* **Validation Rules:** Secure keys must be generated using AES-256 GCM algorithms.
* **Business Rules:** A guest account cannot be linked to emails, phone numbers, or social credentials in V1.
* **Success Scenario:** Key is generated, synced with the backend, and saved in under 800ms.
* **Alternative Scenarios:** User imports a previously exported key file to restore their session.
* **Failure Scenarios:** Keystore access failure alerts the user to update their Google Play security services.
* **Edge Cases:** If a device is rooted, auth calls must check device integrity parameters before registering.
* **User Feedback:** Loading indicator during key registration.
* **Logging Requirements:** Secure logs with sanitized credentials; warnings for root detection alerts.
* **Analytics Events:** `guest_auth_created`, `guest_auth_failed` (Parameters: `error_code` string).
* **Future Roadmap:**
  * **Version 1:** Local Keystore auth, Supabase integration.
  * **Exclusions:** Multi-device sync, third-party authentication.
  * **Version 2:** Encrypted recovery file export/import support.
  * **Version 3:** Zero-knowledge identity backup protocols.

---

## 4. Home Feed

* **Feature Overview:** Chronological text post feed.
* **Purpose:** Facilitates content discovery and reading.
* **Description:** Displays anonymous posts from the community with filter controls.
* **Actors:** Guest User, Supabase.
* **Preconditions:** Authenticated session active.
* **Trigger:** User opens the app or pulls to refresh the feed.
* **Inputs:** Scroll position, pull-to-refresh swipe.
* **Outputs:** List of posts, updated cache tables.
* **Functional Behaviour:**
  1. Fetches first page of posts from Supabase database.
  2. Updates SQLite local tables with new posts.
  3. Displays posts in chronological order.
* **Validation Rules:** Post text body must contain valid Unicode characters.
* **Business Rules:** Posts must display ephemeral, rotating pseudonyms instead of persistent names.
* **Success Scenario:** Feed fetches, caches, and renders posts in under 500ms.
* **Alternative Scenarios:** Offline mode fallback loads content entirely from the local SQLite cache.
* **Failure Scenarios:** Supabase access timeout falls back to local cache and displays a network warning banner.
* **Edge Cases:** Fast scrolling down a feed with a slow connection must render placeholder skeletons.
* **User Feedback:** Skeletal loaders, pull-to-refresh animations.
* **Logging Requirements:** Warning logs for pagination fetch timeouts.
* **Analytics Events:** `feed_fetch_success` (Parameters: `post_count` int), `feed_fetch_failed`.
* **Future Roadmap:**
  * **Version 1:** Chronological feed, pull-to-refresh, skeleton screens.
  * **Exclusions:** Algorithmic recommendation engine.
  * **Version 2:** Category sorting tabs, bookmarks feed integration.
  * **Version 3:** Local NLP relevance sorting.

---

## 5. Featured Stories

* **Feature Overview:** Curated high-empathy posts.
* **Purpose:** Highlights positive community interactions.
* **Description:** A horizontal banner at the top of the feed featuring highly-rated support posts.
* **Actors:** Guest User, Moderator Admin.
* **Preconditions:** Authenticated session active.
* **Trigger:** Home Feed initializes.
* **Inputs:** Moderation approval flag in Supabase DB.
* **Outputs:** Rendered featured stories.
* **Functional Behaviour:**
  1. Queries the database for posts flagged as `is_featured = true`.
  2. Updates local tables.
  3. Displays posts in a carousel on the Home Feed.
* **Validation Rules:** Featured posts must meet safety guidelines.
* **Business Rules:** Posts can only be featured by moderators. A post is featured for a maximum of 48 hours.
* **Success Scenario:** Featured stories are successfully retrieved and displayed on the Home Feed carousel.
* **Alternative Scenarios:** If no posts are flagged as featured, the carousel is hidden.
* **Failure Scenarios:** Database timeout leaves the carousel hidden, displaying only the main feed.
* **Edge Cases:** A featured post deleted by its author must be removed from the carousel instantly.
* **User Feedback:** Horizontal swipe indicator.
* **Logging Requirements:** Debug logs for featured items fetch.
* **Analytics Events:** `featured_story_viewed` (Parameters: `post_id` string).
* **Future Roadmap:**
  * **Version 1:** Basic carousel, static layout.
  * **Exclusions:** Personalized recommendations.
  * **Version 2:** Custom themes for featured posts.
  * **Version 3:** Automated selection based on sentiment metrics.

---

## 6. Trending Feed

* **Feature Overview:** High-activity posts feed.
* **Purpose:** Surfacing active discussions.
* **Description:** Sorts posts by support reaction volume and comments within the last 24 hours.
* **Actors:** Guest User, Supabase.
* **Preconditions:** Authenticated session active.
* **Trigger:** User taps the "Trending" feed filter.
* **Inputs:** Custom sort query to Supabase.
* **Outputs:** Sorted posts list.
* **Functional Behaviour:**
  1. Calculates the activity score of posts within the last 24 hours: `Score = Reactions + (Comments * 2)`.
  2. Fetches and displays posts sorted by activity score.
* **Validation Rules:** Calculation variables must be non-negative integers.
* **Business Rules:** The calculation excludes posts older than 48 hours to keep the feed fresh.
* **Success Scenario:** Trending feed renders sorted posts in under 600ms.
* **Alternative Scenarios:** If trending metrics are identical, the feed falls back to sorting by post timestamp.
* **Failure Scenarios:** Slow query response triggers a fallback to chronological sorting.
* **Edge Cases:** Sudden viral spikes must not overwhelm DB query optimization indexes.
* **User Feedback:** Loading indicators, trending icon badges.
* **Logging Requirements:** Slow-query logging for trending execution plans.
* **Analytics Events:** `trending_feed_viewed`.
* **Future Roadmap:**
  * **Version 1:** Simple 24h activity score sort.
  * **Exclusions:** Complex personalized search models.
  * **Version 2:** Time window adjustments (e.g., 6h, 12h, 48h).
  * **Version 3:** Advanced machine learning engagement feeds.

---

## 7. Search

* **Feature Overview:** Query database content.
* **Purpose:** Allows users to find posts and tags matching their interests.
* **Description:** Text search matching queries against tags, categories, and post text.
* **Actors:** Guest User.
* **Preconditions:** Authenticated session active.
* **Trigger:** User enters text in the search input field.
* **Inputs:** Text query string.
* **Outputs:** Matching posts list.
* **Functional Behaviour:**
  1. Collects text query.
  2. Checks query against categories, tags, and text indexes.
  3. Displays matches in a list.
* **Validation Rules:** Queries are limited to a maximum of 100 characters and are stripped of special characters.
* **Business Rules:** Search excludes blocked words and flagged posts.
* **Success Scenario:** Search matches and displays results in under 400ms.
* **Alternative Scenarios:** If no results are found, the app displays helpful category recommendations.
* **Failure Scenarios:** Database failure displays: *"Search is currently unavailable."*
* **Edge Cases:** Rapid backspacing and typing must trigger query debouncing to avoid API rate limits.
* **User Feedback:** Real-time query suggestions.
* **Logging Requirements:** Warn logs for timeouts on search queries.
* **Analytics Events:** `search_executed` (Parameters: `query_length` int, `results_count` int).
* **Future Roadmap:**
  * **Version 1:** Exact tag matches, basic debouncing.
  * **Exclusions:** Full-text semantic search.
  * **Version 2:** Fuzzy text matching, recent searches cache.
  * **Version 3:** AI-powered semantic search matching user intent.

---

## 8. Category Feed

* **Feature Overview:** Categorized posts feed.
* **Purpose:** Helps users find content matching specific life contexts.
* **Description:** Filtered feed displaying posts matching a specific category tab.
* **Actors:** Guest User.
* **Preconditions:** Authenticated session active.
* **Trigger:** User taps a category tab.
* **Inputs:** Category ID.
* **Outputs:** Category-specific posts list.
* **Functional Behaviour:**
  1. Queries Supabase database for posts matching the selected category ID.
  2. Caches results locally and displays the feed.
* **Validation Rules:** Category ID must match the system catalog.
* **Business Rules:** Category options are defined by the system; custom user categories are blocked in V1.
* **Success Scenario:** Category feed displays posts in under 400ms.
* **Alternative Scenarios:** Offline browsing falls back to cached category content.
* **Failure Scenarios:** Network disconnect displays a connection warning banner.
* **Edge Cases:** Accessing an empty category must display the "No posts here" illustration.
* **User Feedback:** Smooth horizontal tab transitions.
* **Logging Requirements:** Debug logs for category queries.
* **Analytics Events:** `category_viewed` (Parameters: `category_name` string).
* **Future Roadmap:**
  * **Version 1:** Static tabs, chronological posts.
  * **Exclusions:** Customizable user layouts.
  * **Version 2:** User category pinning and muting options.
  * **Version 3:** Personalized category sorting based on engagement metrics.

---

## 9. Create Post

* **Feature Overview:** Write and publish a post.
* **Purpose:** Allows users to share their thoughts anonymously.
* **Description:** Input screen with text guidelines, categories, and mood selections.
* **Actors:** Guest User, Supabase.
* **Preconditions:** Authenticated session active.
* **Trigger:** User taps the FAB on the Home Feed.
* **Inputs:** Body text, category selection, mood tag.
* **Outputs:** New post in the database, success transition.
* **Functional Behaviour:**
  1. Captures text input, category, and mood.
  2. Runs validation checks.
  3. Sends post data to Supabase.
  4. Returns user to the feed upon success.
* **Validation Rules:**
  - Body text must be between **100 and 2,000 characters**.
  - Must select exactly one category and one mood tag.
  - Text must not contain forbidden keywords.
* **Business Rules:** Posts are assigned dynamic pseudonyms. External links are stripped automatically.
* **Success Scenario:** Post is successfully published, and the user returns to the feed.
* **Alternative Scenarios:** User discards the draft, saving it locally.
* **Failure Scenarios:** Upload failure displays: *"Unable to publish. Draft saved."*
* **Edge Cases:** If connection is lost during upload, the app saves the draft locally and schedules a background sync retry.
* **User Feedback:** Character count indicator, validation warnings.
* **Logging Requirements:** Warning logs for content filtering flags.
* **Analytics Events:** `post_submitted` (Parameters: `word_count` int, `category` string, `mood` string).
* **Future Roadmap:**
  * **Version 1:** Text posts, categories, character limits.
  * **Exclusions:** Rich media (images/video/audio) attachments.
  * **Version 2:** Scheduled posting times, custom post backgrounds.
  * **Version 3:** Voice-to-text post generation with vocal anonymizer filters.

---

## 10. Draft System

* **Feature Overview:** Local post draft management.
* **Purpose:** Prevents data loss during interruptions.
* **Description:** Automatically saves unpublished writing to local storage.
* **Actors:** Guest User.
* **Preconditions:** User is on the Create Post screen.
* **Trigger:** User exits the screen before publishing.
* **Inputs:** Current editor text state.
* **Outputs:** SQLite database record update.
* **Functional Behaviour:**
  1. Auto-saves editor content to the local database every 10 seconds.
  2. If the user exits before publishing, the draft is flagged as active.
  3. Re-entering Create Post prompts the user to restore the draft.
* **Validation Rules:** Draft storage limits are capped at 10 active records per device.
* **Business Rules:** Drafts are stored locally and are never synced to Supabase until published.
* **Success Scenario:** Draft saves successfully and is restored on next launch.
* **Alternative Scenarios:** User manually deletes a draft from local storage.
* **Failure Scenarios:** Database storage limits prevent auto-saving, displaying a warning banner.
* **Edge Cases:** Keystore rotation must not corrupt local draft encryption keys.
* **User Feedback:** Subtle "Draft saved" toast indicators.
* **Logging Requirements:** Warn logs for draft database storage limits.
* **Analytics Events:** `draft_saved` (Parameters: `character_count` int), `draft_restored`.
* **Future Roadmap:**
  * **Version 1:** Local drafts, basic auto-save.
  * **Exclusions:** Syncing drafts across devices.
  * **Version 2:** Multiple draft management screens.
  * **Version 3:** Secure cloud drafts.

---

## 11. Post Details

* **Feature Overview:** Full view of a post.
* **Purpose:** Allows users to read posts and comments in detail.
* **Description:** Loads full post content and comment feeds.
* **Actors:** Guest User, Supabase.
* **Preconditions:** Authenticated session active.
* **Trigger:** User taps a post card on the feed.
* **Inputs:** Post ID.
* **Outputs:** Post detail display, comments list.
* **Functional Behaviour:**
  1. Fetches post details and associated comments from Supabase.
  2. Displays comments chronologically below the post content.
* **Validation Rules:** Post ID must match a valid active database record.
* **Business Rules:** Deleted posts display: *"This content has been removed."*
* **Success Scenario:** Post details and comments load in under 450ms.
* **Alternative Scenarios:** User saves the post to their offline vault.
* **Failure Scenarios:** Post not found error redirects the user to the feed.
* **Edge Cases:** Concurrent deletions during reading must update the screen state dynamically.
* **User Feedback:** Loading indicators, toast confirmations.
* **Logging Requirements:** Error logs for missing post records.
* **Analytics Events:** `post_detail_opened` (Parameters: `post_id` string, `comment_count` int).
* **Future Roadmap:**
  * **Version 1:** Details view, comment list loading.
  * **Exclusions:** Comment nesting beyond single reply indent.
  * **Version 2:** Interactive comment sorting (e.g., *Recent*, *Most Supportive*).
  * **Version 3:** AI-generated summaries of large discussion threads.

---

## 12. Comments

* **Feature Overview:** Add responses to posts.
* **Purpose:** Enables community interaction.
* **Description:** Character-limited text comments.
* **Actors:** Guest User, Supabase.
* **Preconditions:** Authenticated session active.
* **Trigger:** User taps "Send" in the comment input field.
* **Inputs:** Comment body text.
* **Outputs:** New comment database record.
* **Functional Behaviour:**
  1. Collects text input.
  2. Runs validation checks.
  3. Uploads comment to Supabase.
  4. Appends comment to feed.
* **Validation Rules:**
  - Length must be between **10 and 500 characters**.
  - Text must not contain web links (URLs).
* **Business Rules:** Commenters are assigned random pseudonyms linked to the thread context.
* **Success Scenario:** Comment is successfully validated, published, and rendered.
* **Alternative Scenarios:** User cancels comment editing.
* **Failure Scenarios:** Upload failure displays: *"Unable to post comment. Try again."*
* **Edge Cases:** Commenting on a post that is deleted concurrently must be rejected gracefully.
* **User Feedback:** Submitting progress bar.
* **Logging Requirements:** Warning logs for flagged keywords in comments.
* **Analytics Events:** `comment_created` (Parameters: `post_id` string, `text_length` int).
* **Future Roadmap:**
  * **Version 1:** Basic text replies, profanity filtering.
  * **Exclusions:** Rich media attachment support.
  * **Version 2:** Markdown formatting, sorting choices.
  * **Version 3:** Voice comments with anonymizer filters.

---

## 13. Replies

* **Feature Overview:** Single-level comment nesting.
* **Purpose:** Allows direct conversation within comment threads.
* **Description:** Users can reply directly to comments, grouped in single indented blocks.
* **Actors:** Guest User, Supabase.
* **Preconditions:** Authenticated session active.
* **Trigger:** User taps "Reply" on a comment.
* **Inputs:** Parent comment ID, reply text.
* **Outputs:** Linked comment record in database.
* **Functional Behaviour:**
  1. Focuses the text input field, linking it to the parent comment ID.
  2. Uploads the reply.
  3. Displays the reply indented beneath the parent comment.
* **Validation Rules:** Maximum reply length is **500 characters**.
* **Business Rules:** Nested reply depth is capped at 1 level to keep the UI clean.
* **Success Scenario:** Reply is published and displays indented under the parent comment.
* **Alternative Scenarios:** User deletes their own reply.
* **Failure Scenarios:** Database timeout fails validation, showing a retry prompt.
* **Edge Cases:** Replying to a parent comment that is deleted concurrently must block submission.
* **User Feedback:** Clear indented lines showing thread relationships.
* **Logging Requirements:** Error logs for missing parent comment IDs.
* **Analytics Events:** `reply_created` (Parameters: `parent_id` string).
* **Future Roadmap:**
  * **Version 1:** Single-level nested replies.
  * **Exclusions:** Deep multi-level nesting.
  * **Version 2:** Accordion collapses for long comment threads.
  * **Version 3:** Smart thread grouping.

---

## 14. Support Actions

* **Feature Overview:** Empathy-based post reactions.
* **Purpose:** Replaces traditional quantitative "likes" with support.
* **Description:** Predefined empathy tags to validate and support user posts.
* **Actors:** Guest User, Supabase.
* **Preconditions:** Authenticated session active.
* **Trigger:** User taps the support button on a post.
* **Inputs:** Reaction tag selection.
* **Outputs:** Updated reaction count database record.
* **Functional Behaviour:**
  1. Displays the reaction options menu.
  2. Updates the reaction count immediately on the client (optimistic UI rendering).
  3. Syncs the update to the Supabase database.
* **Validation Rules:** Users are limited to **one reaction type per post**.
* **Business Rules:** Predefined reactions are limited to: *I Hear You*, *Sending Strength*, *Been There*, *Thank You*, and *Calming Hug*.
* **Success Scenario:** Reaction is applied and synced.
* **Alternative Scenarios:** Tapping an active reaction removes it from the post.
* **Failure Scenarios:** Database sync failure rolls back the UI state and displays: *"Action failed."*
* **Edge Cases:** Rapidly tapping multiple reactions must debounce client requests to prevent database locks.
* **User Feedback:** Micro-animations on reaction selection.
* **Logging Requirements:** Debug logs for reaction database syncs.
* **Analytics Events:** `reaction_applied` (Parameters: `post_id` string, `reaction_type` string).
* **Future Roadmap:**
  * **Version 1:** Five basic empathy reactions.
  * **Exclusions:** Custom emoticons or text comments.
  * **Version 2:** Special themes unlocked via wellness streaks.
  * **Version 3:** Advanced animated reactions.

---

## 15. Bookmarks

* **Feature Overview:** Local offline post vault.
* **Purpose:** Allows users to save posts to read later.
* **Description:** Saves post content locally to the device storage.
* **Actors:** Guest User.
* **Preconditions:** Authenticated session active.
* **Trigger:** User taps the bookmark icon.
* **Inputs:** Post ID, text body, author pseudonym.
* **Outputs:** SQLite database record update.
* **Functional Behaviour:**
  1. Writes the post data to the local SQLite database.
  2. Toggles the bookmark icon state.
  3. Displays the post in the Bookmark Vault screen.
* **Validation Rules:** SQLite storage limits are capped at **200 bookmarks** per user.
* **Business Rules:** Bookmarks are stored locally on the device for privacy.
* **Success Scenario:** Post is saved locally and is accessible offline.
* **Alternative Scenarios:** User removes the bookmark, deleting the local record.
* **Failure Scenarios:** SQLite write failure displays: *"Storage full. Unable to bookmark."*
* **Edge Cases:** Accessing bookmarks for a post that has been deleted from Supabase will load the cached text, appending a banner: *"This post was deleted by the author, but remains in your vault."*
* **User Feedback:** Toast confirmation: *"Saved to your vault."*
* **Logging Requirements:** Warn logs for local database storage limits.
* **Analytics Events:** `bookmark_added` (Parameters: `post_id` string).
* **Future Roadmap:**
  * **Version 1:** Local storage, tag filters.
  * **Exclusions:** Syncing bookmarks across devices.
  * **Version 2:** Custom bookmark folders and category organization.
  * **Version 3:** Password-protected vaults.

---

## 16. History

* **Feature Overview:** Private activity log.
* **Purpose:** Allows users to track their past posts and comments.
* **Description:** Displays list of posts and comments created on the device.
* **Actors:** Guest User.
* **Preconditions:** Local database has user records.
* **Trigger:** User opens "My Vault" -> "History".
* **Inputs:** Local database queries.
* **Outputs:** History log rendering.
* **Functional Behaviour:**
  1. Queries the local SQLite database for historical entries.
  2. Lists matching posts and comments chronologically.
* **Validation Rules:** History displays a maximum of 100 historical items.
* **Business Rules:** To protect privacy, this history log is stored locally and is never uploaded to the backend.
* **Success Scenario:** History log is successfully retrieved and rendered.
* **Alternative Scenarios:** User manually clears their history, purging the local database tables.
* **Failure Scenarios:** Local database access errors display: *"History log unavailable."*
* **Edge Cases:** App cache clearance from Android system settings will clear the local history.
* **User Feedback:** Delete confirmation dialogues.
* **Logging Requirements:** Warning logs for database access failures.
* **Analytics Events:** `history_cleared`.
* **Future Roadmap:**
  * **Version 1:** Local history log, manual deletion.
  * **Exclusions:** Syncing history across devices.
  * **Version 2:** Auto-delete history settings (e.g., after 7, 30, or 90 days).
  * **Version 3:** Advanced local search filters.

---

## 17. Notifications

* **Feature Overview:** Push and in-app notifications.
* **Purpose:** Alerts users to community support and updates.
* **Description:** Custom notifications for post reactions and daily prompts.
* **Actors:** System, Supabase Edge Functions.
* **Preconditions:** Notification permissions granted by the OS.
* **Trigger:** User receives support reactions, or system publishes daily prompts.
* **Inputs:** Notification payload from database.
* **Outputs:** System tray alert.
* **Functional Behaviour:**
  1. Supabase Edge Functions trigger push payloads upon new post actions.
  2. Mobile OS renders notifications in the system tray.
  3. Tapping a notification opens the relevant post.
* **Validation Rules:** Notification payload size must be under 4KB.
* **Business Rules:** Notifications do not contain PII or user IDs.
* **Success Scenario:** Notification is delivered and opens the correct post when tapped.
* **Alternative Scenarios:** User sets quiet hours, silencing notifications.
* **Failure Scenarios:** If network drops, system retries payload delivery.
* **Edge Cases:** Receiving multiple reactions on a post within a short time must group notifications to prevent spam.
* **User Feedback:** Custom notification sounds and icons.
* **Logging Requirements:** Info logs for notification receipt events.
* **Analytics Events:** `notification_received`, `notification_opened` (Parameters: `type` string).
* **Future Roadmap:**
  * **Version 1:** Basic push notifications, settings toggles.
  * **Exclusions:** Interactive inline actions.
  * **Version 2:** Rich notifications with support buttons.
  * **Version 3:** Dynamic notifications customized to user engagement patterns.

---

## 18. Daily Reflection

* **Feature Overview:** Structured daily prompt.
* **Purpose:** Guides users toward mindful self-reflection.
* **Description:** A daily prompt curated by wellness advisors.
* **Actors:** Guest User, Supabase.
* **Preconditions:** Authenticated session active.
* **Trigger:** System clock hits 6:00 AM local time.
* **Inputs:** Daily prompt database record.
* **Outputs:** Display of today's prompt.
* **Functional Behaviour:**
  1. Fetches the daily prompt from Supabase.
  2. Updates local tables.
  3. Displays prompt on the Reflections tab.
* **Validation Rules:** Prompts are restricted to a maximum of 280 characters.
* **Business Rules:** To view community responses, the user must first submit their own reflection.
* **Success Scenario:** Daily prompt displays correctly and prompts user input.
* **Alternative Scenarios:** User accesses archived reflections from previous days.
* **Failure Scenarios:** Offline mode displays: *"Reflection unavailable. Connect to the network to unlock today's prompt."*
* **Edge Cases:** System clock timezone adjustments must sync query logic correctly.
* **User Feedback:** Locked-content overlay visual screens.
* **Logging Requirements:** Info logs for daily reflection downloads.
* **Analytics Events:** `daily_reflection_opened` (Parameters: `prompt_id` string).
* **Future Roadmap:**
  * **Version 1:** Daily prompt, locked answers loop.
  * **Exclusions:** Dynamic user-suggested prompts.
  * **Version 2:** Personalized mood-matching prompts.
  * **Version 3:** Interactive voice reflections.

---

## 19. Reflection Answers

* **Feature Overview:** Community reflection feed.
* **Purpose:** Promotes shared connection and mutual validation.
* **Description:** Feed displaying community responses to the daily prompt.
* **Actors:** Guest User, Supabase.
* **Preconditions:** User has submitted their own daily reflection.
* **Trigger:** User submits their response.
* **Inputs:** User submission confirmation.
* **Outputs:** Feed of community answers.
* **Functional Behaviour:**
  1. Submits user response to Supabase.
  2. Unlocks the reflection feed.
  3. Fetches and displays community responses.
* **Validation Rules:** Answers are text-only, limited to a maximum of 500 characters.
* **Business Rules:** Community answers are completely anonymous. Comments are disabled on answers to prevent harassment.
* **Success Scenario:** Reflection answer is published, unlocking the community feed.
* **Alternative Scenarios:** Users can read community responses without posting after 24 hours.
* **Failure Scenarios:** Submission timeout displays: *"Publishing failed. Retrying..."*
* **Edge Cases:** If a user deletes their response, the community feed is locked again.
* **User Feedback:** Feed unlock animations.
* **Logging Requirements:** Debug logs for response unlocking.
* **Analytics Events:** `reflection_answer_submitted` (Parameters: `prompt_id` string, `word_count` int).
* **Future Roadmap:**
  * **Version 1:** Text replies, locked feed, empathy reactions.
  * **Exclusions:** Moderated discussion threads within reflection replies.
  * **Version 2:** Filter answers by mood.
  * **Version 3:** Community moderation tags.

---

## 20. Daily Challenges

* **Feature Overview:** Positive connection tasks.
* **Purpose:** Encourages positive interactions within the community.
* **Description:** Daily tasks such as leaving supportive comments or reading featured stories.
* **Actors:** Guest User.
* **Preconditions:** Authenticated session active.
* **Trigger:** System clock hits 6:00 AM local time.
* **Inputs:** Daily challenge details database record.
* **Outputs:** Active challenge card.
* **Functional Behaviour:**
  1. Displays the daily challenge details.
  2. Tracks user interactions on the device.
  3. Completes challenge when parameters are met.
* **Validation Rules:** Completion metrics must be validated locally.
* **Business Rules:** Completion awards a wellness streak; no monetary rewards are offered.
* **Success Scenario:** Challenge is completed, updating the streak count.
* **Alternative Scenarios:** User skips the daily challenge.
* **Failure Scenarios:** Sync errors prevent challenge updates, displaying: *"Unable to load challenge."*
* **Edge Cases:** Modifying the system clock must not trigger automatic challenge completions.
* **User Feedback:** Completion animations and badges.
* **Logging Requirements:** Debug logs for challenge progress tracking.
* **Analytics Events:** `challenge_completed` (Parameters: `challenge_type` string, `streak_count` int).
* **Future Roadmap:**
  * **Version 1:** Predefined daily challenges, local progress tracking.
  * **Exclusions:** Multi-user shared group challenges.
  * **Version 2:** Special themes unlocked via wellness streaks.
  * **Version 3:** Dynamically generated challenges personalized to user behavior.

---

## 21. Letters Never Sent

* **Feature Overview:** Unsent letters catalog.
* **Purpose:** Provides a therapeutic outlet for unsent thoughts.
* **Description:** Interface styled as letter templates where users can write anonymously.
* **Actors:** Guest User, Supabase.
* **Preconditions:** Authenticated session active.
* **Trigger:** User taps "Compose Letter" in the Letters Vault tab.
* **Inputs:** Recipient, subject, body text.
* **Outputs:** Local draft update or public post in the database.
* **Functional Behaviour:**
  1. Displays recipient templates (e.g., *To my ex*, *To my boss*).
  2. Saves writing locally as private drafts, or publishes anonymously to the public "Letters Never Sent" feed.
* **Validation Rules:**
  - Body text must be between **200 and 4,000 characters**.
  - Must select a recipient template type.
* **Business Rules:** Private letters are encrypted and stored locally. Public letters are visible to the community, and other users can leave support reactions.
* **Success Scenario:** Letter is published or saved privately.
* **Alternative Scenarios:** User deletes a draft, purging it from local storage.
* **Failure Scenarios:** Database failure prevents public posting, saving the letter locally instead.
* **Edge Cases:** Vault storage limits must prevent saving when local device memory is low.
* **User Feedback:** Calming letter themes and confirmation prompts.
* **Logging Requirements:** Warning logs for local storage capacity issues.
* **Analytics Events:** `letter_created` (Parameters: `is_public` boolean, `recipient_type` string).
* **Future Roadmap:**
  * **Version 1:** Text templates, local encrypt, public share feed.
  * **Exclusions:** Rich media attachment support.
  * **Version 2:** Password protection for private vaults.
  * **Version 3:** Virtual stamp collections and handwritten stylus input options.

---

## 22. Achievements

* **Feature Overview:** Positive contribution badges.
* **Purpose:** Encourages supportive participation.
* **Description:** Badges earned by leaving supportive comments, maintaining streaks, and using reflections.
* **Actors:** Guest User.
* **Preconditions:** Local database tracks user stats.
* **Trigger:** Achievement parameters are met on the device.
* **Inputs:** SQLite user activity history tables.
* **Outputs:** Rendered achievement badge.
* **Functional Behaviour:**
  1. Tracks key metrics locally (e.g., reflections completed, reactions sent).
  2. Unlocks the corresponding badge when thresholds are met.
  3. Displays badges in the user's vault.
* **Validation Rules:** Target progress thresholds are defined locally.
* **Business Rules:** Badges are stored locally on the device to protect privacy.
* **Success Scenario:** Badge is unlocked and displayed.
* **Alternative Scenarios:** Clearing local data resets achievement progress.
* **Failure Scenarios:** Database errors block progress tracking, displaying: *"Achievements offline."*
* **Edge Cases:** If local storage is corrupted, the app resets achievements to prevent crashes.
* **User Feedback:** Achievement unlock card overlay screens.
* **Logging Requirements:** Debug logs for progress tracker updates.
* **Analytics Events:** `badge_unlocked` (Parameters: `badge_name` string).
* **Future Roadmap:**
  * **Version 1:** Predefined badges, local SQLite database tracking.
  * **Exclusions:** Leaderboards, public user metrics.
  * **Version 2:** Custom themes unlocked via achievements.
  * **Version 3:** Peer badges awarded directly by community members.

---

## 23. Anonymous Profile

* **Feature Overview:** Ephemeral user representation.
* **Purpose:** Avoids persistent identifiers that can cause social anxiety.
* **Description:** Dynamic, rotating pseudonyms instead of custom bios or search handles.
* **Actors:** Guest User.
* **Preconditions:** Authenticated session active.
* **Trigger:** User creates a new post or comments on a thread.
* **Inputs:** Predefined word database tables.
* **Outputs:** Generated pseudonym (e.g., *Gentle Star*).
* **Functional Behaviour:**
  1. Combines a random adjective and a noun from the local word list.
  2. Assigns the pseudonym to the post or comment thread.
  3. Rotates the pseudonym for each new post to prevent tracking.
* **Validation Rules:** Generated combinations must not match words on the safety blocklist.
* **Business Rules:** Users cannot set custom names, bios, or search handles.
* **Success Scenario:** Pseudonym generates successfully and links to the post.
* **Alternative Scenarios:** Comments within a post thread use fixed handles (e.g., *OP*, *User 1*) to help users follow the conversation.
* **Failure Scenarios:** Generation failures fallback to generic pseudonyms (e.g., *Anonymous Explorer*).
* **Edge Cases:** The system must handle large databases of word combinations without causing performance issues.
* **User Feedback:** Animated icon representing the generated pseudonym.
* **Logging Requirements:** Info logs for identity generation calls.
* **Analytics Events:** `pseudonym_generated`.
* **Future Roadmap:**
  * **Version 1:** Ephemeral name generation.
  * **Exclusions:** Searchable persistent user profiles.
  * **Version 2:** Mood-themed pseudonyms.
  * **Version 3:** Cryptographically authenticated unique handles.

---

## 24. Avatar Customization

* **Feature Overview:** Abstract avatar selector.
* **Purpose:** Customizes user presence without using real-world photos.
* **Description:** A library of abstract shapes, colors, and patterns.
* **Actors:** Guest User.
* **Preconditions:** Authenticated session active.
* **Trigger:** User opens settings to update their profile styling.
* **Inputs:** Pattern and color palette selection.
* **Outputs:** Updated profile avatar.
* **Functional Behaviour:**
  1. Displays customizable abstract shapes and color palettes.
  2. Saves selection to local storage.
  3. Displays the avatar on the user's posts.
* **Validation Rules:** Avatar assets must use verified system SVGs.
* **Business Rules:** Real photos and custom image uploads are blocked.
* **Success Scenario:** Avatar updates successfully.
* **Alternative Scenarios:** User selects the randomizer button to auto-generate a layout.
* **Failure Scenarios:** Storage errors default to the standard placeholder avatar.
* **Edge Cases:** Rendering complex SVG overlays must not cause frame drops on low-end devices.
* **User Feedback:** Live avatar preview cards.
* **Logging Requirements:** Debug logs for preference updates.
* **Analytics Events:** `avatar_updated` (Parameters: `palette_name` string).
* **Future Roadmap:**
  * **Version 1:** Static SVG selection, basic color palettes.
  * **Exclusions:** Custom uploaded image cropping.
  * **Version 2:** Custom icons unlocked via challenges.
  * **Version 3:** Procedural dynamic avatar layouts that respond to app wellness stats.

---

## 25. Settings

* **Feature Overview:** Local application settings.
* **Purpose:** Centralizes configuration and preferences.
* **Description:** Configuration panel for languages, themes, notifications, and data management.
* **Actors:** Guest User.
* **Preconditions:** Application is open.
* **Trigger:** User opens the Settings tab.
* **Inputs:** Preference selections.
* **Outputs:** Updated SharedPreferences configuration.
* **Functional Behaviour:**
  1. Displays settings categories.
  2. Updates local storage immediately on change.
  3. Propagates configuration updates to active screens.
* **Validation Rules:** Config parameter states must match predefined types.
* **Business Rules:** Users can reset all preferences, clearing local storage database tables.
* **Success Scenario:** Preference updates apply instantly across the application.
* **Alternative Scenarios:** User purges cache tables from settings.
* **Failure Scenarios:** Storage write failures display a warning dialog.
* **Edge Cases:** Deleting app preferences during active database sync operations must handle closures gracefully.
* **User Feedback:** Setting state toggles, change confirmation toasts.
* **Logging Requirements:** Info logs for preference updates.
* **Analytics Events:** `settings_modified` (Parameters: `setting_name` string).
* **Future Roadmap:**
  * **Version 1:** Basic configuration toggles.
  * **Exclusions:** Server-based cloud settings sync.
  * **Version 2:** Exportable JSON settings backups.
  * **Version 3:** Automated preference adjustments based on user context.

---

## 26. Privacy Center

* **Feature Overview:** Security policies and tools.
* **Purpose:** Manages user privacy settings.
* **Description:** Privacy options including key management and data clearance.
* **Actors:** Guest User.
* **Preconditions:** Application is open.
* **Trigger:** User opens Settings -> Privacy Center.
* **Inputs:** Security action selections.
* **Outputs:** Purged database data, exported key files.
* **Functional Behaviour:**
  1. Displays security settings (e.g., key export, clear cache).
  2. Explains data deletion consequences.
  3. Executes security actions on user confirmation.
* **Validation Rules:** Deletion actions require entering verification text (e.g., *"DELETE MY DATA"*).
* **Business Rules:** Deleting data removes all posts and comments from both local storage and Supabase.
* **Success Scenario:** Data deletion completes, returning the user to the onboarding screen.
* **Alternative Scenarios:** User exports their backup key as an encrypted file.
* **Failure Scenarios:** Sync errors prevent backend deletion, displaying a retry prompt.
* **Edge Cases:** Initiating account deletion while offline must save the action and queue it for execution on next connection.
* **User Feedback:** Deletion warnings and verification dialogs.
* **Logging Requirements:** Info logs for security events and account purges.
* **Analytics Events:** `account_permanently_deleted`, `backup_key_exported`.
* **Future Roadmap:**
  * **Version 1:** Basic local wipe, recovery key export.
  * **Exclusions:** Biometric verification locks.
  * **Version 2:** Secure passcode locks for the application vault.
  * **Version 3:** Advanced local data encryption protocols.

---

## 27. Language

* **Feature Overview:** Localized system text.
* **Purpose:** Supports users in different languages.
* **Description:** Select and load language resource dictionaries.
* **Actors:** Guest User.
* **Preconditions:** Language localization files are packaged with the app build.
* **Trigger:** User selects a new language in Settings.
* **Inputs:** Selected language code.
* **Outputs:** Reloaded UI strings in the selected language.
* **Functional Behaviour:**
  1. Updates the locale configuration.
  2. Reloads JSON localization files.
  3. Updates UI text elements.
* **Validation Rules:** Locale code must match packaged languages (e.g., *en*, *es*).
* **Business Rules:** The default language is English if the system locale is unsupported.
* **Success Scenario:** UI updates to the selected language without requiring a reload.
* **Alternative Scenarios:** The app matches the Android system language automatically on launch.
* **Failure Scenarios:** Missing language files default to English.
* **Edge Cases:** Switching language with active form inputs must preserve user text.
* **User Feedback:** Updated text layouts.
* **Logging Requirements:** Debug logs for locale change events.
* **Analytics Events:** `language_changed` (Parameters: `locale` string).
* **Future Roadmap:**
  * **Version 1:** English support, static translation files.
  * **Exclusions:** Real-time post translations.
  * **Version 2:** Spanish, German, and Portuguese support.
  * **Version 3:** Real-time translation for community feeds.

---

## 28. Theme

* **Feature Overview:** Theme management (Dark, Light, System).
* **Purpose:** Customizes the reading experience and reduces eye strain.
* **Description:** Adjusts UI colors based on user selection or system preference.
* **Actors:** Guest User.
* **Preconditions:** Theme files are packaged with the app.
* **Trigger:** User changes theme settings.
* **Inputs:** Selected theme mode tag.
* **Outputs:** Updated system theme.
* **Functional Behaviour:**
  1. Saves selection to local preferences.
  2. Applies updated theme color variables to the UI.
* **Validation Rules:** Option must match allowed settings: *Dark*, *Light*, or *System*.
* **Business Rules:** The default theme is Dark Mode to promote a calming user experience.
* **Success Scenario:** Theme changes apply instantly without lag.
* **Alternative Scenarios:** Selecting "System Default" matches the theme to Android system settings.
* **Failure Scenarios:** Theme application errors default to Dark Mode.
* **Edge Cases:** Rapidly toggling themes must not cause UI lag or layout errors.
* **User Feedback:** Smooth color transitions.
* **Logging Requirements:** Debug logs for theme changes.
* **Analytics Events:** `theme_changed` (Parameters: `theme_type` string).
* **Future Roadmap:**
  * **Version 1:** Light, Dark, and System theme selectors.
  * **Exclusions:** Custom user theme color configurations.
  * **Version 2:** Special themes unlocked via wellness streaks.
  * **Version 3:** Automated theme changes based on sunset/sunrise times.

---

## 29. Report Content

* **Feature Overview:** Moderation flagging.
* **Purpose:** Keeps the platform safe and toxicity-free.
* **Description:** Flagging tool for posts or comments that violate community guidelines.
* **Actors:** Guest User, Supabase.
* **Preconditions:** Authenticated session active.
* **Trigger:** User taps the report flag button on content.
* **Inputs:** Content ID, selected report reason.
* **Outputs:** Updated moderation record in Supabase.
* **Functional Behaviour:**
  1. Opens the report options bottom sheet.
  2. Submits the report to Supabase.
  3. Hides the reported content from the user's feed.
* **Validation Rules:** Report reasons must match allowed categories: *Self-harm*, *Harassment*, *PII Leak*, *Spam*, *Hate Speech*.
* **Business Rules:** Content receiving more than 3 reports is hidden automatically pending review.
* **Success Scenario:** Content is flagged, hidden locally, and queued for review.
* **Alternative Scenarios:** User blocks the author, hiding all their posts.
* **Failure Scenarios:** Sync errors queue the report locally for submission when online.
* **Edge Cases:** If a user reports their own post, the action is rejected.
* **User Feedback:** Toast confirmation: *"Thank you. We will review this content."*
* **Logging Requirements:** Warn logs for high report counts on specific content.
* **Analytics Events:** `content_reported` (Parameters: `content_type` string, `reason` string).
* **Future Roadmap:**
  * **Version 1:** Predefined reasons, automated hide rules.
  * **Exclusions:** Direct messaging review tools.
  * **Version 2:** AI-assisted classification of reported content.
  * **Version 3:** Automated peer-review moderation systems.

---

## 30. Community Guidelines

* **Feature Overview:** Platform rules reference.
* **Purpose:** Sets clear expectations for community behavior.
* **Description:** Static reference screen detailing safety policies and rules.
* **Actors:** Guest User.
* **Preconditions:** Guidelines document is packaged with the app build.
* **Trigger:** User opens Settings -> Community Guidelines.
* **Inputs:** Screen navigation request.
* **Outputs:** Renders the Guidelines text.
* **Functional Behaviour:**
  1. Loads packaged rules document.
  2. Renders text with formatted headers.
* **Validation Rules:** Content must match safety requirements.
* **Business Rules:** Guidelines must be accessible at all times, including offline.
* **Success Scenario:** Screen loads and displays text.
* **Alternative Scenarios:** Redirects users to external helpline links for immediate support.
* **Failure Scenarios:** Loading errors display a fallback rules card.
* **Edge Cases:** Fast scrolling down guidelines must not lag or cause layout overflow.
* **User Feedback:** Interactive headers and search shortcuts.
* **Logging Requirements:** Debug logs for screen open events.
* **Analytics Events:** `guidelines_viewed`.
* **Future Roadmap:**
  * **Version 1:** Static guidelines screen, clean formatting.
  * **Exclusions:** Interactive quizzes on safety guidelines.
  * **Version 2:** Quizzes that award badges for knowing the guidelines.
  * **Version 3:** Multi-language localized guidelines screens.

---

## 31. Support Center

* **Feature Overview:** Helpline search.
* **Purpose:** Provides crisis helpline resources for vulnerable users.
* **Description:** Searchable list of global mental health resources and helplines.
* **Actors:** Guest User.
* **Preconditions:** Resource list is cached locally.
* **Trigger:** User opens Support Center or flags self-harm content.
* **Inputs:** Location selection.
* **Outputs:** Targeted resource contact info.
* **Functional Behaviour:**
  1. Displays resource categories (e.g., *Grief Support*, *Crisis Helplines*).
  2. Shows helpline phone numbers, SMS codes, and links based on selected location.
* **Validation Rules:** Phone numbers must use valid international formats.
* **Business Rules:** Crisis resources must be available offline without network access.
* **Success Scenario:** Support center opens and displays contact info.
* **Alternative Scenarios:** Double-clicking telephone links launches the phone dialer.
* **Failure Scenarios:** UI loading errors display generic fallback contact info.
* **Edge Cases:** If a country is not found, the app defaults to displaying international resources.
* **User Feedback:** Tap-to-copy phone numbers, clear quick-call buttons.
* **Logging Requirements:** Info logs for helpline interactions.
* **Analytics Events:** `helpline_accessed` (Parameters: `country` string, `helpline_name` string).
* **Future Roadmap:**
  * **Version 1:** Static resource database, location filters.
  * **Exclusions:** Direct integration with live chat interfaces.
  * **Version 2:** Direct messaging integration with crisis hotlines.
  * **Version 3:** GPS-based routing to local health centers.

---

## 32. Feedback

* **Feature Overview:** Bug report submission.
* **Purpose:** Allows users to report issues directly to the developers.
* **Description:** Input form for bug reports, suggestions, and suggestions.
* **Actors:** Guest User, Supabase.
* **Preconditions:** Authenticated session active.
* **Trigger:** User opens Settings -> Send Feedback.
* **Inputs:** Topic category, description text.
* **Outputs:** Updated feedback record in Supabase.
* **Functional Behaviour:**
  1. Collects feedback text and category selection.
  2. Runs validation checks.
  3. Uploads submission to Supabase.
* **Validation Rules:**
  - Description body must be between **20 and 1,000 characters**.
  - Must select a valid category.
* **Business Rules:** Submissions do not upload user logs or device data without consent.
* **Success Scenario:** Feedback is submitted successfully, displaying a thank-you dialog.
* **Alternative Scenarios:** User exits without submitting, discarding the draft.
* **Failure Scenarios:** Upload failure displays: *"Unable to send feedback. Saved to drafts."*
* **Edge Cases:** Submitting feedback while offline must queue the submission locally.
* **User Feedback:** Submission progress indicators, success toasts.
* **Logging Requirements:** Info logs for feedback submission attempts.
* **Analytics Events:** `feedback_submitted` (Parameters: `category` string, `text_length` int).
* **Future Roadmap:**
  * **Version 1:** Simple text form, category selectors.
  * **Exclusions:** Attaching screenshots or file uploads.
  * **Version 2:** Screenshot attachment support, formatted replies.
  * **Version 3:** Multi-threaded support ticketing panels.

---

## 33. Rate App

* **Feature Overview:** Play Store rating prompt.
* **Purpose:** Encourages reviews to improve store ratings.
* **Description:** Prompt asking users to review the app on the Google Play Store.
* **Actors:** Guest User, Google Play Core API.
* **Preconditions:** App meets prompt criteria.
* **Trigger:** User completes 5 daily reflection challenges.
* **Inputs:** Rating action confirmation.
* **Outputs:** Google Play Review overlay.
* **Functional Behaviour:**
  1. Checks if prompt criteria are met.
  2. Launches the Google Play In-App Review dialog.
  3. Updates preferences to prevent showing the prompt again.
* **Validation Rules:** The prompt is shown a maximum of 3 times per user.
* **Business Rules:** The prompt is shown only after positive actions (e.g., challenge completion) to optimize ratings.
* **Success Scenario:** The Play Store review overlay opens and registers the rating.
* **Alternative Scenarios:** User taps "Later", postponing the prompt for 7 days.
* **Failure Scenarios:** Play Store Core API failures default to opening the external Play Store page.
* **Edge Cases:** If Google Play Services are missing, the prompt is disabled automatically.
* **User Feedback:** Clean native Android review overlays.
* **Logging Requirements:** Debug logs for review request triggers.
* **Analytics Events:** `rate_prompt_shown`, `rate_prompt_acted` (Parameters: `action` string).
* **Future Roadmap:**
  * **Version 1:** Play Store Core API overlay prompt.
  * **Exclusions:** Custom inline rating dialogs.
  * **Version 2:** Dynamic triggers based on user engagement metrics.
  * **Version 3:** Incentivized feedback programs.

---

## 34. Share App

* **Feature Overview:** Share platform download link.
* **Purpose:** Encourages viral growth.
* **Description:** Generates a clean referral link text to share the app.
* **Actors:** Guest User, Android Sharesheet.
* **Preconditions:** OS Sharesheet is available.
* **Trigger:** User taps "Share RAAZ" in settings or post cards.
* **Inputs:** Share action request.
* **Outputs:** Android Sharesheet intent.
* **Functional Behaviour:**
  1. Generates invitation text with the app download link.
  2. Launches the native Android Sharesheet.
* **Validation Rules:** Download link must direct users to the official Play Store listing.
* **Business Rules:** Share payloads do not contain referral codes or tracking IDs.
* **Success Scenario:** Sharesheet opens, allowing the user to select an external app.
* **Alternative Scenarios:** Tapping "Copy Link" saves the URL directly to the clipboard.
* **Failure Scenarios:** Sharesheet failures fallback to copying the link to the clipboard.
* **Edge Cases:** Long post texts must be cropped to avoid exceeding clipboard limits.
* **User Feedback:** Standard Android sharesheet overlays.
* **Logging Requirements:** Info logs for share events.
* **Analytics Events:** `app_shared` (Parameters: `source_screen` string).
* **Future Roadmap:**
  * **Version 1:** Basic text link sharing.
  * **Exclusions:** Interactive referral reward programs.
  * **Version 2:** Visual styled image card generator.
  * **Version 3:** Dynamic deep link invitations that open specific categories.

---

## 35. Offline Mode

* **Feature Overview:** Offline caching support.
* **Purpose:** Enables reading and writing without active network connections.
* **Description:** Falls back to local database records when connection is lost.
* **Actors:** System, Guest User.
* **Preconditions:** Connection is unavailable.
* **Trigger:** Network connection drops.
* **Inputs:** Connection status changes.
* **Outputs:** Offline status banner.
* **Functional Behaviour:**
  1. Detects network disconnect.
  2. Displays an offline warning banner.
  3. Configures database queries to load cached content.
  4. Saves new posts as drafts locally.
* **Validation Rules:** Cache data must match sync status flags.
* **Business Rules:** Writing actions (posts, comments) are saved locally until a connection is restored.
* **Success Scenario:** User can browse and write drafts offline.
* **Alternative Scenarios:** User reconnects, and the app transitions back to online mode.
* **Failure Scenarios:** Corrupted local database caches trigger automatic tables regeneration.
* **Edge Cases:** High device storage use must clear the image cache before deleting database records.
* **User Feedback:** Top-bar status banners, disabled interaction states.
* **Logging Requirements:** Warn logs for connection status changes.
* **Analytics Events:** `network_status_changed` (Parameters: `is_online` boolean).
* **Future Roadmap:**
  * **Version 1:** SQLite caching, draft saving, offline banners.
  * **Exclusions:** Multi-user offline conflict resolution.
  * **Version 2:** Dynamic cache pruning settings.
  * **Version 3:** Peer-to-peer mesh sync networks.

---

## 36. Synchronization

* **Feature Overview:** Cache sync.
* **Purpose:** Updates local databases and syncs offline edits.
* **Description:** Syncs cached local drafts and changes to Supabase once online.
* **Actors:** System, Supabase.
* **Preconditions:** Network connection is restored.
* **Trigger:** App transitions to online mode.
* **Inputs:** Cached offline edits list.
* **Outputs:** Synchronized database tables.
* **Functional Behaviour:**
  1. Checks for local edits with pending status flags.
  2. Sends changes to Supabase.
  3. Updates sync flags upon confirmation.
  4. Fetches and updates the local cache.
* **Validation Rules:** Data payloads must pass security checks.
* **Business Rules:** Sync operations prioritize user edits over server state during updates.
* **Success Scenario:** Local edits sync, and the feed updates.
* **Alternative Scenarios:** Resolves conflict issues by matching timestamps.
* **Failure Scenarios:** Sync errors pause the queue and reschedule execution.
* **Edge Cases:** Sudden connection drops during sync must not cause duplicate posts.
* **User Feedback:** Silent status updates, refresh spinners.
* **Logging Requirements:** Debug logs for sync items processing.
* **Analytics Events:** `sync_completed` (Parameters: `records_count` int).
* **Future Roadmap:**
  * **Version 1:** Basic draft sync.
  * **Exclusions:** Dual-active multi-device databases sync.
  * **Version 2:** Smart delta sync updates.
  * **Version 3:** Fully decentralized synchronization databases.

---

## 37. Error Handling

* **Feature Overview:** Centralized error management.
* **Purpose:** Handles failures gracefully without crashing.
* **Description:** Intercepts and logs errors, showing helpful recovery actions to the user.
* **Actors:** System.
* **Preconditions:** System exception occurs.
* **Trigger:** API timeouts, database errors, or memory warnings.
* **Inputs:** Exception traces, stack frames.
* **Outputs:** UI error banners, diagnostic logs.
* **Functional Behaviour:**
  1. Intercepts exceptions.
  2. Logs error details for diagnostics.
  3. Displays user-friendly error messages and recovery actions.
* **Validation Rules:** Error messages must not expose internal technical details.
* **Business Rules:** Sensitive data is stripped from errors before logging.
* **Success Scenario:** System handles exception and recovery proceeds without a crash.
* **Alternative Scenarios:** Retries the failed action in the background.
* **Failure Scenarios:** Unrecoverable errors prompt a crash recovery screen.
* **Edge Cases:** Running out of storage must not corrupt the local SQLite database.
* **User Feedback:** Error banners and retry options.
* **Logging Requirements:** Error level log messages with stack traces.
* **Analytics Events:** `app_error` (Parameters: `error_tag` string, `code` string).
* **Future Roadmap:**
  * **Version 1:** Basic error dialogs, local log files.
  * **Exclusions:** Cloud error aggregation.
  * **Version 2:** Self-healing local database recovery.
  * **Version 3:** Real-time AI-powered diagnostic logs processing.

---

## 38. Loading States

* **Feature Overview:** UI loading states.
* **Purpose:** Visual feedback during data retrieval.
* **Description:** Skeleton UI displays that match content layouts during loading.
* **Actors:** System.
* **Preconditions:** UI requests data from a background thread.
* **Trigger:** App loads a new screen or fetches feed updates.
* **Inputs:** API request initiation.
* **Outputs:** Rendered loading screen.
* **Functional Behaviour:**
  1. Displays skeleton layout blocks matching the content layout.
  2. Fetches data.
  3. Replaces skeleton blocks with loaded content.
* **Validation Rules:** Layout matches must use verified screen models.
* **Business Rules:** Skeletons must animate to show active progress.
* **Success Scenario:** Skeleton transitions to content smoothly.
* **Alternative Scenarios:** Small inline activities display spinner icons.
* **Failure Scenarios:** Data loading failures replace skeletons with error state screens.
* **Edge Cases:** If load takes less than 100ms, the loader is skipped to avoid flickering.
* **User Feedback:** Animated gray layout blocks.
* **Logging Requirements:** Debug logs for render transitions.
* **Analytics Events:** `skeleton_rendered` (Parameters: `duration_ms` int).
* **Future Roadmap:**
  * **Version 1:** Skeleton screens for feeds, spinner icons.
  * **Exclusions:** Shimmer animation controls.
  * **Version 2:** Shimmer gradients custom settings.
  * **Version 3:** Procedural loading layouts.

---

## 39. Empty States

* **Feature Overview:** No-content fallback layouts.
* **Purpose:** Explains empty views and guides the user's next action.
* **Description:** Displays structured illustrations and suggestions when screens are empty.
* **Actors:** System, Guest User.
* **Preconditions:** Feed or list query returns 0 records.
* **Trigger:** Screen rendering query returns empty.
* **Inputs:** 0 count flag.
* **Outputs:** Rendered empty state UI.
* **Functional Behaviour:**
  1. Identifies empty search or feed results.
  2. Displays matching illustration and prompt text.
  3. Shows a call-to-action (CTA) button to help the user proceed.
* **Validation Rules:** CTA paths must match active features.
* **Business Rules:** Empty states must provide actionable next steps (e.g., search alternative tags, start writing).
* **Success Scenario:** Empty state screen loads and prompts action.
* **Alternative Scenarios:** User acts on CTA, updating the screen state.
* **Failure Scenarios:** Render failures default to displaying generic placeholders.
* **Edge Cases:** Fast network status transitions must update empty states instantly.
* **User Feedback:** Custom illustrations, helpful prompt text, CTA buttons.
* **Logging Requirements:** Info logs for empty state displays.
* **Analytics Events:** `empty_state_rendered` (Parameters: `screen_name` string).
* **Future Roadmap:**
  * **Version 1:** Basic illustrations, custom prompt text, CTA buttons.
  * **Exclusions:** Interactive, animated onboarding steps.
  * **Version 2:** Dynamic prompts customized to user interests.
  * **Version 3:** AI-guided suggestions based on local preferences.

---

## 40. Permissions

* **Feature Overview:** System permissions handling.
* **Purpose:** Securely requests device permissions as needed.
* **Description:** Manages requests for OS permissions (e.g., notifications, storage).
* **Actors:** System, Guest User.
* **Preconditions:** App action requires a device permission.
* **Trigger:** User initiates an action requiring storage or notifications.
* **Inputs:** Permission request parameters.
* **Outputs:** Update to system permission status.
* **Functional Behaviour:**
  1. Checks permission status.
  2. If missing, displays an explanation prompt.
  3. Requests the permission from the OS.
* **Validation Rules:** Requests must use standard Android SDK permissions.
* **Business Rules:** Permissions are requested only when needed (just-in-time), never on first launch.
* **Success Scenario:** Permission is granted, and the user action proceeds.
* **Alternative Scenarios:** If denied, the app disables associated features and shows a link to system settings.
* **Failure Scenarios:** Repeated denials disable the request prompt, prompting a manual settings link.
* **Edge Cases:** Permissions modified in Android settings during active app operations must update states cleanly.
* **User Feedback:** Permission dialog overlays.
* **Logging Requirements:** Warning logs for permission denial events.
* **Analytics Events:** `permission_requested` (Parameters: `permission_name` string, `granted` boolean).
* **Future Roadmap:**
  * **Version 1:** Support requests for notification and storage permissions.
  * **Exclusions:** Camera and microphone permission requests.
  * **Version 2:** Future support for audio journal microphone permission requests.
  * **Version 3:** Advanced proximity permission settings.

---

## 41. AdMob Behaviour

* **Feature Overview:** Banner and Native ad integration.
* **Purpose:** Monitizes the application without disrupting the reading experience.
* **Description:** Integrates non-intrusive AdMob banner, native, and rewarded ads.
* **Actors:** Guest User, AdMob.
* **Preconditions:** AdMob SDK initialized.
* **Trigger:** Feed scrolling or setting screen loading.
* **Inputs:** User interaction events.
* **Outputs:** Display of sponsored content.
* **Functional Behaviour:**
  1. Loads ads in the background.
  2. Renders in-feed native ads every 15 items, and banner ads on setting screens.
  3. Displays rewarded ads when users choose to unlock custom styles.
* **Validation Rules:** Ads must be labeled "Sponsored" and have distinct borders.
* **Business Rules:** Restricted categories are disabled (e.g., gambling, political) to maintain safety. Ads are hidden during post composition.
* **Success Scenario:** Ads display cleanly and do not lag the feed.
* **Alternative Scenarios:** Ad loading failures hide the ad container without displaying empty blocks.
* **Failure Scenarios:** Network disconnect disables ads, loading offline cached content instead.
* **Edge Cases:** Rapid scrolling must not trigger ad loading loops or cause UI lag.
* **User Feedback:** Clear "Sponsored" badges, close buttons.
* **Logging Requirements:** Warn logs for ad load failures.
* **Analytics Events:** `ad_rendered` (Parameters: `ad_type` string), `ad_clicked`.
* **Future Roadmap:**
  * **Version 1:** In-feed native ads, banner ads, rewarded style unlocks.
  * **Exclusions:** Intrusive full-screen interstitial ads.
  * **Version 2:** Contextual ad category optimization.
  * **Version 3:** Ad-free premium tier options.

---

## 42. Future Premium Placeholders

* **Feature Overview:** Premium feature gates.
* **Purpose:** Prepares the application for premium tier monetization.
* **Description:** Inactive UI controls and configurations for future premium features.
* **Actors:** Guest User.
* **Preconditions:** Application config active.
* **Trigger:** User interacts with locked settings.
* **Inputs:** Tap events on premium items.
* **Outputs:** Informational prompt dialog.
* **Functional Behaviour:**
  1. Identifies premium actions (e.g., audio vault, custom focus rooms).
  2. Displays lock icons on premium settings.
  3. Shows a feature interest survey when tapped.
* **Validation Rules:** Prompt actions are static.
* **Business Rules:** Premium prompts explain features without collecting payments in V1.
* **Success Scenario:** Lock indicators display cleanly and prompt interest options.
* **Alternative Scenarios:** Users opt-in to notifications for feature updates.
* **Failure Scenarios:** Configuration errors hide lock indicators.
* **Edge Cases:** Offline usage must preserve static lock indicators.
* **User Feedback:** Feature interest survey dialogs.
* **Logging Requirements:** Debug logs for premium interactions.
* **Analytics Events:** `premium_preview_tapped` (Parameters: `feature_tag` string).
* **Future Roadmap:**
  * **Version 1:** Static lock icons, feature interest surveys.
  * **Exclusions:** Processing payments, subscription models.
  * **Version 2:** Secure subscription plans and checkouts.
  * **Version 3:** Personalized recommendation plans.
