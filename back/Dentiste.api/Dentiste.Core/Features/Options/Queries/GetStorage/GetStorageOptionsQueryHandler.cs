using Dentiste.Data.Infrastructure.EF;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Dentiste.Core.Features.Options.Queries.GetStorage;

public class GetStorageOptionsQueryHandler : IRequestHandler<GetStorageOptionsQuery, StorageOptionsDto>
{
    private readonly DentisteContext _context;

    public GetStorageOptionsQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<StorageOptionsDto> Handle(GetStorageOptionsQuery request, CancellationToken cancellationToken)
    {
        var opts = await _context.Options
            .AsNoTracking()
            .Where(o => o.Group == "Storage")
            .ToListAsync(cancellationToken);

        string Get(string name) => opts.FirstOrDefault(o => o.Name == name)?.Value ?? string.Empty;

        return new StorageOptionsDto
        {
            Type     = Get("storage.provider.type"),
            HasToken = !string.IsNullOrWhiteSpace(Get("storage.provider.token")),
            Path     = Get("storage.provider.path"),
            Account  = Get("storage.provider.account")
        };
    }
}
