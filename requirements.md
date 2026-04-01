Building a posting/feed system with Supabase using Copilot.

Requirements:
1. Feed source:
- Read posts from Supabase Storage bucket "User Posts"
- Folder format: {userId}/
- File naming format: {timestamp}_{index}.jpg
- Group files with same timestamp as one post
- Sort post groups newest first
- Sort images within a post by index

2. Post card UI:
- Show avatar, username, relative timestamp, image carousel, and action row
- Timestamp format:
  - <60s => "Xs ago"
  - <60m => "Xm ago"
  - <24h => "Xh ago"
  - <7d => "Xd ago"
  - >=7d => dd/mm/yy
- Image area must be square (1:1)
- Card max width should stay phone-like on large screens
- Action row below image:
  - Like + Comment on left
  - Share pinned to right
  - No labels

3. Identity and profile:
- Resolve author from folder userId
- Fetch username + avatar_url from "profiles" table by id
- If username missing, fallback to shortened id format: user_{first8chars}
- Avatar fallback order:
  - profiles.avatar_url if present
  - else public URL from Avatars bucket: {userId}/avatar.jpg
  - else person icon

4. Auth behavior:
- Anyone (including logged-out users) can view feed
- Only logged-in users can create posts
- If not logged in and user taps create, show message and redirect to login

5. Upload behavior:
- Multi-image upload supported
- Store to "User Posts" as {userId}/{timestamp}_{index}.jpg
- On successful upload: close upload screen and refresh feed
- Add loading/error handling

6. Code quality:
- Keep HomePage focused on data fetching and navigation
- Move post card UI to a separate widget file
- Keep robust null/error handling for network/storage/profile lookup
- Preserve current app theme and styling conventions
- Ensure code compiles with no Dart analyzer errors

Implement all required files and edits step by step, verifying there are no errors.