using MediatR;

namespace Dentiste.Core.Features.Options.Queries.GetCloudinary;

public record GetCloudinaryOptionsQuery() : IRequest<CloudinaryOptionsDto>;

public class CloudinaryOptionsDto
{
    public string Name   { get; set; } = string.Empty;
    public string Key    { get; set; } = string.Empty;
    public bool   HasSecret { get; set; }
    public string Folder { get; set; } = string.Empty;
}
