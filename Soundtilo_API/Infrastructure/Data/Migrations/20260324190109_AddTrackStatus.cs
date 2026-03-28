using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddTrackStatus : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Safely add status column to cached_tracks
            migrationBuilder.Sql("ALTER TABLE cached_tracks ADD COLUMN IF NOT EXISTS status integer NOT NULL DEFAULT 0;");
            
            // If other tables like album_tracks are needed, add them safely too
            migrationBuilder.Sql(@"
                CREATE TABLE IF NOT EXISTS album_tracks (
                    id uuid PRIMARY KEY,
                    album_id uuid NOT NULL REFERENCES albums(id) ON DELETE CASCADE,
                    track_external_id varchar(255) NOT NULL,
                    position integer NOT NULL,
                    added_at timestamp with time zone NOT NULL
                );
                CREATE UNIQUE INDEX IF NOT EXISTS IX_album_tracks_album_id_track_external_id ON album_tracks (album_id, track_external_id);
            ");

            // Ensure role exists in users
            migrationBuilder.Sql("ALTER TABLE users ADD COLUMN IF NOT EXISTS role text NOT NULL DEFAULT 'User';");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Manual cleanup if needed, but keeping it empty for safety with raw SQL migration
        }
    }
}
