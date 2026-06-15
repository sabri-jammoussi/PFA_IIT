using System.Collections.Generic;
using Dentiste.Core.Shared;
using MediatR;

namespace Dentiste.Core.Features.Patients.Queries.GetMy;

public record GetMyMedicalRecordQuery() : IRequest<Result<MyMedicalRecordDto>>;
