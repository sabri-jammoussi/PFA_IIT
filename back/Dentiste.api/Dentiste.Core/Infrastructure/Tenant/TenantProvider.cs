using Microsoft.AspNetCore.Http;
using System.Security.Claims;
using Dentiste.Data.Infrastructure;

namespace Dentiste.Core.Infrastructure.Tenant
{
    public class TenantProvider : ITenantProvider
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public TenantProvider(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        public int? GetCabinetId()
        {
            var httpContext = _httpContextAccessor.HttpContext;
            if (httpContext == null) return null;

            var cabinetIdClaim = httpContext.User?.FindFirst("cabinetId")?.Value;
            if (int.TryParse(cabinetIdClaim, out var cabinetId))
            {
                return cabinetId;
            }

            return null;
        }
    }
}
