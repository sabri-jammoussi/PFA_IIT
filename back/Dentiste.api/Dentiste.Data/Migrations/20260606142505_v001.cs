using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Dentiste.Data.Migrations
{
    /// <inheritdoc />
    public partial class v001 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ACTE_MEDICAL",
                columns: table => new
                {
                    ACT_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ACT_LIBELLE = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    ACT_TARIF_DE_BASE = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    ACT_CODE_NOMENCLATURE = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ACTE_MEDICAL", x => x.ACT_ID);
                });

            migrationBuilder.CreateTable(
                name: "AUDIT_LOG",
                columns: table => new
                {
                    AUD_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AUD_ACTION = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    AUD_TABLE_NAME = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    AUD_TIMESTAMP = table.Column<DateTime>(type: "datetime2", nullable: false),
                    AUD_USER_ID = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    AUD_KEY_VALUES = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    AUD_OLD_VALUES = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    AUD_NEW_VALUES = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AUDIT_LOG", x => x.AUD_ID);
                });

            migrationBuilder.CreateTable(
                name: "PATIENT",
                columns: table => new
                {
                    PAT_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PAT_NOM = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    PAT_PRENOM = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    PAT_DATE_NAISSANCE = table.Column<DateTime>(type: "datetime2", nullable: false),
                    PAT_TELEPHONE = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    PAT_EMAIL = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PAT_ADRESSE = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PAT_ANTECEDENTS_MEDICAUX = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PAT_GROUP_SANGUIN = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PAT_CREATED_AT = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PATIENT", x => x.PAT_ID);
                });

            migrationBuilder.CreateTable(
                name: "ROLE",
                columns: table => new
                {
                    ROL_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ROL_NAME = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    ROL_DESCRIPTION = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ROLE", x => x.ROL_ID);
                });

            migrationBuilder.CreateTable(
                name: "FACTURE",
                columns: table => new
                {
                    FAC_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FAC_NUMERO_FACTURE = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    FAC_DATE_EMISSION = table.Column<DateTime>(type: "datetime2", nullable: false),
                    FAC_MONTANT_TOTAL = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    FAC_MONTANT_PAYE = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    FAC_STATUT_PAIEMENT = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    FAC_PATIENT_ID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FACTURE", x => x.FAC_ID);
                    table.ForeignKey(
                        name: "FK_FACTURE_PATIENT_FAC_PATIENT_ID",
                        column: x => x.FAC_PATIENT_ID,
                        principalTable: "PATIENT",
                        principalColumn: "PAT_ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "USER",
                columns: table => new
                {
                    USR_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    USR_USERNAME = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    USR_EMAIL = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    USR_PASSWORD_HASH = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    USR_PASSWORD_SALT = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    USR_NOM = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    USR_PRENOM = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    USR_IS_ACTIVE = table.Column<bool>(type: "bit", nullable: false),
                    USR_CREATED_AT = table.Column<DateTime>(type: "datetime2", nullable: false),
                    USR_ROLE_ID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_USER", x => x.USR_ID);
                    table.ForeignKey(
                        name: "FK_USER_ROLE_USR_ROLE_ID",
                        column: x => x.USR_ROLE_ID,
                        principalTable: "ROLE",
                        principalColumn: "ROL_ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PAIEMENT",
                columns: table => new
                {
                    PAI_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PAI_DATE_PAIEMENT = table.Column<DateTime>(type: "datetime2", nullable: false),
                    PAI_MONTANT = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    PAI_MODE_PAIEMENT = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    PAI_FACTURE_ID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PAIEMENT", x => x.PAI_ID);
                    table.ForeignKey(
                        name: "FK_PAIEMENT_FACTURE_PAI_FACTURE_ID",
                        column: x => x.PAI_FACTURE_ID,
                        principalTable: "FACTURE",
                        principalColumn: "FAC_ID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "CONSULTATION",
                columns: table => new
                {
                    CON_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CON_DATE_CONSULTATION = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CON_NOTES_OBSERVATIONS = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CON_PATIENT_ID = table.Column<int>(type: "int", nullable: false),
                    CON_DENTISTE_ID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CONSULTATION", x => x.CON_ID);
                    table.ForeignKey(
                        name: "FK_CONSULTATION_PATIENT_CON_PATIENT_ID",
                        column: x => x.CON_PATIENT_ID,
                        principalTable: "PATIENT",
                        principalColumn: "PAT_ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_CONSULTATION_USER_CON_DENTISTE_ID",
                        column: x => x.CON_DENTISTE_ID,
                        principalTable: "USER",
                        principalColumn: "USR_ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "RENDEZ_VOUS",
                columns: table => new
                {
                    RDV_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RDV_DATE_HEURE = table.Column<DateTime>(type: "datetime2", nullable: false),
                    RDV_DUREE_ESTIMEE = table.Column<TimeSpan>(type: "time", nullable: false),
                    RDV_STATUT = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    RDV_MOTIF = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    RDV_NOTE = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    RDV_PATIENT_ID = table.Column<int>(type: "int", nullable: false),
                    RDV_DENTISTE_ID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RENDEZ_VOUS", x => x.RDV_ID);
                    table.ForeignKey(
                        name: "FK_RENDEZ_VOUS_PATIENT_RDV_PATIENT_ID",
                        column: x => x.RDV_PATIENT_ID,
                        principalTable: "PATIENT",
                        principalColumn: "PAT_ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_RENDEZ_VOUS_USER_RDV_DENTISTE_ID",
                        column: x => x.RDV_DENTISTE_ID,
                        principalTable: "USER",
                        principalColumn: "USR_ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ORDONNANCE",
                columns: table => new
                {
                    ORD_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ORD_DATE_EMISSION = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ORD_TRAITEMENT = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ORD_CONSULTATION_ID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ORDONNANCE", x => x.ORD_ID);
                    table.ForeignKey(
                        name: "FK_ORDONNANCE_CONSULTATION_ORD_CONSULTATION_ID",
                        column: x => x.ORD_CONSULTATION_ID,
                        principalTable: "CONSULTATION",
                        principalColumn: "CON_ID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SOIN_EFFECTUE",
                columns: table => new
                {
                    SOI_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SOI_NUMERO_DENT = table.Column<int>(type: "int", nullable: true),
                    SOI_FACE_DENTAIRE = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    SOI_PRIX_APPLIQUE = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    SOI_NOTES = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SOI_CONSULTATION_ID = table.Column<int>(type: "int", nullable: false),
                    SOI_ACTE_MEDICAL_ID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SOIN_EFFECTUE", x => x.SOI_ID);
                    table.ForeignKey(
                        name: "FK_SOIN_EFFECTUE_ACTE_MEDICAL_SOI_ACTE_MEDICAL_ID",
                        column: x => x.SOI_ACTE_MEDICAL_ID,
                        principalTable: "ACTE_MEDICAL",
                        principalColumn: "ACT_ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SOIN_EFFECTUE_CONSULTATION_SOI_CONSULTATION_ID",
                        column: x => x.SOI_CONSULTATION_ID,
                        principalTable: "CONSULTATION",
                        principalColumn: "CON_ID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AUDIT_LOG_AUD_TABLE_NAME",
                table: "AUDIT_LOG",
                column: "AUD_TABLE_NAME");

            migrationBuilder.CreateIndex(
                name: "IX_AUDIT_LOG_AUD_TIMESTAMP",
                table: "AUDIT_LOG",
                column: "AUD_TIMESTAMP");

            migrationBuilder.CreateIndex(
                name: "IX_CONSULTATION_CON_DENTISTE_ID",
                table: "CONSULTATION",
                column: "CON_DENTISTE_ID");

            migrationBuilder.CreateIndex(
                name: "IX_CONSULTATION_CON_PATIENT_ID",
                table: "CONSULTATION",
                column: "CON_PATIENT_ID");

            migrationBuilder.CreateIndex(
                name: "IX_FACTURE_FAC_NUMERO_FACTURE",
                table: "FACTURE",
                column: "FAC_NUMERO_FACTURE",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_FACTURE_FAC_PATIENT_ID",
                table: "FACTURE",
                column: "FAC_PATIENT_ID");

            migrationBuilder.CreateIndex(
                name: "IX_ORDONNANCE_ORD_CONSULTATION_ID",
                table: "ORDONNANCE",
                column: "ORD_CONSULTATION_ID",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PAIEMENT_PAI_FACTURE_ID",
                table: "PAIEMENT",
                column: "PAI_FACTURE_ID");

            migrationBuilder.CreateIndex(
                name: "IX_RENDEZ_VOUS_RDV_DENTISTE_ID",
                table: "RENDEZ_VOUS",
                column: "RDV_DENTISTE_ID");

            migrationBuilder.CreateIndex(
                name: "IX_RENDEZ_VOUS_RDV_PATIENT_ID",
                table: "RENDEZ_VOUS",
                column: "RDV_PATIENT_ID");

            migrationBuilder.CreateIndex(
                name: "IX_SOIN_EFFECTUE_SOI_ACTE_MEDICAL_ID",
                table: "SOIN_EFFECTUE",
                column: "SOI_ACTE_MEDICAL_ID");

            migrationBuilder.CreateIndex(
                name: "IX_SOIN_EFFECTUE_SOI_CONSULTATION_ID",
                table: "SOIN_EFFECTUE",
                column: "SOI_CONSULTATION_ID");

            migrationBuilder.CreateIndex(
                name: "IX_USER_USR_EMAIL",
                table: "USER",
                column: "USR_EMAIL",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_USER_USR_ROLE_ID",
                table: "USER",
                column: "USR_ROLE_ID");

            migrationBuilder.CreateIndex(
                name: "IX_USER_USR_USERNAME",
                table: "USER",
                column: "USR_USERNAME",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AUDIT_LOG");

            migrationBuilder.DropTable(
                name: "ORDONNANCE");

            migrationBuilder.DropTable(
                name: "PAIEMENT");

            migrationBuilder.DropTable(
                name: "RENDEZ_VOUS");

            migrationBuilder.DropTable(
                name: "SOIN_EFFECTUE");

            migrationBuilder.DropTable(
                name: "FACTURE");

            migrationBuilder.DropTable(
                name: "ACTE_MEDICAL");

            migrationBuilder.DropTable(
                name: "CONSULTATION");

            migrationBuilder.DropTable(
                name: "PATIENT");

            migrationBuilder.DropTable(
                name: "USER");

            migrationBuilder.DropTable(
                name: "ROLE");
        }
    }
}
