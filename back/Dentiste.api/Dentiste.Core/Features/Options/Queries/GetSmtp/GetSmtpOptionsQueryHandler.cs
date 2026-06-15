using Dentiste.Data.Infrastructure.EF;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Dentiste.Core.Features.Options.Queries.GetSmtp;

public class GetSmtpOptionsQueryHandler : IRequestHandler<GetSmtpOptionsQuery, SmtpOptionsDto>
{
    private readonly DentisteContext _context;

    public GetSmtpOptionsQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<SmtpOptionsDto> Handle(GetSmtpOptionsQuery request, CancellationToken cancellationToken)
    {
        var opts = await _context.Options
            .AsNoTracking()
            .Where(o => o.Group == "SMTP")
            .ToListAsync(cancellationToken);

        string Get(string name) => opts.FirstOrDefault(o => o.Name == name)?.Value ?? string.Empty;

        return new SmtpOptionsDto
        {
            Host        = Get("smtp.host"),
            Port        = Get("smtp.port"),
            Username    = Get("smtp.username"),
            HasPassword = !string.IsNullOrWhiteSpace(Get("smtp.password")),
            Ssl         = Get("smtp.ssl") == "true"
        };
    }
}
