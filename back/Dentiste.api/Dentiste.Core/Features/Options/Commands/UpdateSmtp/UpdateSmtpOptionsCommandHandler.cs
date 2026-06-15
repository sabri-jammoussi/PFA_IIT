using Dentiste.Data.Infrastructure.EF;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Dentiste.Core.Features.Options.Commands.UpdateSmtp;

public class UpdateSmtpOptionsCommandHandler : IRequestHandler<UpdateSmtpOptionsCommand, bool>
{
    private readonly DentisteContext _context;

    public UpdateSmtpOptionsCommandHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<bool> Handle(UpdateSmtpOptionsCommand request, CancellationToken cancellationToken)
    {
        var opts = await _context.Options
            .Where(o => o.Group == "SMTP")
            .ToListAsync(cancellationToken);

        void Set(string name, string value)
        {
            var opt = opts.FirstOrDefault(o => o.Name == name);
            if (opt is not null) opt.Value = value;
        }

        Set("smtp.host",     request.Host);
        Set("smtp.port",     request.Port);
        Set("smtp.username", request.Username);
        Set("smtp.ssl",      request.Ssl ? "true" : "false");

        // Only update password if a new one was provided
        if (!string.IsNullOrWhiteSpace(request.Password))
            Set("smtp.password", request.Password);

        await _context.SaveChangesAsync(cancellationToken);
        return true;
    }
}
