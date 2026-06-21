using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Dentiste.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddPasswordResetToken : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "USR_RESET_TOKEN",
                table: "USER",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "USR_RESET_TOKEN_EXPIRES",
                table: "USER",
                type: "datetime2",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "USR_RESET_TOKEN",
                table: "USER");

            migrationBuilder.DropColumn(
                name: "USR_RESET_TOKEN_EXPIRES",
                table: "USER");
        }
    }
}
