# Flutter client for WordPress + BuddyPress (Commons in a Box)

Lightweight Flutter mobile app that connects to a WordPress backend running BuddyPress / Commons in a Box (CBOX).

## Goals / MVP
- User authentication (JWT)
- View user profile
- Activity feed
- List groups and join/leave
- Create simple posts (text/media)
- Offline caching & secure token storage (later)

## Prerequisites (backend)
- WordPress with BuddyPress + Commons in a Box
- REST API enabled (default in WP)
- Recommended auth plugin: JWT Authentication for WP REST API (or OAuth plugin)
  - For JWT plugin, you should have an endpoint: `POST /wp-json/jwt-auth/v1/token`
- BuddyPress REST endpoints:
  - Members: `/wp-json/buddypress/v1/members`
  - Groups: `/wp-json/buddypress/v1/groups`
  - Activity: `/wp-json/buddypress/v1/activity`
- Configure CORS and HTTPS in WP so the mobile app can call REST endpoints.

## Local dev / Quickstart
1. Install Flutter SDK (stable)
2. Clone this repo
3. Update backend base URL in `lib/src/services/api_service.dart` (or use env/config)
4. flutter pub get
5. Run on device: `flutter run`

## Architecture & Libraries
- HTTP: `http` package. Consider `dio` later for advanced features.
- State management: `provider` (simple), can switch to Riverpod/Bloc later.
- Secure token storage: `flutter_secure_storage`
- Image caching: `cached_network_image`
- Connectivity: `connectivity_plus`

## Next steps / Roadmap
- Add Registration, Forgot password flows
- Implement profile editing + avatar upload
- Activity posting, media upload
- Group membership and group wall
- Add tests and CI (GitHub Actions)
- Mobile build configuration for Android/iOS (App IDs, entitlements)

## How to contribute
- Create issues for each feature or bug.
- Use feature branches and open PRs.