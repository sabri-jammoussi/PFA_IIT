using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Dentiste.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddCloudinaryFolderToCabinet : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Column already exists in the database
            /*migrationBuilder.AddColumn<string>(
                name: "CAB_CLOUDINARY_FOLDER",
                table: "CABINET",
                type: "nvarchar(max)",
                nullable: true);*/
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CAB_CLOUDINARY_FOLDER",
                table: "CABINET");
        }
    }
}
