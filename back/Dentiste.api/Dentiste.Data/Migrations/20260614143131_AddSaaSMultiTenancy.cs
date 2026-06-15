using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Dentiste.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddSaaSMultiTenancy : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "CABINET",
                columns: table => new
                {
                    CAB_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CAB_NOM = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    CAB_ADRESSE = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CAB_TELEPHONE = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CAB_CREATED_AT = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CAB_IS_ACTIVE = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CABINET", x => x.CAB_ID);
                });

            // Seed default cabinet so existing data has a valid foreign key target
            migrationBuilder.Sql("SET IDENTITY_INSERT [CABINET] ON;");
            migrationBuilder.Sql("INSERT INTO [CABINET] (CAB_ID, CAB_NOM, CAB_ADRESSE, CAB_TELEPHONE, CAB_CREATED_AT, CAB_IS_ACTIVE) VALUES (1, 'Clinique Dentaire Sfax', 'Route de Tunis Km 1, Sfax', '74111222', GETDATE(), 1);");
            migrationBuilder.Sql("SET IDENTITY_INSERT [CABINET] OFF;");

            migrationBuilder.AddColumn<int>(
                name: "USR_CABINET_ID",
                table: "USER",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "SOI_CABINET_ID",
                table: "SOIN_EFFECTUE",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<int>(
                name: "RDV_CABINET_ID",
                table: "RENDEZ_VOUS",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<int>(
                name: "REC_CABINET_ID",
                table: "RECETTE_ACTE",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<int>(
                name: "PAT_CABINET_ID",
                table: "PATIENT",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<int>(
                name: "PAI_CABINET_ID",
                table: "PAIEMENT",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<int>(
                name: "ORD_CABINET_ID",
                table: "ORDONNANCE",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<int>(
                name: "NTF_CABINET_ID",
                table: "NOTIFICATION",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<int>(
                name: "FAC_CABINET_ID",
                table: "FACTURE",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<int>(
                name: "CON_CABINET_ID",
                table: "CONSULTATION",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<int>(
                name: "AUD_CABINET_ID",
                table: "AUDIT_LOG",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ART_CABINET_ID",
                table: "ARTICLE",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<int>(
                name: "ACT_CABINET_ID",
                table: "ACTE_MEDICAL",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.CreateIndex(
                name: "IX_USER_USR_CABINET_ID",
                table: "USER",
                column: "USR_CABINET_ID");

            migrationBuilder.CreateIndex(
                name: "IX_SOIN_EFFECTUE_SOI_CABINET_ID",
                table: "SOIN_EFFECTUE",
                column: "SOI_CABINET_ID");

            migrationBuilder.CreateIndex(
                name: "IX_RENDEZ_VOUS_RDV_CABINET_ID",
                table: "RENDEZ_VOUS",
                column: "RDV_CABINET_ID");

            migrationBuilder.CreateIndex(
                name: "IX_RECETTE_ACTE_REC_CABINET_ID",
                table: "RECETTE_ACTE",
                column: "REC_CABINET_ID");

            migrationBuilder.CreateIndex(
                name: "IX_PATIENT_PAT_CABINET_ID",
                table: "PATIENT",
                column: "PAT_CABINET_ID");

            migrationBuilder.CreateIndex(
                name: "IX_PAIEMENT_PAI_CABINET_ID",
                table: "PAIEMENT",
                column: "PAI_CABINET_ID");

            migrationBuilder.CreateIndex(
                name: "IX_ORDONNANCE_ORD_CABINET_ID",
                table: "ORDONNANCE",
                column: "ORD_CABINET_ID");

            migrationBuilder.CreateIndex(
                name: "IX_NOTIFICATION_NTF_CABINET_ID",
                table: "NOTIFICATION",
                column: "NTF_CABINET_ID");

            migrationBuilder.CreateIndex(
                name: "IX_FACTURE_FAC_CABINET_ID",
                table: "FACTURE",
                column: "FAC_CABINET_ID");

            migrationBuilder.CreateIndex(
                name: "IX_CONSULTATION_CON_CABINET_ID",
                table: "CONSULTATION",
                column: "CON_CABINET_ID");

            migrationBuilder.CreateIndex(
                name: "IX_AUDIT_LOG_AUD_CABINET_ID",
                table: "AUDIT_LOG",
                column: "AUD_CABINET_ID");

            migrationBuilder.CreateIndex(
                name: "IX_ARTICLE_ART_CABINET_ID",
                table: "ARTICLE",
                column: "ART_CABINET_ID");

            migrationBuilder.CreateIndex(
                name: "IX_ACTE_MEDICAL_ACT_CABINET_ID",
                table: "ACTE_MEDICAL",
                column: "ACT_CABINET_ID");

            migrationBuilder.AddForeignKey(
                name: "FK_ACTE_MEDICAL_CABINET_ACT_CABINET_ID",
                table: "ACTE_MEDICAL",
                column: "ACT_CABINET_ID",
                principalTable: "CABINET",
                principalColumn: "CAB_ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_ARTICLE_CABINET_ART_CABINET_ID",
                table: "ARTICLE",
                column: "ART_CABINET_ID",
                principalTable: "CABINET",
                principalColumn: "CAB_ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_AUDIT_LOG_CABINET_AUD_CABINET_ID",
                table: "AUDIT_LOG",
                column: "AUD_CABINET_ID",
                principalTable: "CABINET",
                principalColumn: "CAB_ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_CONSULTATION_CABINET_CON_CABINET_ID",
                table: "CONSULTATION",
                column: "CON_CABINET_ID",
                principalTable: "CABINET",
                principalColumn: "CAB_ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_FACTURE_CABINET_FAC_CABINET_ID",
                table: "FACTURE",
                column: "FAC_CABINET_ID",
                principalTable: "CABINET",
                principalColumn: "CAB_ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_NOTIFICATION_CABINET_NTF_CABINET_ID",
                table: "NOTIFICATION",
                column: "NTF_CABINET_ID",
                principalTable: "CABINET",
                principalColumn: "CAB_ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_ORDONNANCE_CABINET_ORD_CABINET_ID",
                table: "ORDONNANCE",
                column: "ORD_CABINET_ID",
                principalTable: "CABINET",
                principalColumn: "CAB_ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_PAIEMENT_CABINET_PAI_CABINET_ID",
                table: "PAIEMENT",
                column: "PAI_CABINET_ID",
                principalTable: "CABINET",
                principalColumn: "CAB_ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_PATIENT_CABINET_PAT_CABINET_ID",
                table: "PATIENT",
                column: "PAT_CABINET_ID",
                principalTable: "CABINET",
                principalColumn: "CAB_ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_RECETTE_ACTE_CABINET_REC_CABINET_ID",
                table: "RECETTE_ACTE",
                column: "REC_CABINET_ID",
                principalTable: "CABINET",
                principalColumn: "CAB_ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_RENDEZ_VOUS_CABINET_RDV_CABINET_ID",
                table: "RENDEZ_VOUS",
                column: "RDV_CABINET_ID",
                principalTable: "CABINET",
                principalColumn: "CAB_ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_SOIN_EFFECTUE_CABINET_SOI_CABINET_ID",
                table: "SOIN_EFFECTUE",
                column: "SOI_CABINET_ID",
                principalTable: "CABINET",
                principalColumn: "CAB_ID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_USER_CABINET_USR_CABINET_ID",
                table: "USER",
                column: "USR_CABINET_ID",
                principalTable: "CABINET",
                principalColumn: "CAB_ID",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ACTE_MEDICAL_CABINET_ACT_CABINET_ID",
                table: "ACTE_MEDICAL");

            migrationBuilder.DropForeignKey(
                name: "FK_ARTICLE_CABINET_ART_CABINET_ID",
                table: "ARTICLE");

            migrationBuilder.DropForeignKey(
                name: "FK_AUDIT_LOG_CABINET_AUD_CABINET_ID",
                table: "AUDIT_LOG");

            migrationBuilder.DropForeignKey(
                name: "FK_CONSULTATION_CABINET_CON_CABINET_ID",
                table: "CONSULTATION");

            migrationBuilder.DropForeignKey(
                name: "FK_FACTURE_CABINET_FAC_CABINET_ID",
                table: "FACTURE");

            migrationBuilder.DropForeignKey(
                name: "FK_NOTIFICATION_CABINET_NTF_CABINET_ID",
                table: "NOTIFICATION");

            migrationBuilder.DropForeignKey(
                name: "FK_ORDONNANCE_CABINET_ORD_CABINET_ID",
                table: "ORDONNANCE");

            migrationBuilder.DropForeignKey(
                name: "FK_PAIEMENT_CABINET_PAI_CABINET_ID",
                table: "PAIEMENT");

            migrationBuilder.DropForeignKey(
                name: "FK_PATIENT_CABINET_PAT_CABINET_ID",
                table: "PATIENT");

            migrationBuilder.DropForeignKey(
                name: "FK_RECETTE_ACTE_CABINET_REC_CABINET_ID",
                table: "RECETTE_ACTE");

            migrationBuilder.DropForeignKey(
                name: "FK_RENDEZ_VOUS_CABINET_RDV_CABINET_ID",
                table: "RENDEZ_VOUS");

            migrationBuilder.DropForeignKey(
                name: "FK_SOIN_EFFECTUE_CABINET_SOI_CABINET_ID",
                table: "SOIN_EFFECTUE");

            migrationBuilder.DropForeignKey(
                name: "FK_USER_CABINET_USR_CABINET_ID",
                table: "USER");

            migrationBuilder.DropTable(
                name: "CABINET");

            migrationBuilder.DropIndex(
                name: "IX_USER_USR_CABINET_ID",
                table: "USER");

            migrationBuilder.DropIndex(
                name: "IX_SOIN_EFFECTUE_SOI_CABINET_ID",
                table: "SOIN_EFFECTUE");

            migrationBuilder.DropIndex(
                name: "IX_RENDEZ_VOUS_RDV_CABINET_ID",
                table: "RENDEZ_VOUS");

            migrationBuilder.DropIndex(
                name: "IX_RECETTE_ACTE_REC_CABINET_ID",
                table: "RECETTE_ACTE");

            migrationBuilder.DropIndex(
                name: "IX_PATIENT_PAT_CABINET_ID",
                table: "PATIENT");

            migrationBuilder.DropIndex(
                name: "IX_PAIEMENT_PAI_CABINET_ID",
                table: "PAIEMENT");

            migrationBuilder.DropIndex(
                name: "IX_ORDONNANCE_ORD_CABINET_ID",
                table: "ORDONNANCE");

            migrationBuilder.DropIndex(
                name: "IX_NOTIFICATION_NTF_CABINET_ID",
                table: "NOTIFICATION");

            migrationBuilder.DropIndex(
                name: "IX_FACTURE_FAC_CABINET_ID",
                table: "FACTURE");

            migrationBuilder.DropIndex(
                name: "IX_CONSULTATION_CON_CABINET_ID",
                table: "CONSULTATION");

            migrationBuilder.DropIndex(
                name: "IX_AUDIT_LOG_AUD_CABINET_ID",
                table: "AUDIT_LOG");

            migrationBuilder.DropIndex(
                name: "IX_ARTICLE_ART_CABINET_ID",
                table: "ARTICLE");

            migrationBuilder.DropIndex(
                name: "IX_ACTE_MEDICAL_ACT_CABINET_ID",
                table: "ACTE_MEDICAL");

            migrationBuilder.DropColumn(
                name: "USR_CABINET_ID",
                table: "USER");

            migrationBuilder.DropColumn(
                name: "SOI_CABINET_ID",
                table: "SOIN_EFFECTUE");

            migrationBuilder.DropColumn(
                name: "RDV_CABINET_ID",
                table: "RENDEZ_VOUS");

            migrationBuilder.DropColumn(
                name: "REC_CABINET_ID",
                table: "RECETTE_ACTE");

            migrationBuilder.DropColumn(
                name: "PAT_CABINET_ID",
                table: "PATIENT");

            migrationBuilder.DropColumn(
                name: "PAI_CABINET_ID",
                table: "PAIEMENT");

            migrationBuilder.DropColumn(
                name: "ORD_CABINET_ID",
                table: "ORDONNANCE");

            migrationBuilder.DropColumn(
                name: "NTF_CABINET_ID",
                table: "NOTIFICATION");

            migrationBuilder.DropColumn(
                name: "FAC_CABINET_ID",
                table: "FACTURE");

            migrationBuilder.DropColumn(
                name: "CON_CABINET_ID",
                table: "CONSULTATION");

            migrationBuilder.DropColumn(
                name: "AUD_CABINET_ID",
                table: "AUDIT_LOG");

            migrationBuilder.DropColumn(
                name: "ART_CABINET_ID",
                table: "ARTICLE");

            migrationBuilder.DropColumn(
                name: "ACT_CABINET_ID",
                table: "ACTE_MEDICAL");
        }
    }
}
