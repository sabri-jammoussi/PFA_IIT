using Dentiste.Core.Features.Auth.Commands.Login;
using Dentiste.Core.Features.Users.Commands.Add;
using Xunit;

namespace Dentiste.Tests;

public class ValidatorTests
{
    private readonly AddUserCommandValidator _addUser = new();
    private readonly LoginCommandValidator _login = new();

    [Fact]
    public void AddUser_Valid_Passes()
    {
        var cmd = new AddUserCommand
        {
            Username = "dr.house",
            Email = "house@clinic.tn",
            Password = "Str0ngPass",
            Nom = "House",
            Prenom = "Gregory",
            RoleId = 2
        };

        Assert.True(_addUser.Validate(cmd).IsValid);
    }

    [Fact]
    public void AddUser_InvalidEmail_Fails()
    {
        var cmd = new AddUserCommand
        {
            Username = "u",
            Email = "not-an-email",
            Password = "Str0ngPass",
            Nom = "N",
            Prenom = "P",
            RoleId = 2
        };

        var result = _addUser.Validate(cmd);
        Assert.False(result.IsValid);
        Assert.Contains(result.Errors, e => e.PropertyName == nameof(AddUserCommand.Email));
    }

    [Fact]
    public void AddUser_ShortPassword_Fails()
    {
        var cmd = new AddUserCommand
        {
            Username = "u",
            Email = "u@clinic.tn",
            Password = "short",
            Nom = "N",
            Prenom = "P",
            RoleId = 2
        };

        var result = _addUser.Validate(cmd);
        Assert.False(result.IsValid);
        Assert.Contains(result.Errors, e => e.PropertyName == nameof(AddUserCommand.Password));
    }

    [Fact]
    public void Login_Empty_Fails()
    {
        var result = _login.Validate(new LoginCommand { Username = "", Password = "" });
        Assert.False(result.IsValid);
    }
}
