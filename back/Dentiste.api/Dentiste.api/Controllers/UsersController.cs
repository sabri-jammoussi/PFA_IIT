using System.Threading.Tasks;
using System.Linq;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Dentiste.Data;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Core.Features.Users;
using Dentiste.Core.Features.Users.Commands.Add;
using Dentiste.Core.Features.Users.Commands.Update;
using Dentiste.Core.Features.Users.Commands.Delete;
using Dentiste.Core.Features.Users.Queries.GetById;
using Dentiste.Core.Features.Users.Queries.GetAll;

namespace Dentiste.api.Controllers;

[ApiController]
[Route("api/users")]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly ISender _sender;
    private readonly DentisteContext _context;

    public UsersController(ISender sender, DentisteContext context)
    {
        _sender = sender;
        _context = context;
    }

    [HttpGet]
    [Authorize(Roles = $"{nameof(UserRole.Admin)},{nameof(UserRole.Dentiste)}")]
    public async Task<IActionResult> GetAll([FromQuery] int page = 1, [FromQuery] int pageSize = 10, [FromQuery] string? search = null, [FromQuery] int? roleId = null)
    {
        var query = new GetAllUsersQuery
        {
            Page = page,
            PageSize = pageSize,
            SearchTerm = search,
            RoleId = roleId
        };
        var result = await _sender.Send(query);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpGet("dentists")]
    [Authorize(Roles = $"{nameof(UserRole.Admin)},{nameof(UserRole.Dentiste)},{nameof(UserRole.Secretaire)},{nameof(UserRole.Patient)}")]
    public async Task<IActionResult> GetDentists()
    {
        var dentists = await _context.Users
            .AsNoTracking()
            .Include(u => u.Role)
            .Where(u => u.RoleId == (int)UserRole.Dentiste)
            .Select(u => new UserDto
            {
                Id = u.Id,
                Username = u.Username,
                Email = u.Email,
                Nom = u.Nom,
                Prenom = u.Prenom,
                IsActive = u.IsActive,
                CreatedAt = u.CreatedAt,
                RoleId = u.RoleId,
                RoleName = u.Role != null ? u.Role.Name : null
            })
            .ToListAsync();

        return Ok(dentists);
    }

    [HttpGet("{id:int}")]
    [Authorize(Roles = $"{nameof(UserRole.Admin)},{nameof(UserRole.Dentiste)},{nameof(UserRole.Secretaire)},{nameof(UserRole.Patient)}")]
    public async Task<IActionResult> GetById(int id)
    {
        var currentUserId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        var isAdmin = User.IsInRole(nameof(UserRole.Admin));
        var isDentist = User.IsInRole(nameof(UserRole.Dentiste));
        
        var targetUser = await _context.Users.IgnoreQueryFilters().AsNoTracking().FirstOrDefaultAsync(u => u.Id == id);
        if (targetUser == null)
        {
            return NotFound("Utilisateur non trouvé.");
        }

        bool isAuthorized = isAdmin || (currentUserId == id.ToString());

        if (!isAuthorized && isDentist)
        {
            var cabinetIdClaim = User.FindFirst("cabinetId")?.Value;
            if (int.TryParse(cabinetIdClaim, out var currentCabinetId))
            {
                isAuthorized = targetUser.CabinetId == currentCabinetId;
            }
        }

        if (!isAuthorized)
        {
            return Forbid();
        }

        var query = new GetUserByIdQuery { Id = id };
        var result = await _sender.Send(query);
        if (result.IsSuccess)
        {
            return Ok(result.Value);
        }
        return NotFound(result.Error);
    }

    [HttpPost]
    [Authorize(Roles = $"{nameof(UserRole.Admin)},{nameof(UserRole.Dentiste)}")]
    public async Task<IActionResult> Create([FromBody] AddUserCommand command)
    {
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return CreatedAtAction(nameof(GetById), new { id = result.Value }, result.Value);
        }
        return BadRequest(result.Error);
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = $"{nameof(UserRole.Admin)},{nameof(UserRole.Dentiste)},{nameof(UserRole.Secretaire)}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateUserCommand command)
    {
        if (id != command.Id)
        {
            return BadRequest("L'ID spécifié dans l'URL ne correspond pas à celui du corps de la requête.");
        }

        var currentUserId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        var isAdmin = User.IsInRole(nameof(UserRole.Admin));
        var isDentist = User.IsInRole(nameof(UserRole.Dentiste));
        
        var targetUser = await _context.Users.IgnoreQueryFilters().AsNoTracking().FirstOrDefaultAsync(u => u.Id == id);
        if (targetUser == null)
        {
            return NotFound("Utilisateur non trouvé.");
        }

        bool isAuthorized = isAdmin || (currentUserId == id.ToString());

        if (!isAuthorized && isDentist)
        {
            var cabinetIdClaim = User.FindFirst("cabinetId")?.Value;
            if (int.TryParse(cabinetIdClaim, out var currentCabinetId))
            {
                isAuthorized = targetUser.CabinetId == currentCabinetId;
            }
        }

        if (!isAuthorized)
        {
            return Forbid();
        }

        // Additional security check: Non-admins cannot change their own RoleId or IsActive status
        if (!isAdmin && currentUserId == id.ToString())
        {
            if (command.RoleId != targetUser.RoleId || command.IsActive != targetUser.IsActive)
            {
                return BadRequest("Vous ne pouvez pas modifier votre propre rôle ou l'état actif de votre compte.");
            }
        }

        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return NoContent();
        }
        return BadRequest(result.Error);
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = $"{nameof(UserRole.Admin)},{nameof(UserRole.Dentiste)}")]
    public async Task<IActionResult> Delete(int id)
    {
        var command = new DeleteUserCommand { Id = id };
        var result = await _sender.Send(command);
        if (result.IsSuccess)
        {
            return NoContent();
        }
        return BadRequest(result.Error);
    }
}
