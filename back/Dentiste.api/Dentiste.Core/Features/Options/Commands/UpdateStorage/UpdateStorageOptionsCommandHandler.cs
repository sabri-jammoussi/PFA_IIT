using Dentiste.Data.Infrastructure.EF;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Dentiste.Core.Features.Options.Commands.UpdateStorage;

public class UpdateStorageOptionsCommandHandler : IRequestHandler<UpdateStorageOptionsCommand, bool>
{
    private readonly DentisteContext _context;

    public UpdateStorageOptionsCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<bool> Handle(UpdateStorageOptionsCommand request, CancellationToken cancellationToken)
    {
        var opts = await _context.Options
            .Where(o => o.Group == "Storage")
            .ToListAsync(cancellationToken);

        void Set(string name, string value)
        {
            var opt = opts.FirstOrDefault(o => o.Name == name);
            if (opt is not null) opt.Value = value;
        }

        Set("storage.provider.type",    request.Type);
        Set("storage.provider.path",    request.Path);
        Set("storage.provider.account", request.Account);

        if (!string.IsNullOrWhiteSpace(request.Token))
            Set("storage.provider.token", request.Token);

        await _context.SaveChangesAsync(cancellationToken);
        return true;
    }
}
