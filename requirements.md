Building a posting/feed system with Supabase using Copilot.

Requirements:
1. Feed source:
- Read posts from Supabase Storage bucket "User Posts"
- Folder format: {userId}/
- File naming format: {timestamp}_{index}.jpg
- Group files with the same timestamp as one post
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
- Resolve author from the storage folder user_id
- Fetch username + profile picture data from the public user table by user_id
- If username is missing, fallback to shortened id format: user_{first8chars}
- Avatar fallback order:
  - user.profile_pic_url if present
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


Feed source
  - Read post files from Supabase Storage bucket `User Posts` organized by folder `{userId}/`.
  - Parse file names `{timestamp}_{index}.jpg` and group files that share the same `timestamp` into a single post object.
  - Sort post groups newest-first by `timestamp` and sort images within each post by `index`.
  - Provide a lightweight loader that pages results and refreshes when new uploads are detected.

Post card UI (`FeedPostCard`)
  - Render avatar, username, relative timestamp, a square (1:1) image carousel, and an action row beneath the image.
  - Action row layout: left-aligned Like and Comment icons (no labels), right-aligned Share icon.
  - Limit card width on wide screens so layout remains phone-like; center card horizontally when constrained.
  - Support multiple images via `PageView`, show page indicators for >1 image.

Timestamps
  - Implement a `formatTimeAgo(DateTime)` utility with rules: <60s => `Xs ago`; <60m => `Xm ago`; <24h => `Xh ago`; <7d => `Xd ago`; else `dd/mm/yy`.
  - Use this utility in feed cards and detail views to keep timestamps consistent.

Identity resolution
  - Determine `userId` from the storage folder path for a post.
  - Query the public users table for `username` and `profile_pic_url` by `userId`.
  - Fallback `username` to `user_{first8chars}` when missing.
  - Avatar selection order: `user.profile_pic_url` → Avatars bucket public URL `{userId}/avatar.jpg` → default person icon.
  - All lookups must handle missing data and network errors gracefully.

Auth behavior
  - Allow feed read access to unauthenticated users in the UI.
  - Restrict create/upload actions to authenticated users; show `showAppMessage` prompting sign-in and navigate to `/login` when unauthenticated users attempt to create.

Upload behavior
  - Multi-image selection and local cropping per image.
  - Write files to `User Posts` storage using path pattern `{userId}/{timestamp}_{index}.jpg`.
  - After uploading media, attempt to insert a `post` metadata row including `storage_key`, `user_id`, `media_url` (first image), `caption`, and `created_at` — handle cases where DB insert fails but files uploaded.
  - Signal success to the feed (close upload screen, trigger refresh) and surface errors via `showAppMessage`.

Post upload UI
  - Page title: "Create New Post"; AppBar follows app theme (dark background, white title/icons, no elevation).
  - Image grid: add tile for selecting images, thumbnails for selected images with edit (crop) and remove actions.
  - Caption field: use app's dark rounded input style.
  - Upload button: placed to the right of the caption, uses app accent color, shows a white spinner while uploading, and is disabled during upload.

Image cropper (`CropPage`)
  - Provide an interactive cropper (based on `crop_your_image`) that supports square and free aspect ratios.
  - Controls: Confirm (crop), Cancel, Reset, and quick aspect toggles; return cropped bytes via `Navigator.pop(cropped)`.

Like system
  - Optimistic UI: toggle heart state and update like count immediately on tap.
  - Persist by inserting into `post_likes` (for storage-backed posts insert with `post_id: null` and `storage_key`).
  - On failure, revert local state and show an error via `showAppMessage`; log DB/RLS errors for debugging.

Comments UI
  - Implement slide-up comments sheet using `DraggableScrollableSheet` that subscribes to `comments` for a post via Supabase realtime.
  - Support optimistic comment posting (append immediately, remove on failure), autoscroll to newest comment, and hide input when user is not authenticated.
  - Resolve commenter display names and avatars using a repository helper to avoid repeated queries.

Post detail & caption UX
  - Full post page showing the caption prominently above the comments list.
  - Reuse collapsible caption logic from feed (truncate to ~50 chars with inline "More"/"Less").
  - Comments area uses the same repository and UI tile (`PostCommentTile`) as the sheet.
  - Comment input uses dark rounded style and accent send button.

Collapsible captions
  - Truncate caption text around 50 characters in feed cards and show inline "More". When expanded show full caption and inline "Less".
  - Implement using `RichText` and `TapGestureRecognizer` for the inline interaction.

Realtime subscriptions
  - Use `Supabase.instance.client.from('comments').stream(primaryKey: ['comments_id']).eq('storage_key', storageKey)` to subscribe to comment changes.
  - Update UI reactively and ensure subscriptions are cleaned up on widget dispose.

Optimistic UI patterns
  - For likes and comments: update local UI state first, send DB request, and rollback on failure.
  - Provide visual feedback (disabled states, spinners) and use `showAppMessage` on errors.

showAppMessage helper
  - Implement overlay toast: 300ms initial delay, 1s visible, 200ms fade; support `error` flag to change color.
  - Replace existing `SnackBar` uses in pages with this helper for consistent UX.

Repositories
  - Add `SupabaseCommentRepository` with `fetchComments(storageKey)` and `addComment(storageKey, userId, text)` methods.
  - Repository should also resolve commenter display name and profile image URL, caching where applicable.

Storage-key convention
  - Use a `storage_key` text column for storage-based posts; client inserts use `storage_key` and set relational `post_id` to `null` when appropriate.
  - Ensure client queries and realtime streams can filter on `storage_key`.

Code-quality checklist
  - Keep `HomePage` focused on data fetching and navigation; move UI into small, testable widgets.
  - Add robust null and error handling for network/storage/profile lookups.
  - Add concise inline comments to clarify non-obvious logic.
  - Run `flutter analyze` and `flutter test` before merging changes.

Implement all required files and edits step by step, verifying there are no errors.
