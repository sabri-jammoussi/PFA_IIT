using System.Security.Claims;
using Microsoft.AspNetCore.Http;

namespace Dentiste.Core.Infrastructure.Security
{
    public interface ICurrentUserProvider
    {
        int? GetUserId();
        int? GetCabinetId();
    }

    public class CurrentUserProvider : ICurrentUserProvider
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly Dentiste.Data.Infrastructure.ITenantProvider _tenantProvider;

        public CurrentUserProvider(IHttpContextAccessor httpContextAccessor, Dentiste.Data.Infrastructure.ITenantProvider tenantProvider)
        {
            _httpContextAccessor = httpContextAccessor;
            _tenantProvider = tenantProvider;
        }

        public int? GetUserId()
        {
            var httpContext = _httpContextAccessor.HttpContext;
            if (httpContext == null) return null;

            var userIdClaim = httpContext.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value 
                              ?? httpContext.User?.FindFirst("id")?.Value;

            if (int.TryParse(userIdClaim, out var userId))
            {
                return userId;
            }

            return null;
        }

        public int? GetCabinetId()
        {
            return _tenantProvider.GetCabinetId();
        }
    }
}
