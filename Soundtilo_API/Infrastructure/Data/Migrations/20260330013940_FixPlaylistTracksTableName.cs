using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class FixPlaylistTracksTableName : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_PlaylistTracks_playlists_PlaylistId",
                table: "PlaylistTracks");

            migrationBuilder.DropPrimaryKey(
                name: "PK_PlaylistTracks",
                table: "PlaylistTracks");

            migrationBuilder.DropIndex(
                name: "IX_PlaylistTracks_PlaylistId",
                table: "PlaylistTracks");

            migrationBuilder.RenameTable(
                name: "PlaylistTracks",
                newName: "playlist_tracks");

            migrationBuilder.RenameColumn(
                name: "Position",
                table: "playlist_tracks",
                newName: "position");

            migrationBuilder.RenameColumn(
                name: "Id",
                table: "playlist_tracks",
                newName: "id");

            migrationBuilder.RenameColumn(
                name: "TrackExternalId",
                table: "playlist_tracks",
                newName: "track_external_id");

            migrationBuilder.RenameColumn(
                name: "PlaylistId",
                table: "playlist_tracks",
                newName: "playlist_id");

            migrationBuilder.RenameColumn(
                name: "AddedAt",
                table: "playlist_tracks",
                newName: "added_at");

            migrationBuilder.AlterColumn<string>(
                name: "track_external_id",
                table: "playlist_tracks",
                type: "character varying(255)",
                maxLength: 255,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddPrimaryKey(
                name: "PK_playlist_tracks",
                table: "playlist_tracks",
                column: "id");

            migrationBuilder.CreateIndex(
                name: "IX_playlist_tracks_playlist_id_track_external_id",
                table: "playlist_tracks",
                columns: new[] { "playlist_id", "track_external_id" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_playlist_tracks_playlists_playlist_id",
                table: "playlist_tracks",
                column: "playlist_id",
                principalTable: "playlists",
                principalColumn: "id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_playlist_tracks_playlists_playlist_id",
                table: "playlist_tracks");

            migrationBuilder.DropPrimaryKey(
                name: "PK_playlist_tracks",
                table: "playlist_tracks");

            migrationBuilder.DropIndex(
                name: "IX_playlist_tracks_playlist_id_track_external_id",
                table: "playlist_tracks");

            migrationBuilder.RenameTable(
                name: "playlist_tracks",
                newName: "PlaylistTracks");

            migrationBuilder.RenameColumn(
                name: "position",
                table: "PlaylistTracks",
                newName: "Position");

            migrationBuilder.RenameColumn(
                name: "id",
                table: "PlaylistTracks",
                newName: "Id");

            migrationBuilder.RenameColumn(
                name: "track_external_id",
                table: "PlaylistTracks",
                newName: "TrackExternalId");

            migrationBuilder.RenameColumn(
                name: "playlist_id",
                table: "PlaylistTracks",
                newName: "PlaylistId");

            migrationBuilder.RenameColumn(
                name: "added_at",
                table: "PlaylistTracks",
                newName: "AddedAt");

            migrationBuilder.AlterColumn<string>(
                name: "TrackExternalId",
                table: "PlaylistTracks",
                type: "text",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "character varying(255)",
                oldMaxLength: 255);

            migrationBuilder.AddPrimaryKey(
                name: "PK_PlaylistTracks",
                table: "PlaylistTracks",
                column: "Id");

            migrationBuilder.CreateIndex(
                name: "IX_PlaylistTracks_PlaylistId",
                table: "PlaylistTracks",
                column: "PlaylistId");

            migrationBuilder.AddForeignKey(
                name: "FK_PlaylistTracks_playlists_PlaylistId",
                table: "PlaylistTracks",
                column: "PlaylistId",
                principalTable: "playlists",
                principalColumn: "id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
