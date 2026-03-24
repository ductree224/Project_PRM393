namespace Application.Interfaces;

public interface IJwtService
{
    string GenerateAccessToken(Guid userId, string username, string email, string role, DateTime expiresAt);
    string GenerateRefreshToken();
    Guid? ValidateAccessToken(string token);
}
