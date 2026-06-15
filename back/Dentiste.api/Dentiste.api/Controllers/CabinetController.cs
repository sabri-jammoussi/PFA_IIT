using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;
using Dentiste.Data.Infrastructure;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/cabinet")]
[Authorize(Roles = "Dentiste,Admin")]
public class CabinetController : ControllerBase
{
    private readonly DentisteContext _context;
    private readonly ITenantProvider _tenantProvider;

    public CabinetController(DentisteContext context, ITenantProvider tenantProvider)
    {
        _context = context;
        _tenantProvider = tenantProvider;
    }

    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetAllCabinets()
    {
        var cabinets = await _context.Cabinets
            .AsNoTracking()
            .Select(c => new
            {
                c.Id,
                c.NomCabinet,
                c.Adresse,
                c.TelephoneCorporate,
                c.CreatedAt,
                c.IsSubscriptionActive
            })
            .ToListAsync();

        return Ok(cabinets);
    }

    [HttpPut("{id}/subscription")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateSubscription(int id, [FromBody] UpdateSubscriptionDto model)
    {
        var cabinet = await _context.Cabinets.FindAsync(id);
        if (cabinet == null)
        {
            return NotFound(new { error = "Cabinet non trouvé." });
        }

        cabinet.IsSubscriptionActive = model.IsActive;
        await _context.SaveChangesAsync();
        return Ok(new { success = true });
    }

    [HttpPost("subscription/reactivate")]
    public async Task<IActionResult> ReactivateSubscription()
    {
        var cabinetId = _tenantProvider.GetCabinetId();
        if (cabinetId == null)
        {
            return BadRequest(new { error = "Aucun cabinet associé à l'utilisateur." });
        }

        var cabinet = await _context.Cabinets.IgnoreQueryFilters().FirstOrDefaultAsync(c => c.Id == cabinetId.Value);
        if (cabinet == null)
        {
            return NotFound(new { error = "Cabinet non trouvé." });
        }

        cabinet.IsSubscriptionActive = true;
        await _context.SaveChangesAsync();
        return Ok(new { success = true });
    }

    [HttpGet("settings/smtp")]
    public async Task<IActionResult> GetSmtpSettings()
    {
        var cabinetId = _tenantProvider.GetCabinetId();
        if (cabinetId == null)
        {
            return BadRequest(new { error = "Aucun cabinet associé à l'utilisateur connecté." });
        }

        var config = await _context.ConfigurationsCabinets
            .FirstOrDefaultAsync(c => c.CabinetId == cabinetId.Value);

        if (config == null)
        {
            return Ok(new CabinetSmtpSettingsDto());
        }

        return Ok(new CabinetSmtpSettingsDto
        {
            SmtpHost = config.SmtpHost,
            SmtpPort = config.SmtpPort,
            SmtpUsername = config.SmtpUsername,
            SmtpEnableSsl = config.SmtpEnableSsl ?? true,
            SenderName = config.SenderName
            // We do not return password for security
        });
    }

    [HttpPost("settings/smtp")]
    public async Task<IActionResult> UpdateSmtpSettings([FromBody] CabinetSmtpSettingsDto model)
    {
        var cabinetId = _tenantProvider.GetCabinetId();
        if (cabinetId == null)
        {
            return BadRequest(new { error = "Aucun cabinet associé à l'utilisateur connecté." });
        }

        var config = await _context.ConfigurationsCabinets
            .FirstOrDefaultAsync(c => c.CabinetId == cabinetId.Value);

        if (config == null)
        {
            config = new ConfigurationCabinetDao
            {
                CabinetId = cabinetId.Value
            };
            _context.ConfigurationsCabinets.Add(config);
        }

        config.SmtpHost = model.SmtpHost;
        config.SmtpPort = model.SmtpPort;
        config.SmtpUsername = model.SmtpUsername;
        config.SmtpEnableSsl = model.SmtpEnableSsl;
        config.SenderName = model.SenderName;

        if (!string.IsNullOrEmpty(model.SmtpPassword))
        {
            config.SmtpPassword = model.SmtpPassword;
        }

        await _context.SaveChangesAsync();
        return Ok(new { success = true });
    }
}

public class CabinetSmtpSettingsDto
{
    public string? SmtpHost { get; set; }
    public int? SmtpPort { get; set; }
    public string? SmtpUsername { get; set; }
    public string? SmtpPassword { get; set; }
    public bool SmtpEnableSsl { get; set; } = true;
    public string? SenderName { get; set; }
}

public class UpdateSubscriptionDto
{
    public bool IsActive { get; set; }
}
