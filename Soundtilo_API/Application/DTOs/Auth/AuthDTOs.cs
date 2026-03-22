namespace Application.DTOs.Auth;

public record RegisterRequest(
    string Username,
    string Email,
    string Password,
    string? DisplayName
);

public record LoginRequest(
    string UsernameOrEmail,
    string Password
);

public record RefreshTokenRequest(
    string RefreshToken
);

public record GoogleLoginRequest(
    string IdToken
);

public record ForgotPasswordRequest(
    string Email
);

public record ResetPasswordRequest(
    string Token,
    string NewPassword
);

public record ForgotPasswordResponse(
    string Message,
    string Token
);

public record MessageResponse(
    string Message
);

public record AuthResponse(
    Guid UserId,
    string Username,
    string Email,
    string? DisplayName,
    string? AvatarUrl,
    string Role,
    string AccessToken,
    string RefreshToken,
    DateTime ExpiresAt
);
