using System;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    [DbContext(typeof(SoundtiloDbContext))]
    [Migration("20260329064050_WaitlistSchemaNormalization")]
    public partial class WaitlistSchemaNormalization : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Intentionally no-op.
            // Waitlist schema was already created in normalized form by AddWaitlistTable
            // (Waitlists/WaitlistTracks). This migration came from model drift and must not
            // attempt to mutate non-existent legacy tables (Waitlist/WaitlistTrack).
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Intentionally no-op.
        }
    }
}
