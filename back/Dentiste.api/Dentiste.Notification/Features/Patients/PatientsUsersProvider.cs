using Microsoft.EntityFrameworkCore;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Dentiste.Notification.Features.Patients
{
    public class PatientsUsersProvider
    {
        private readonly DentisteContext _dbContext;

        public PatientsUsersProvider(DentisteContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IList<UserDao>> Get(int cabinetId, int currentUserId, CancellationToken cancellationToken = default)
        {
            return await _dbContext.Users
                .IgnoreQueryFilters()
                .Include(u => u.Role)
                .AsNoTracking()
                .Where(u => u.CabinetId == cabinetId && u.Id != currentUserId)
                .Where(u => u.Role.Name == "Dentiste" || u.Role.Name == "Secretaire")
                .ToListAsync(cancellationToken);
        }
    }
}
