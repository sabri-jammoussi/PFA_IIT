using MediatR;

namespace Dentiste.Core.Features.Options.Queries.GetStorage;

public record GetStorageOptionsQuery() : IRequest<StorageOptionsDto>;

public class StorageOptionsDto
{
    public string Type { get; set; } = string.Empty;
    public bool HasToken { get; set; }
    public string Path { get; set; } = string.Empty;
    public string Account { get; set; } = string.Empty;
}
