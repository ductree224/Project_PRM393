using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities;

public class WaitlistTrack
{
    public Guid WaitlistId { get; set; }
    public Waitlist Waitlist { get; set; } = null!;
    public string TrackExternalId { get; set; } = string.Empty;
    public int Position { get; set; } // Dùng để quản lý thứ tự (reorder)
    public DateTime AddedAt { get; set; } = DateTime.UtcNow;
}