using MediatR;

namespace Dentiste.Core.Features.Options.Commands.UpdateCloudinary;

public record UpdateCloudinaryOptionsCommand(
    string Name,
    string Key,
    /// <summary>Null or empty = do not change the stored secret.</summary>
    string? Secret,
    string Folder
) : IRequest<bool>;
