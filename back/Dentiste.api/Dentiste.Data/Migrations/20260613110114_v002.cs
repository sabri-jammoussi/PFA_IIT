using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Dentiste.Data.Migrations
{
    /// <inheritdoc />
    public partial class v002 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ARTICLE",
                columns: table => new
                {
                    ART_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ART_NOM = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    ART_DESCRIPTION = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ART_QUANTITE_EN_STOCK = table.Column<int>(type: "int", nullable: false),
                    ART_SEUIL_ALERTE = table.Column<int>(type: "int", nullable: false),
                    ART_UNITE = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ARTICLE", x => x.ART_ID);
                });

            migrationBuilder.CreateTable(
                name: "RECETTE_ACTE",
                columns: table => new
                {
                    REC_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    REC_QUANTITE_REQUISE = table.Column<int>(type: "int", nullable: false),
                    REC_ACTE_MEDICAL_ID = table.Column<int>(type: "int", nullable: false),
                    REC_ARTICLE_ID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RECETTE_ACTE", x => x.REC_ID);
                    table.ForeignKey(
                        name: "FK_RECETTE_ACTE_ACTE_MEDICAL_REC_ACTE_MEDICAL_ID",
                        column: x => x.REC_ACTE_MEDICAL_ID,
                        principalTable: "ACTE_MEDICAL",
                        principalColumn: "ACT_ID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_RECETTE_ACTE_ARTICLE_REC_ARTICLE_ID",
                        column: x => x.REC_ARTICLE_ID,
                        principalTable: "ARTICLE",
                        principalColumn: "ART_ID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_RECETTE_ACTE_REC_ACTE_MEDICAL_ID",
                table: "RECETTE_ACTE",
                column: "REC_ACTE_MEDICAL_ID");

            migrationBuilder.CreateIndex(
                name: "IX_RECETTE_ACTE_REC_ARTICLE_ID",
                table: "RECETTE_ACTE",
                column: "REC_ARTICLE_ID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "RECETTE_ACTE");

            migrationBuilder.DropTable(
                name: "ARTICLE");
        }
    }
}
