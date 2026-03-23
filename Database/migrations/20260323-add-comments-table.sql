-- Migration: Add comments table for track comments feature
-- Target: Supabase (PostgreSQL)
-- Date: 2026-03-23

CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    track_external_id VARCHAR(255) NOT NULL,
    content VARCHAR(500) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fetching comments by track, ordered by newest first
CREATE INDEX IF NOT EXISTS idx_comments_track_created
    ON comments (track_external_id, created_at DESC);

-- Index for user's own comments (for delete authorization lookups)
CREATE INDEX IF NOT EXISTS idx_comments_user_id
    ON comments (user_id);
