using MediatR;

namespace Dentiste.Core.Features.Options.Commands.UpdateStorage;

public record UpdateStorageOptionsCommand(
    string Type,
    /// <summary>Null or empty = do not change the stored token.</summary>
    string? Token,
    string Path,
    string Account
) : IRequest<bool>;
