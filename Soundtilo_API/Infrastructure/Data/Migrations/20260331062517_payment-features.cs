using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Infrastructure.Data.Migrations
{
    /// <inheritdoc />
    public partial class paymentfeatures : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "stripe_invoice_id",
                table: "payment_transactions");

            migrationBuilder.RenameColumn(
                name: "stripe_customer_id",
                table: "users",
                newName: "vnpay_customer_id");

            migrationBuilder.RenameColumn(
                name: "stripe_subscription_id",
                table: "subscriptions",
                newName: "vnpay_order_info");

            migrationBuilder.RenameIndex(
                name: "IX_subscriptions_stripe_subscription_id",
                table: "subscriptions",
                newName: "IX_subscriptions_vnpay_order_info");

            migrationBuilder.RenameColumn(
                name: "stripe_price_id",
                table: "subscription_plans",
                newName: "plan_code");

            migrationBuilder.RenameColumn(
                name: "stripe_payment_intent_id",
                table: "payment_transactions",
                newName: "vnp_transaction_no");

            migrationBuilder.AddColumn<string>(
                name: "vnp_response_code",
                table: "payment_transactions",
                type: "character varying(10)",
                maxLength: 10,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "vnp_txn_ref",
                table: "payment_transactions",
                type: "character varying(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "vnp_response_code",
                table: "payment_transactions");

            migrationBuilder.DropColumn(
                name: "vnp_txn_ref",
                table: "payment_transactions");

            migrationBuilder.RenameColumn(
                name: "vnpay_customer_id",
                table: "users",
                newName: "stripe_customer_id");

            migrationBuilder.RenameColumn(
                name: "vnpay_order_info",
                table: "subscriptions",
                newName: "stripe_subscription_id");

            migrationBuilder.RenameIndex(
                name: "IX_subscriptions_vnpay_order_info",
                table: "subscriptions",
                newName: "IX_subscriptions_stripe_subscription_id");

            migrationBuilder.RenameColumn(
                name: "plan_code",
                table: "subscription_plans",
                newName: "stripe_price_id");

            migrationBuilder.RenameColumn(
                name: "vnp_transaction_no",
                table: "payment_transactions",
                newName: "stripe_payment_intent_id");

            migrationBuilder.AddColumn<string>(
                name: "stripe_invoice_id",
                table: "payment_transactions",
                type: "character varying(255)",
                maxLength: 255,
                nullable: true);
        }
    }
}
