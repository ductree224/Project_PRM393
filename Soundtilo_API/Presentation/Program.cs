using System.Text;
using System.Text.Json;
using Application;
using Application.Interfaces;
using Infrastructure;
using Infrastructure.Data;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Presentation.Hubs;
using Presentation.Realtime;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
    });
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSignalR();
builder.Services.AddSwaggerGen(options =>
{
    options.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = Microsoft.OpenApi.Models.ParameterLocation.Header,
        Description = "Enter your JWT token"
    });
    options.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
    {
        {
            new Microsoft.OpenApi.Models.OpenApiSecurityScheme
            {
                Reference = new Microsoft.OpenApi.Models.OpenApiReference
                {
                    Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// JWT Authentication
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var accessToken = context.Request.Query["access_token"];
                var path = context.HttpContext.Request.Path;

                if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/hubs/notifications"))
                {
                    context.Token = accessToken;
                }

                return Task.CompletedTask;
            }
        };

        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Secret"]
                    ?? throw new InvalidOperationException("JWT Secret not configured"))),
            ValidateIssuer = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidateAudience = true,
            ValidAudience = builder.Configuration["Jwt:Audience"],
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero
        };
    });

// CORS - allow Flutter app
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterApp", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Register Application & Infrastructure layers
builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);
builder.Services.AddScoped<INotificationRealtimePublisher, SignalRNotificationRealtimePublisher>();

var app = builder.Build();

// Ensure database schema is aligned with the current EF model at startup.
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<SoundtiloDbContext>();
    dbContext.Database.Migrate();

    // Ensure subscription tables exist (created via raw SQL migration, not EF migrations).
    dbContext.Database.ExecuteSqlRaw("""
        CREATE TABLE IF NOT EXISTS subscription_plans (
            id          UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
            name        VARCHAR(100)    NOT NULL,
            price       DECIMAL(10,2)   NOT NULL,
            currency    VARCHAR(10)     NOT NULL DEFAULT 'vnd',
            interval    VARCHAR(20)     NOT NULL,
            plan_code   VARCHAR(255),
            is_active   BOOLEAN         NOT NULL DEFAULT true,
            created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
        );

        CREATE TABLE IF NOT EXISTS subscriptions (
            id                      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id                 UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            plan_id                 UUID        NOT NULL REFERENCES subscription_plans(id),
            status                  VARCHAR(30) NOT NULL DEFAULT 'active',
            current_period_start    TIMESTAMPTZ NOT NULL,
            current_period_end      TIMESTAMPTZ NOT NULL,
            cancelled_at            TIMESTAMPTZ,
            created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            CONSTRAINT uq_subscriptions_user UNIQUE (user_id)
        );

        CREATE TABLE IF NOT EXISTS payment_transactions (
            id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id         UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            subscription_id UUID        REFERENCES subscriptions(id) ON DELETE SET NULL,
            txn_ref         VARCHAR(255) NOT NULL UNIQUE,
            amount          DECIMAL(18,2) NOT NULL,
            currency        VARCHAR(10)  NOT NULL DEFAULT 'vnd',
            status          VARCHAR(30)  NOT NULL DEFAULT 'pending',
            provider        VARCHAR(50)  NOT NULL DEFAULT 'vnpay',
            response_code   VARCHAR(10),
            response_message VARCHAR(500),
            bank_code       VARCHAR(50),
            pay_date        VARCHAR(30),
            created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );

        ALTER TABLE users ADD COLUMN IF NOT EXISTS subscription_tier     VARCHAR(20)  NOT NULL DEFAULT 'free';
        ALTER TABLE users ADD COLUMN IF NOT EXISTS premium_expires_at    TIMESTAMPTZ;
        ALTER TABLE users ADD COLUMN IF NOT EXISTS vnpay_customer_id     VARCHAR(255);
        """);

    // Seed default subscription plans if table is empty.
    if (!dbContext.SubscriptionPlans.Any())
    {
        dbContext.SubscriptionPlans.AddRange(
            new Domain.Entities.SubscriptionPlan
            {
                Id = Guid.NewGuid(),
                Name = "Free",
                Price = 0m,
                Currency = "vnd",
                Interval = "free",
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
            },
            new Domain.Entities.SubscriptionPlan
            {
                Id = Guid.NewGuid(),
                Name = "Premium Monthly",
                Price = 10000m,
                Currency = "vnd",
                Interval = "monthly",
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
            },
            new Domain.Entities.SubscriptionPlan
            {
                Id = Guid.NewGuid(),
                Name = "Premium Yearly",
                Price = 100000m,
                Currency = "vnd",
                Interval = "yearly",
                IsActive = true,
                CreatedAt = DateTime.UtcNow,
            }
        );
        dbContext.SaveChanges();
    }
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}


// Note: HttpsRedirection can sometimes cause CORS issues during local development with Web/Desktop

// app.UseHttpsRedirection();

app.UseCors("AllowFlutterApp");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHub<NotificationHub>("/hubs/notifications");

app.Run();
