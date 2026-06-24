using Microsoft.EntityFrameworkCore;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Dentiste.Notification.Features.Consultations
{
    /// <summary>
    /// Recipients of a "consultation finalized" notification: the cabinet's
    /// secretaries, who are in charge of collecting the payment.
    /// </summary>
    public class ConsultationsUsersProvider
    {
        private readonly DentisteContext _dbContext;

        public ConsultationsUsersProvider(DentisteContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IList<UserDao>> Get(int cabinetId, CancellationToken cancellationToken = default)
        {
            return await _dbContext.Users
                .IgnoreQueryFilters()
                .Include(u => u.Role)
                .AsNoTracking()
                .Where(u => u.CabinetId == cabinetId)
                .Where(u => u.Role.Name == "Secretaire")
                .ToListAsync(cancellationToken);
        }
    }
}
