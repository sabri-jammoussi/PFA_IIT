using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.Users.Queries.GetById;

public class GetUserByIdQueryHandler : IQueryHandler<GetUserByIdQuery, UserDto>
{
    private readonly DentisteContext _context;

    public GetUserByIdQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<UserDto>> Handle(GetUserByIdQuery request, CancellationToken cancellationToken)
    {
        var user = await _context.Users
            .AsNoTracking()
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
                RoleName = u.Role.Name
            })
            .FirstOrDefaultAsync(u => u.Id == request.Id, cancellationToken);

        if (user == null)
        {
            return Result.Failure<UserDto>(Errors.UserNotFound);
        }

        return Result.Success(user);
    }
}
