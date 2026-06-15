using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.api.Middleware
{
    public class SubscriptionCheckMiddleware
    {
        private readonly RequestDelegate _next;

        public SubscriptionCheckMiddleware(RequestDelegate next) => _next = next;

        public async Task InvokeAsync(HttpContext context, DentisteContext dbContext)
        {
            var endpoint = context.GetEndpoint();
            var allowAnonymous = endpoint?.Metadata?.GetMetadata<AllowAnonymousAttribute>() != null;

            if (allowAnonymous || context.Request.Path.Value?.Contains("/subscription/reactivate") == true)
            {
                await _next(context);
                return;
            }

            var cabinetIdClaim = context.User?.FindFirst("cabinetId")?.Value;

            if (!string.IsNullOrEmpty(cabinetIdClaim) && int.TryParse(cabinetIdClaim, out var cabinetId))
            {
                // Retrieve subscription status by ignoring query filters (since it is a background checks/context query)
                var isSubscriptionActive = await dbContext.Cabinets
                    .IgnoreQueryFilters()
                    .Where(c => c.Id == cabinetId)
                    .Select(c => c.IsSubscriptionActive)
                    .FirstOrDefaultAsync();

                if (!isSubscriptionActive)
                {
                    context.Response.StatusCode = StatusCodes.Status402PaymentRequired;
                    context.Response.ContentType = "application/json";
                    await context.Response.WriteAsJsonAsync(new { error = "L'abonnement de votre cabinet a expiré." });
                    return;
                }
            }

            await _next(context);
        }
    }
}
