using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Dentiste.Data.Migrations
{
    /// <inheritdoc />
    public partial class v003 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "NOTIFICATION",
                columns: table => new
                {
                    NTF_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    NTF_NATURE = table.Column<int>(type: "int", nullable: false),
                    NTF_ENTITY_ID = table.Column<int>(type: "int", nullable: false),
                    NTF_ENTITY_CODE = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    NTF_TITLE = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    NTF_NOTE = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    NO_DOMAINE = table.Column<int>(type: "int", nullable: false),
                    USR_ID_CREATED_BY = table.Column<int>(type: "int", nullable: false),
                    USR_ID_CREATED_TO = table.Column<int>(type: "int", nullable: false),
                    NTF_DATE = table.Column<DateTime>(type: "datetime2", nullable: false),
                    NTF_SEEN = table.Column<bool>(type: "bit", nullable: false),
                    NTF_TYPE = table.Column<int>(type: "int", nullable: false),
                    NTF_DEMANDE_ID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_NOTIFICATION", x => x.NTF_ID);
                    table.ForeignKey(
                        name: "FK_NOTIFICATION_USER_USR_ID_CREATED_BY",
                        column: x => x.USR_ID_CREATED_BY,
                        principalTable: "USER",
                        principalColumn: "USR_ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_NOTIFICATION_USER_USR_ID_CREATED_TO",
                        column: x => x.USR_ID_CREATED_TO,
                        principalTable: "USER",
                        principalColumn: "USR_ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_NOTIFICATION_USR_ID_CREATED_BY",
                table: "NOTIFICATION",
                column: "USR_ID_CREATED_BY");

            migrationBuilder.CreateIndex(
                name: "IX_NOTIFICATION_USR_ID_CREATED_TO",
                table: "NOTIFICATION",
                column: "USR_ID_CREATED_TO");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "NOTIFICATION");
        }
    }
}
