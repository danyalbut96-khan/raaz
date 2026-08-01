# RAAZ Implementation Walkthrough

This document summarizes the completed implementation tasks and how to verify them.

## Prerequisites

1. **Flutter SDK** 3.11+ with Dart 3.x
2. **Supabase project** with credentials in `lib/core/supabase_config.dart`
3. Run SQL migrations in order:
   - `supabase/schema.sql`
   - `supabase/phase2_migration.sql`
   - `supabase/phase3_migration.sql`

## Phase 1: Database & Supabase Integration

`supabase/phase3_migration.sql` adds:

| Table | Purpose |
|-------|---------|
| `achievements` | Badge definitions (slug, title, XP, requirements) |
| `user_achievements` | Per-user progress and unlock timestamps |
| `daily_challenges` | Daily prompt/challenge content |
| `reported_posts` | User-facing report status tracking |
| `drafts` | Optional cloud-synced post drafts |

Also seeds achievements, sample daily challenges, and `maintenance_mode` / `maintenance_message` in `app_config`.

## Phase 2: Core Feature Screens

| Screen | File | Entry Points |
|--------|------|--------------|
| Search | `search_screen.dart` | Home feed search icon |
| Search Results | `search_results_screen.dart` | Submit search query |
| Edit Post | `edit_post_screen.dart` | Post details / My Posts |
| Draft Manager | `draft_manager_screen.dart` | My Posts → Drafts tab |
| Daily Challenge | `daily_challenge_screen.dart` | Settings, Trending fire icon |
| Achievements | `achievements_screen.dart` | Settings, Anonymous Profile |
| AI Writing Assistant | `ai_writing_assistant_screen.dart` | Create Post flow |
| Anonymous Chat | `anonymous_chat_screen.dart` | (Coming soon UI) |

## Phase 3: Settings & Utility Screens

| Screen | File | Wired From |
|--------|------|------------|
| Language | `language_screen.dart` | Settings → Language |
| Notification Settings | `notification_settings_screen.dart` | Settings → Notifications |
| Data & Storage | `data_storage_screen.dart` | Settings → Data & Storage |
| Permissions Center | `permissions_center_screen.dart` | Settings → Permissions |
| Help Center | `help_center_screen.dart` | Settings help icon, Settings → Help Center |
| About | `about_screen.dart` | Settings → About RAAZ |
| Community Guidelines | `community_guidelines_screen.dart` | Settings, Help Center |
| Maintenance Mode | `maintenance_mode_screen.dart` | Splash (when `maintenance_mode=true`) |
| AdMob Preview | `admob_integration_screen.dart` | Settings → Ad Preferences |
| Rate & Share | `rate_share_app_screen.dart` | Settings → Rate & Share |
| Reported Posts Status | `reported_posts_status_screen.dart` | Settings → Reported Posts |

## Phase 4: Navigation Wiring

- **Settings** — all utility screens linked with `Navigator.push`
- **Home Feed** — search and notifications icons
- **Trending** — daily challenge and notifications icons
- **Anonymous Profile** — “View All Achievements” button
- **My Posts** — Drafts tab opens Draft Manager
- **Splash** — maintenance check + anonymous auth on return visits
- **Continue as Guest** — calls `AuthService.ensureSignedIn()` before entering app
- **Post reporting** — `PostRepository.reportPost()` writes to `reported_posts`

## Verification Steps

### 1. Static analysis

```bash
cd raaz_app
flutter pub get
flutter analyze
```

### 2. Run the app

```bash
flutter run
```

### 3. Manual test checklist

- [ ] Splash → onboarding → guest sign-in → home feed
- [ ] Home feed search icon → search → results screen
- [ ] Settings → each menu item opens correct screen
- [ ] Settings help icon → Help Center
- [ ] Trending fire icon → Daily Challenge (loads from Supabase)
- [ ] Settings → Achievements (loads badges from Supabase)
- [ ] Report a post → Settings → Reported Posts shows status
- [ ] My Posts → Drafts → Draft Manager
- [ ] Profile → View All Achievements

### 4. Enable maintenance mode (optional)

In Supabase SQL Editor:

```sql
update app_config set value = 'true' where key = 'maintenance_mode';
```

Restart app — should show `MaintenanceModeScreen`. Set back to `'false'` to resume.

## File Structure (new screens)

```
lib/
├── about_screen.dart
├── achievements_screen.dart
├── admob_integration_screen.dart
├── community_guidelines_screen.dart
├── daily_challenge_screen.dart
├── data_storage_screen.dart
├── help_center_screen.dart
├── language_screen.dart
├── maintenance_mode_screen.dart
├── notification_settings_screen.dart
├── permissions_center_screen.dart
├── rate_share_app_screen.dart
├── reported_posts_status_screen.dart
├── search_results_screen.dart
└── search_screen.dart
```

## Notes

- Local drafts remain in SQLite via `DraftDatabaseService`; Supabase `drafts` table is for optional cloud backup.
- `AchievementsScreen` falls back gracefully if Supabase tables are not yet migrated.
- AdMob screen is a UI preview only — SDK integration is planned for Open Beta.
