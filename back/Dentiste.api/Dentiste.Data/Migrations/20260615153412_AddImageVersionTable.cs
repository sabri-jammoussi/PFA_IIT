using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Dentiste.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddImageVersionTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "IMAGE_VERSION",
                columns: table => new
                {
                    IV_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    IV_IM_ID = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    IV_VERSION = table.Column<long>(type: "bigint", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_IMAGE_VERSION", x => x.IV_ID);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "IMAGE_VERSION");
        }
    }
}
