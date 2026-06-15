using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Dentiste.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddCabinetSmtpConfiguration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "CONFIGURATION_CABINET",
                columns: table => new
                {
                    CFG_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CFG_CABINET_ID = table.Column<int>(type: "int", nullable: false),
                    CFG_SMTP_HOST = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    CFG_SMTP_PORT = table.Column<int>(type: "int", nullable: true),
                    CFG_SMTP_USERNAME = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    CFG_SMTP_PASSWORD = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    CFG_SMTP_SSL = table.Column<bool>(type: "bit", nullable: true),
                    CFG_SENDER_NAME = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CONFIGURATION_CABINET", x => x.CFG_ID);
                    table.ForeignKey(
                        name: "FK_CONFIGURATION_CABINET_CABINET_CFG_CABINET_ID",
                        column: x => x.CFG_CABINET_ID,
                        principalTable: "CABINET",
                        principalColumn: "CAB_ID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_CONFIGURATION_CABINET_CFG_CABINET_ID",
                table: "CONFIGURATION_CABINET",
                column: "CFG_CABINET_ID",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CONFIGURATION_CABINET");
        }
    }
}
