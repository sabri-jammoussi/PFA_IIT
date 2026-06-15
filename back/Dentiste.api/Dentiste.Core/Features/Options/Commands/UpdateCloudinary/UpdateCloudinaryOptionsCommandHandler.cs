using Dentiste.Data.Infrastructure.EF;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Dentiste.Core.Features.Options.Commands.UpdateCloudinary;

public class UpdateCloudinaryOptionsCommandHandler : IRequestHandler<UpdateCloudinaryOptionsCommand, bool>
{
    private readonly DentisteContext _context;

    public UpdateCloudinaryOptionsCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<bool> Handle(UpdateCloudinaryOptionsCommand request, CancellationToken cancellationToken)
    {
        var opts = await _context.Options
            .Where(o => o.Group == "Cloudinary")
            .ToListAsync(cancellationToken);

        void Set(string name, string value)
        {
            var opt = opts.FirstOrDefault(o => o.Name == name);
            if (opt is not null) opt.Value = value;
        }

        Set("cloudinary.name",   request.Name);
        Set("cloudinary.key",    request.Key);
        Set("cloudinary.folder", request.Folder);

        if (!string.IsNullOrWhiteSpace(request.Secret))
            Set("cloudinary.secret", request.Secret);

        await _context.SaveChangesAsync(cancellationToken);
        return true;
    }
}
