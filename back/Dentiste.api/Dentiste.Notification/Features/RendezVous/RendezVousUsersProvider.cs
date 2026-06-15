using Microsoft.EntityFrameworkCore;
using Dentiste.Data.Infrastructure.EF;
using Dentiste.Data.Models;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Dentiste.Notification.Features.RendezVous
{
    public class RendezVousUsersProvider
    {
        private readonly DentisteContext _dbContext;

        public RendezVousUsersProvider(DentisteContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IList<UserDao>> Get(int dentistId, CancellationToken cancellationToken = default)
        {
            var dentist = await _dbContext.Users.IgnoreQueryFilters().AsNoTracking().SingleOrDefaultAsync(u => u.Id == dentistId, cancellationToken);
            var result = new List<UserDao>();
            if (dentist != null)
            {
                result.Add(dentist);
            }
            return result;
        }
    }
}
