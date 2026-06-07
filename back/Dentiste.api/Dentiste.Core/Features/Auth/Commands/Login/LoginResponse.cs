using Dentiste.Core.Features.Users;

namespace Dentiste.Core.Features.Auth.Commands.Login;

public record LoginResponse(string Token, UserDto User);
