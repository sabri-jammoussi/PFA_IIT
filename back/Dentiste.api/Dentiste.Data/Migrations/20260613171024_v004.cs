using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Dentiste.Data.Migrations
{
    /// <inheritdoc />
    public partial class v004 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "OPTION",
                columns: table => new
                {
                    OPT_ID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OPT_NAME = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: false),
                    OPT_VALUE = table.Column<string>(type: "nvarchar(1024)", maxLength: 1024, nullable: false),
                    OPT_REQUIRED = table.Column<bool>(type: "bit", nullable: false),
                    OPT_DESCRIPTION = table.Column<string>(type: "nvarchar(512)", maxLength: 512, nullable: false),
                    OPT_LABEL = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: false),
                    OPT_GROUP = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OPTION", x => x.OPT_ID);
                });

            migrationBuilder.InsertData(
                table: "OPTION",
                columns: new[] { "OPT_ID", "OPT_DESCRIPTION", "OPT_GROUP", "OPT_LABEL", "OPT_NAME", "OPT_REQUIRED", "OPT_VALUE" },
                values: new object[,]
                {
                    { 1, "Serveur SMTP sortant", "SMTP", "Hôte SMTP", "smtp.host", true, "smtp.gmail.com" },
                    { 2, "Port de connexion SMTP (587 TLS, 465 SSL)", "SMTP", "Port SMTP", "smtp.port", true, "587" },
                    { 3, "Adresse email de l'expéditeur", "SMTP", "Email expéditeur", "smtp.username", true, "" },
                    { 4, "Mot de passe ou app password", "SMTP", "Mot de passe", "smtp.password", false, "" },
                    { 5, "Chiffrement de la connexion", "SMTP", "Activer SSL/TLS", "smtp.ssl", true, "true" },
                    { 6, "Nom du compte Cloudinary", "Cloudinary", "Cloud Name", "cloudinary.name", false, "" },
                    { 7, "Clé API Cloudinary", "Cloudinary", "API Key", "cloudinary.key", false, "" },
                    { 8, "Clé secrète Cloudinary", "Cloudinary", "API Secret", "cloudinary.secret", false, "" },
                    { 9, "Dossier racine pour les fichiers", "Cloudinary", "Dossier", "cloudinary.folder", false, "dentiste" },
                    { 10, "Local, Desactiver, Google, Microsoft", "Storage", "Type de stockage", "storage.provider.type", true, "Desactiver" },
                    { 11, "Token d'authentification cloud", "Storage", "Token OAuth", "storage.provider.token", false, "" },
                    { 12, "Chemin absolu du répertoire de stockage local", "Storage", "Chemin local", "storage.provider.path", false, "" },
                    { 13, "Email du compte cloud connecté", "Storage", "Compte connecté", "storage.provider.account", false, "" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "OPTION");
        }
    }
}
