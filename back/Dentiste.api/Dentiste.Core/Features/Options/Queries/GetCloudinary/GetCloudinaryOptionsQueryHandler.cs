using Dentiste.Data.Infrastructure.EF;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Dentiste.Core.Features.Options.Queries.GetCloudinary;

public class GetCloudinaryOptionsQueryHandler : IRequestHandler<GetCloudinaryOptionsQuery, CloudinaryOptionsDto>
{
    private readonly DentisteContext _context;

    public GetCloudinaryOptionsQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<CloudinaryOptionsDto> Handle(GetCloudinaryOptionsQuery request, CancellationToken cancellationToken)
    {
        var opts = await _context.Options
            .AsNoTracking()
            .Where(o => o.Group == "Cloudinary")
            .ToListAsync(cancellationToken);

        string Get(string name) => opts.FirstOrDefault(o => o.Name == name)?.Value ?? string.Empty;

        return new CloudinaryOptionsDto
        {
            Name      = Get("cloudinary.name"),
            Key       = Get("cloudinary.key"),
            HasSecret = !string.IsNullOrWhiteSpace(Get("cloudinary.secret")),
            Folder    = Get("cloudinary.folder")
        };
    }
}
