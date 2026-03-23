using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities;

public class TrackAnalyticsDaily
{
    public Guid Id { get; set; }
    public DateOnly Date { get; set; }
    public string TrackExternalId { get; set; } = string.Empty;

    public long PlayCount { get; set; }
    public long CompletedPlayCount { get; set; }
    public long TotalListeningDurationSeconds { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
