using Dentiste.Data.Models;
using Microsoft.EntityFrameworkCore;

namespace Dentiste.Data.Infrastructure.EF;

public class DentisteContext : DbContext
{
    public DentisteContext(DbContextOptions<DentisteContext> options)
        : base(options)
    {
    }

    // Authentification & Rôles
    public DbSet<UserDao> Users { get; set; }
    public DbSet<RoleDao> Roles { get; set; }

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

    // Traçabilité & Sécurité
    public DbSet<AuditLogDao> AuditLogs { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

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

        // ── AuditLog ──
        modelBuilder.Entity<AuditLogDao>(entity =>
        {
            entity.HasIndex(a => a.Timestamp);
            entity.HasIndex(a => a.TableName);
        });
    }
}
