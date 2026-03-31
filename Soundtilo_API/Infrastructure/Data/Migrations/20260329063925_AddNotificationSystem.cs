using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddNotificationSystem : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "notification_templates",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    type = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    title_template = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    message_template = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false),
                    metadata_template_json = table.Column<string>(type: "jsonb", nullable: true),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    created_by_admin_id = table.Column<Guid>(type: "uuid", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_notification_templates", x => x.id);
                    table.ForeignKey(
                        name: "FK_notification_templates_users_created_by_admin_id",
                        column: x => x.created_by_admin_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "notifications",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    created_by_admin_id = table.Column<Guid>(type: "uuid", nullable: true),
                    type = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    source = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    message = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false),
                    metadata_json = table.Column<string>(type: "jsonb", nullable: true),
                    is_read = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    read_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    expires_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_notifications", x => x.id);
                    table.ForeignKey(
                        name: "FK_notifications_users_created_by_admin_id",
                        column: x => x.created_by_admin_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_notifications_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "notification_schedules",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    template_id = table.Column<Guid>(type: "uuid", nullable: true),
                    target_user_id = table.Column<Guid>(type: "uuid", nullable: true),
                    created_by_admin_id = table.Column<Guid>(type: "uuid", nullable: false),
                    type = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    source = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    target_scope = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    status = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    title = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    message = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false),
                    metadata_json = table.Column<string>(type: "jsonb", nullable: true),
                    scheduled_for = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    processed_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    attempts = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
                    last_error = table.Column<string>(type: "character varying(1500)", maxLength: 1500, nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_notification_schedules", x => x.id);
                    table.ForeignKey(
                        name: "FK_notification_schedules_notification_templates_template_id",
                        column: x => x.template_id,
                        principalTable: "notification_templates",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_notification_schedules_users_created_by_admin_id",
                        column: x => x.created_by_admin_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_notification_schedules_users_target_user_id",
                        column: x => x.target_user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "notification_delivery_logs",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    notification_id = table.Column<Guid>(type: "uuid", nullable: true),
                    schedule_id = table.Column<Guid>(type: "uuid", nullable: true),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    channel = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    status = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    error_message = table.Column<string>(type: "character varying(1500)", maxLength: 1500, nullable: true),
                    delivered_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_notification_delivery_logs", x => x.id);
                    table.ForeignKey(
                        name: "FK_notification_delivery_logs_notification_schedules_schedule_~",
                        column: x => x.schedule_id,
                        principalTable: "notification_schedules",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_notification_delivery_logs_notifications_notification_id",
                        column: x => x.notification_id,
                        principalTable: "notifications",
                        principalColumn: "id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_notification_delivery_logs_users_user_id",
                        column: x => x.user_id,
                        principalTable: "users",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_notification_delivery_logs_delivered_at",
                table: "notification_delivery_logs",
                column: "delivered_at");

            migrationBuilder.CreateIndex(
                name: "IX_notification_delivery_logs_notification_id",
                table: "notification_delivery_logs",
                column: "notification_id");

            migrationBuilder.CreateIndex(
                name: "IX_notification_delivery_logs_schedule_id",
                table: "notification_delivery_logs",
                column: "schedule_id");

            migrationBuilder.CreateIndex(
                name: "IX_notification_delivery_logs_user_id_delivered_at",
                table: "notification_delivery_logs",
                columns: new[] { "user_id", "delivered_at" });

            migrationBuilder.CreateIndex(
                name: "IX_notification_schedules_created_by_admin_id",
                table: "notification_schedules",
                column: "created_by_admin_id");

            migrationBuilder.CreateIndex(
                name: "IX_notification_schedules_status_scheduled_for",
                table: "notification_schedules",
                columns: new[] { "status", "scheduled_for" });

            migrationBuilder.CreateIndex(
                name: "IX_notification_schedules_target_user_id",
                table: "notification_schedules",
                column: "target_user_id");

            migrationBuilder.CreateIndex(
                name: "IX_notification_schedules_template_id",
                table: "notification_schedules",
                column: "template_id");

            migrationBuilder.CreateIndex(
                name: "IX_notification_templates_created_by_admin_id",
                table: "notification_templates",
                column: "created_by_admin_id");

            migrationBuilder.CreateIndex(
                name: "IX_notification_templates_is_active_updated_at",
                table: "notification_templates",
                columns: new[] { "is_active", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "IX_notification_templates_name",
                table: "notification_templates",
                column: "name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_notifications_created_by_admin_id",
                table: "notifications",
                column: "created_by_admin_id");

            migrationBuilder.CreateIndex(
                name: "IX_notifications_expires_at",
                table: "notifications",
                column: "expires_at");

            migrationBuilder.CreateIndex(
                name: "IX_notifications_user_id_is_read_created_at",
                table: "notifications",
                columns: new[] { "user_id", "is_read", "created_at" });

        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "notification_delivery_logs");

            migrationBuilder.DropTable(
                name: "notification_schedules");

            migrationBuilder.DropTable(
                name: "notifications");

            migrationBuilder.DropTable(
                name: "notification_templates");
        }
    }
}
