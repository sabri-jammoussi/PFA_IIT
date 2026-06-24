using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Dentiste.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddConsommationArticleAndFactureConsultation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "FAC_CONSULTATION_ID",
                table: "FACTURE",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "CONSOMMATION_ARTICLE",
                columns: table => new
                {
                    CSM_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CSM_QUANTITE = table.Column<int>(type: "int", nullable: false),
                    CSM_DATE = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CSM_CONSULTATION_ID = table.Column<int>(type: "int", nullable: false),
                    CSM_ARTICLE_ID = table.Column<int>(type: "int", nullable: false),
                    CSM_CABINET_ID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CONSOMMATION_ARTICLE", x => x.CSM_ID);
                    table.ForeignKey(
                        name: "FK_CONSOMMATION_ARTICLE_ARTICLE_CSM_ARTICLE_ID",
                        column: x => x.CSM_ARTICLE_ID,
                        principalTable: "ARTICLE",
                        principalColumn: "ART_ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_CONSOMMATION_ARTICLE_CABINET_CSM_CABINET_ID",
                        column: x => x.CSM_CABINET_ID,
                        principalTable: "CABINET",
                        principalColumn: "CAB_ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_CONSOMMATION_ARTICLE_CONSULTATION_CSM_CONSULTATION_ID",
                        column: x => x.CSM_CONSULTATION_ID,
                        principalTable: "CONSULTATION",
                        principalColumn: "CON_ID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_FACTURE_FAC_CONSULTATION_ID",
                table: "FACTURE",
                column: "FAC_CONSULTATION_ID");

            migrationBuilder.CreateIndex(
                name: "IX_CONSOMMATION_ARTICLE_CSM_ARTICLE_ID",
                table: "CONSOMMATION_ARTICLE",
                column: "CSM_ARTICLE_ID");

            migrationBuilder.CreateIndex(
                name: "IX_CONSOMMATION_ARTICLE_CSM_CABINET_ID",
                table: "CONSOMMATION_ARTICLE",
                column: "CSM_CABINET_ID");

            migrationBuilder.CreateIndex(
                name: "IX_CONSOMMATION_ARTICLE_CSM_CONSULTATION_ID",
                table: "CONSOMMATION_ARTICLE",
                column: "CSM_CONSULTATION_ID");

            migrationBuilder.AddForeignKey(
                name: "FK_FACTURE_CONSULTATION_FAC_CONSULTATION_ID",
                table: "FACTURE",
                column: "FAC_CONSULTATION_ID",
                principalTable: "CONSULTATION",
                principalColumn: "CON_ID",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_FACTURE_CONSULTATION_FAC_CONSULTATION_ID",
                table: "FACTURE");

            migrationBuilder.DropTable(
                name: "CONSOMMATION_ARTICLE");

            migrationBuilder.DropIndex(
                name: "IX_FACTURE_FAC_CONSULTATION_ID",
                table: "FACTURE");

            migrationBuilder.DropColumn(
                name: "FAC_CONSULTATION_ID",
                table: "FACTURE");
        }
    }
}
