using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Dentiste.Core.Messaging;
using Dentiste.Core.Shared;
using Dentiste.Data.Infrastructure.EF;

namespace Dentiste.Core.Features.ActesMedicaux.Queries.GetById;

public class GetActeMedicalByIdQueryHandler : IQueryHandler<GetActeMedicalByIdQuery, ActeMedicalDto>
{
    private readonly DentisteContext _context;

    public GetActeMedicalByIdQueryHandler(DentisteContext context)
    {
        _context = context;
    }

    public async Task<Result<ActeMedicalDto>> Handle(GetActeMedicalByIdQuery request, CancellationToken cancellationToken)
    {
        var acte = await _context.ActesMedicaux
            .AsNoTracking()
            .Select(a => new ActeMedicalDto
            {
                Id = a.Id,
                Libelle = a.Libelle,
                TarifDeBase = a.TarifDeBase,
                CodeNomenclature = a.CodeNomenclature
            })
            .FirstOrDefaultAsync(a => a.Id == request.Id, cancellationToken);

        if (acte == null)
        {
            return Result.Failure<ActeMedicalDto>(Errors.ActeMedicalNotFound);
        }

        return Result.Success(acte);
    }
}
