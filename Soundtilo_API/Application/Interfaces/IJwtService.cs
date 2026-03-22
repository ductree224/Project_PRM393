namespace Application.Interfaces;

public interface IJwtService
{
    string GenerateAccessToken(Guid userId, string username, string email, string role);
    string GenerateRefreshToken();
    Guid? ValidateAccessToken(string token);
}
