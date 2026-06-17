using System.Threading;
using System.Threading.Tasks;
using Dentiste.Data.Infrastructure;
using Dentiste.Data.Models;
using Microsoft.EntityFrameworkCore;

namespace Dentiste.Data.Infrastructure.EF;

public class DentisteContext : DbContext
{
    private readonly ITenantProvider? _tenantProvider;

    public DentisteContext(DbContextOptions<DentisteContext> options, ITenantProvider? tenantProvider = null)
        : base(options)
    {
        _tenantProvider = tenantProvider;
    }

    public override int SaveChanges()
    {
        ApplyTenantId();
        return base.SaveChanges();
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        ApplyTenantId();
        return base.SaveChangesAsync(cancellationToken);
    }

    private void ApplyTenantId()
    {
        var currentCabinetId = _tenantProvider?.GetCabinetId();
        if (currentCabinetId == null) return;

        foreach (var entry in ChangeTracker.Entries())
        {
            if (entry.State == EntityState.Added)
            {
                var cabinetIdProp = entry.Metadata.FindProperty("CabinetId");
                if (cabinetIdProp != null)
                {
                    var currentValue = entry.CurrentValues[cabinetIdProp];
                    if (currentValue == null || (currentValue is int val && val == 0))
                    {
                        entry.CurrentValues[cabinetIdProp] = currentCabinetId.Value;
                    }
                }
            }
        }
    }

    // Authentification & Rôles
    public DbSet<UserDao> Users { get; set; }
    public DbSet<RoleDao> Roles { get; set; }
    public DbSet<CabinetDao> Cabinets { get; set; }

    // Dossier Patient & Agenda
    public DbSet<PatientDao> Patients { get; set; }
    public DbSet<RendezVousDao> RendezVous { get; set; }

    // Dossier Clinique & Schéma Dentaire
    public DbSet<ActeMedicalDao> ActesMedicaux { get; set; }
    public DbSet<ConsultationDao> Consultations { get; set; }
    public DbSet<SoinEffectueDao> SoinsEffectues { get; set; }
    public DbSet<OrdonnanceDao> Ordonnances { get; set; }

    // Facturation & Comptabilité
    public DbSet<FactureDao> Factures { get; set; }
    public DbSet<PaiementDao> Paiements { get; set; }

    // Stock & Inventaire
    public DbSet<ArticleDao> Articles { get; set; }
    public DbSet<RecetteActeDao> RecettesActes { get; set; }

    // Notifications
    public DbSet<NotificationDao> Notifications { get; set; }

    // Traçabilité & Sécurité
    public DbSet<AuditLogDao> AuditLogs { get; set; }

    // Configuration système
    public DbSet<OptionDao> Options { get; set; }
    public DbSet<ConfigurationCabinetDao> ConfigurationsCabinets { get; set; }
    public DbSet<ImageVersionDao> ImageVersions { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // ── SaaS Multi-Tenant Query Filters ──
        modelBuilder.Entity<CabinetDao>().HasKey(c => c.Id);

        modelBuilder.Entity<UserDao>().HasQueryFilter(u => _tenantProvider != null && u.CabinetId == _tenantProvider.GetCabinetId());
        modelBuilder.Entity<PatientDao>().HasQueryFilter(p => _tenantProvider != null && p.CabinetId == _tenantProvider.GetCabinetId());
        modelBuilder.Entity<RendezVousDao>().HasQueryFilter(r => _tenantProvider != null && r.CabinetId == _tenantProvider.GetCabinetId());
        modelBuilder.Entity<ActeMedicalDao>().HasQueryFilter(a => _tenantProvider != null && a.CabinetId == _tenantProvider.GetCabinetId());
        modelBuilder.Entity<ConsultationDao>().HasQueryFilter(c => _tenantProvider != null && c.CabinetId == _tenantProvider.GetCabinetId());
        modelBuilder.Entity<OrdonnanceDao>().HasQueryFilter(o => _tenantProvider != null && o.CabinetId == _tenantProvider.GetCabinetId());
        modelBuilder.Entity<SoinEffectueDao>().HasQueryFilter(s => _tenantProvider != null && s.CabinetId == _tenantProvider.GetCabinetId());
        modelBuilder.Entity<FactureDao>().HasQueryFilter(f => _tenantProvider != null && f.CabinetId == _tenantProvider.GetCabinetId());
        modelBuilder.Entity<PaiementDao>().HasQueryFilter(p => _tenantProvider != null && p.CabinetId == _tenantProvider.GetCabinetId());
        modelBuilder.Entity<ArticleDao>().HasQueryFilter(a => _tenantProvider != null && a.CabinetId == _tenantProvider.GetCabinetId());
        modelBuilder.Entity<RecetteActeDao>().HasQueryFilter(r => _tenantProvider != null && r.CabinetId == _tenantProvider.GetCabinetId());
        modelBuilder.Entity<NotificationDao>().HasQueryFilter(n => _tenantProvider != null && n.CabinetId == _tenantProvider.GetCabinetId());
        modelBuilder.Entity<AuditLogDao>().HasQueryFilter(a => _tenantProvider != null && a.CabinetId == _tenantProvider.GetCabinetId());
        modelBuilder.Entity<ConfigurationCabinetDao>().HasQueryFilter(c => _tenantProvider != null && c.CabinetId == _tenantProvider.GetCabinetId());

        // ── Cabinet Foreign Keys ──
        modelBuilder.Entity<UserDao>().HasOne(u => u.Cabinet).WithMany(c => c.Users).HasForeignKey(u => u.CabinetId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<PatientDao>().HasOne(p => p.Cabinet).WithMany().HasForeignKey(p => p.CabinetId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<RendezVousDao>().HasOne(r => r.Cabinet).WithMany().HasForeignKey(r => r.CabinetId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<ActeMedicalDao>().HasOne(a => a.Cabinet).WithMany().HasForeignKey(a => a.CabinetId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<ConsultationDao>().HasOne(c => c.Cabinet).WithMany().HasForeignKey(c => c.CabinetId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<OrdonnanceDao>().HasOne(o => o.Cabinet).WithMany().HasForeignKey(o => o.CabinetId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<SoinEffectueDao>().HasOne(s => s.Cabinet).WithMany().HasForeignKey(s => s.CabinetId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<FactureDao>().HasOne(f => f.Cabinet).WithMany().HasForeignKey(f => f.CabinetId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<PaiementDao>().HasOne(p => p.Cabinet).WithMany().HasForeignKey(p => p.CabinetId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<ArticleDao>().HasOne(a => a.Cabinet).WithMany().HasForeignKey(a => a.CabinetId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<RecetteActeDao>().HasOne(r => r.Cabinet).WithMany().HasForeignKey(r => r.CabinetId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<NotificationDao>().HasOne(n => n.Cabinet).WithMany().HasForeignKey(n => n.CabinetId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<AuditLogDao>().HasOne(a => a.Cabinet).WithMany().HasForeignKey(a => a.CabinetId).OnDelete(DeleteBehavior.Restrict);
        modelBuilder.Entity<ConfigurationCabinetDao>().HasOne(c => c.Cabinet).WithOne().HasForeignKey<ConfigurationCabinetDao>(c => c.CabinetId).OnDelete(DeleteBehavior.Cascade);

        // ── User ──
        modelBuilder.Entity<UserDao>(entity =>
        {
            entity.HasIndex(u => u.Username).IsUnique();
            entity.HasIndex(u => u.Email).IsUnique();

            entity.HasOne(u => u.Role)
                  .WithMany(r => r.Users)
                  .HasForeignKey(u => u.RoleId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // ── RendezVous ──
        modelBuilder.Entity<RendezVousDao>(entity =>
        {
            entity.HasOne(rv => rv.Patient)
                  .WithMany(p => p.RendezVous)
                  .HasForeignKey(rv => rv.PatientId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(rv => rv.Dentiste)
                  .WithMany()
                  .HasForeignKey(rv => rv.DentisteId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // ── Consultation ──
        modelBuilder.Entity<ConsultationDao>(entity =>
        {
            entity.HasOne(c => c.Patient)
                  .WithMany(p => p.Consultations)
                  .HasForeignKey(c => c.PatientId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(c => c.Dentiste)
                  .WithMany()
                  .HasForeignKey(c => c.DentisteId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // ── SoinEffectue ──
        modelBuilder.Entity<SoinEffectueDao>(entity =>
        {
            entity.HasOne(s => s.Consultation)
                  .WithMany(c => c.SoinsEffectues)
                  .HasForeignKey(s => s.ConsultationId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(s => s.ActeMedical)
                  .WithMany()
                  .HasForeignKey(s => s.ActeMedicalId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // ── Ordonnance (One-to-One avec Consultation) ──
        modelBuilder.Entity<OrdonnanceDao>(entity =>
        {
            entity.HasIndex(o => o.ConsultationId).IsUnique();

            entity.HasOne(o => o.Consultation)
                  .WithOne(c => c.Ordonnance)
                  .HasForeignKey<OrdonnanceDao>(o => o.ConsultationId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // ── Facture ──
        modelBuilder.Entity<FactureDao>(entity =>
        {
            entity.HasIndex(f => f.NumeroFacture).IsUnique();

            entity.HasOne(f => f.Patient)
                  .WithMany(p => p.Factures)
                  .HasForeignKey(f => f.PatientId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // ── Paiement ──
        modelBuilder.Entity<PaiementDao>(entity =>
        {
            entity.HasOne(p => p.Facture)
                  .WithMany(f => f.Paiements)
                  .HasForeignKey(p => p.FactureId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // ── RecetteActe ──
        modelBuilder.Entity<RecetteActeDao>(entity =>
        {
            entity.HasOne(r => r.ActeMedical)
                  .WithMany()
                  .HasForeignKey(r => r.ActeMedicalId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(r => r.Article)
                  .WithMany()
                  .HasForeignKey(r => r.ArticleId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // ── AuditLog ──
        modelBuilder.Entity<AuditLogDao>(entity =>
        {
            entity.HasIndex(a => a.Timestamp);
            entity.HasIndex(a => a.TableName);
        });

        // ── Notification ──
        modelBuilder.Entity<NotificationDao>(entity =>
        {
            entity.HasOne(n => n.CreatedByUser)
                  .WithMany()
                  .HasForeignKey(n => n.CreatedBy)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(n => n.CreatedToUser)
                  .WithMany()
                  .HasForeignKey(n => n.CreatedTo)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // ── Options Seed ──
        modelBuilder.Entity<OptionDao>().HasData(
            // SMTP
            new OptionDao { Id = 1,  Group = "SMTP",       Name = "smtp.host",               Value = "smtp.gmail.com",  Required = true,  Label = "H\u00f4te SMTP",           Description = "Serveur SMTP sortant" },
            new OptionDao { Id = 2,  Group = "SMTP",       Name = "smtp.port",               Value = "587",             Required = true,  Label = "Port SMTP",             Description = "Port de connexion SMTP (587 TLS, 465 SSL)" },
            new OptionDao { Id = 3,  Group = "SMTP",       Name = "smtp.username",           Value = "",               Required = true,  Label = "Email exp\u00e9diteur",      Description = "Adresse email de l'exp\u00e9diteur" },
            new OptionDao { Id = 4,  Group = "SMTP",       Name = "smtp.password",           Value = "",               Required = false, Label = "Mot de passe",          Description = "Mot de passe ou app password" },
            new OptionDao { Id = 5,  Group = "SMTP",       Name = "smtp.ssl",                Value = "true",           Required = true,  Label = "Activer SSL/TLS",       Description = "Chiffrement de la connexion" },
            // Cloudinary
            new OptionDao { Id = 6,  Group = "Cloudinary", Name = "cloudinary.name",         Value = "",               Required = false, Label = "Cloud Name",            Description = "Nom du compte Cloudinary" },
            new OptionDao { Id = 7,  Group = "Cloudinary", Name = "cloudinary.key",          Value = "",               Required = false, Label = "API Key",               Description = "Cl\u00e9 API Cloudinary" },
            new OptionDao { Id = 8,  Group = "Cloudinary", Name = "cloudinary.secret",       Value = "",               Required = false, Label = "API Secret",            Description = "Cl\u00e9 secr\u00e8te Cloudinary" },
            new OptionDao { Id = 9,  Group = "Cloudinary", Name = "cloudinary.folder",       Value = "dentiste",       Required = false, Label = "Dossier",               Description = "Dossier racine pour les fichiers" },
            // Storage
            new OptionDao { Id = 10, Group = "Storage",    Name = "storage.provider.type",  Value = "Desactiver",     Required = true,  Label = "Type de stockage",      Description = "Local, Desactiver, Google, Microsoft" },
            new OptionDao { Id = 11, Group = "Storage",    Name = "storage.provider.token", Value = "",               Required = false, Label = "Token OAuth",           Description = "Token d'authentification cloud" },
            new OptionDao { Id = 12, Group = "Storage",    Name = "storage.provider.path",  Value = "",               Required = false, Label = "Chemin local",          Description = "Chemin absolu du r\u00e9pertoire de stockage local" },
            new OptionDao { Id = 13, Group = "Storage",    Name = "storage.provider.account",Value = "",              Required = false, Label = "Compte connect\u00e9",      Description = "Email du compte cloud connect\u00e9" }
        );
    }
}
