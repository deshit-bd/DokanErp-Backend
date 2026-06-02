const stats = [
  {
    label: "Total Shop",
    value: "120",
    sublabel: "All Brand",
    accent: "indigo",
    icon: "shop",
  },
  {
    label: "Total User",
    value: "14544",
    sublabel: "Total Brand",
    accent: "green",
    icon: "check",
  },
  {
    label: "Total Product",
    value: "112",
    sublabel: "Total Brand",
    accent: "green",
    icon: "check",
  },
  {
    label: "Todays Sale",
    value: "$7524",
    sublabel: "Total Brand",
    accent: "orange",
    icon: "close",
  },
  {
    label: "Revenue",
    meta: "(This Month)",
    value: "$223",
    sublabel: "Total Brand",
    accent: "red",
    icon: "alert",
  },
];

const timelineLabels = [
  "01 May",
  "06 May",
  "11 May",
  "16 May",
  "21 May",
  "26 May",
  "31 May",
];

const categoryBreakdown = [
  { label: "Food", value: "2,456 (36.9%)", accent: "green" },
  { label: "Drinks", value: "1,456 (36.9%)", accent: "blue" },
  { label: "Household products", value: "2,456 (36.9%)", accent: "pink" },
  { label: "Fast Food", value: "2,456 (36.9%)", accent: "violet" },
  { label: "Baby Product", value: "2,456 (36.9%)", accent: "yellow" },
  { label: "Dry Food", value: "2,456 (36.9%)", accent: "gray" },
  { label: "Others", value: "2,456 (36.9%)", accent: "sky" },
];

const recentShops = [
  { id: "shop-rahman", name: "Rahman Store", location: "Dhaka, Bangladesh", date: "30 may, 2024", status: "Active" },
  { id: "shop-mother", name: "Mother Store", location: "Dhaka, Bangladesh", date: "30 may, 2024", status: "Active" },
  { id: "shop-janata", name: "Janata Store", location: "Dhaka, Bangladesh", date: "30 may, 2024", status: "Active" },
  { id: "shop-bondhon-1", name: "Bondhon Store", location: "Dhaka, Bangladesh", date: "30 may, 2024", status: "Active" },
  { id: "shop-bondhon-2", name: "Bondhon Store", location: "Dhaka, Bangladesh", date: "30 may, 2024", status: "Active" },
];

const recentActivities = [
  { id: "activity-product", title: "New product added.", location: "Dhaka, Bangladesh", date: "30 may, 2024", accent: "green", icon: "check" },
  { id: "activity-price", title: "Suggested price update", location: "Dhaka, Bangladesh", date: "30 may, 2024", accent: "indigo", icon: "note" },
  { id: "activity-shop", title: "New shop added.", location: "Dhaka, Bangladesh", date: "30 may, 2024", accent: "yellow", icon: "shop" },
  { id: "activity-user-1", title: "Create a user account", location: "Dhaka, Bangladesh", date: "30 may, 2024", accent: "pink", icon: "userplus" },
  { id: "activity-user-2", title: "Create a user account", location: "Dhaka, Bangladesh", date: "30 may, 2024", accent: "pink", icon: "userplus" },
];

const systemStatus = [
  { title: "Server Status", location: "Dhaka, Bangladesh", status: "Active", accent: "green", icon: "trend" },
  { title: "Database Status", location: "Dhaka, Bangladesh", status: "Active", accent: "orange", icon: "coin" },
  { title: "Rahman Store", location: "Dhaka, Bangladesh", status: "Success will(10:AM)", accent: "red", icon: "mute" },
  { title: "Rahman Store", location: "Dhaka, Bangladesh", status: "Active", accent: "orange", icon: "messagebox" },
];

function DashboardStatIcon({ type }: { type: string }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  switch (type) {
    case "shop":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M4.5 9h15" />
          <path {...commonProps} d="M6 9V19h12V9" />
          <path {...commonProps} d="M4 9 6 5h12l2 4" />
          <path {...commonProps} d="M9 19v-5h6v5" />
        </svg>
      );
    case "check":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <circle {...commonProps} cx="12" cy="12" r="8.5" />
          <path {...commonProps} d="m8.5 12 2.3 2.3 4.7-4.8" />
        </svg>
      );
    case "close":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="m8 8 8 8" />
          <path {...commonProps} d="m16 8-8 8" />
        </svg>
      );
    case "alert":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M12 3.5 19 8v8l-7 4.5L5 16V8l7-4.5Z" />
          <path {...commonProps} d="M12 8v5" />
          <path {...commonProps} d="M12 16h.01" />
        </svg>
      );
    default:
      return null;
  }
}

function DashboardListIcon({ type }: { type: string }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  switch (type) {
    case "shop":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M4.5 9h15" />
          <path {...commonProps} d="M6 9V19h12V9" />
          <path {...commonProps} d="M4 9 6 5h12l2 4" />
          <path {...commonProps} d="M9 19v-5h6v5" />
        </svg>
      );
    case "check":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <circle {...commonProps} cx="12" cy="12" r="8.5" />
          <path {...commonProps} d="m8.5 12 2.3 2.3 4.7-4.8" />
        </svg>
      );
    case "note":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M7 4.5h8l3 3V19H7V4.5Z" />
          <path {...commonProps} d="M15 4.5v3h3" />
          <path {...commonProps} d="M10 11h4" />
        </svg>
      );
    case "userplus":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M10 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" />
          <path {...commonProps} d="M4.5 19a5 5 0 0 1 10 0" />
          <path {...commonProps} d="M18 8v6" />
          <path {...commonProps} d="M15 11h6" />
        </svg>
      );
    case "trend":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M5 17V7" />
          <path {...commonProps} d="M5 17h14" />
          <path {...commonProps} d="m8 14 3-3 3 2 4-5" />
        </svg>
      );
    case "coin":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <circle {...commonProps} cx="12" cy="12" r="7.5" />
          <path {...commonProps} d="M10 9.5h3a1.5 1.5 0 1 1 0 3h-2a1.5 1.5 0 1 0 0 3h3" />
        </svg>
      );
    case "mute":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M10 9 6.5 12 10 15V9Z" />
          <path {...commonProps} d="m14 10 4 4" />
          <path {...commonProps} d="m18 10-4 4" />
        </svg>
      );
    case "messagebox":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M5 6h14v10H9l-4 3V6Z" />
          <path {...commonProps} d="M8 10h7" />
        </svg>
      );
    default:
      return null;
  }
}

export default function SuperAdminDashboardPage() {
  return (
    <section className="admin-dashboard">
      <div className="admin-dashboard-stats">
        {stats.map((stat) => (
          <article className="admin-stat-card" key={stat.label}>
            <div className={`admin-stat-icon admin-stat-icon-${stat.accent}`}>
              <DashboardStatIcon type={stat.icon} />
            </div>
            <div className="admin-stat-content">
              <div className="admin-stat-heading">
                <span>{stat.label}</span>
                {stat.meta ? <small>{stat.meta}</small> : null}
              </div>
              <strong>{stat.value}</strong>
              <p>{stat.sublabel}</p>
            </div>
          </article>
        ))}
      </div>

      <div className="admin-dashboard-analytics">
        <section className="admin-analytics-card admin-analytics-card-wide">
          <div className="admin-analytics-header">
            <h2>Sale and Revenue</h2>
            <div className="admin-analytics-legend">
              <span className="admin-legend-item">
                <i className="admin-legend-dot admin-legend-dot-green" />
                Sales
              </span>
              <span className="admin-legend-item">
                <i className="admin-legend-dot admin-legend-dot-blue" />
                Order
              </span>
              <button className="admin-filter-chip" type="button">
                Daily
                <span className="admin-filter-caret">⌄</span>
              </button>
            </div>
          </div>

          <div className="admin-chart-shell">
            <div className="admin-chart-axis">
              <span>$2.5 Lakh</span>
              <span>$2.0 Lakh</span>
              <span>$1.5 Lakh</span>
              <span>$1.0 Lakh</span>
              <span>$50 Thousand</span>
              <span>$0 TK</span>
            </div>

            <div className="admin-chart-area">
              <div className="admin-chart-grid">
                <span />
                <span />
                <span />
                <span />
                <span />
                <span />
              </div>
              <svg
                className="admin-chart-svg"
                viewBox="0 0 640 240"
                preserveAspectRatio="none"
                aria-hidden="true"
              >
                <defs>
                  <linearGradient id="sales-fill" x1="0" x2="0" y1="0" y2="1">
                    <stop offset="0%" stopColor="rgba(16, 185, 129, 0.28)" />
                    <stop offset="100%" stopColor="rgba(16, 185, 129, 0)" />
                  </linearGradient>
                  <linearGradient id="orders-fill" x1="0" x2="0" y1="0" y2="1">
                    <stop offset="0%" stopColor="rgba(67, 97, 255, 0.24)" />
                    <stop offset="100%" stopColor="rgba(67, 97, 255, 0)" />
                  </linearGradient>
                </defs>
                <path
                  className="admin-chart-fill-green"
                  d="M0 185 C20 120, 40 110, 60 84 S100 86, 120 58 S160 188, 180 160 S220 165, 240 124 S280 86, 300 103 S340 158, 360 120 S400 112, 420 72 S460 149, 480 98 S520 58, 540 42 S580 120, 600 108 S630 95, 640 126 L640 240 L0 240 Z"
                />
                <path
                  className="admin-chart-fill-blue"
                  d="M0 205 C20 198, 40 188, 60 192 S100 176, 120 146 S160 210, 180 205 S220 174, 240 132 S280 198, 300 183 S340 172, 360 165 S400 186, 420 164 S460 118, 480 120 S520 72, 540 136 S580 170, 600 158 S630 142, 640 190 L640 240 L0 240 Z"
                />
                <path
                  className="admin-chart-line-green"
                  d="M0 185 C20 120, 40 110, 60 84 S100 86, 120 58 S160 188, 180 160 S220 165, 240 124 S280 86, 300 103 S340 158, 360 120 S400 112, 420 72 S460 149, 480 98 S520 58, 540 42 S580 120, 600 108 S630 95, 640 126"
                />
                <path
                  className="admin-chart-line-blue"
                  d="M0 205 C20 198, 40 188, 60 192 S100 176, 120 146 S160 210, 180 205 S220 174, 240 132 S280 198, 300 183 S340 172, 360 165 S400 186, 420 164 S460 118, 480 120 S520 72, 540 136 S580 170, 600 158 S630 142, 640 190"
                />
              </svg>

              <div className="admin-chart-labels">
                {timelineLabels.map((label) => (
                  <span key={label}>{label}</span>
                ))}
              </div>
            </div>
          </div>

          <div className="admin-chart-summary">
            <article className="admin-summary-card">
              <span>Total Sale</span>
              <strong>$5468468</strong>
              <div className="admin-summary-meta">
                <small>Last Month: $1235465</small>
                <em>↑ 24%</em>
              </div>
            </article>
            <article className="admin-summary-card">
              <span>Total Order</span>
              <strong>$5468468</strong>
              <div className="admin-summary-meta">
                <small>Last Month: $1235465</small>
                <em>↑ 20.4%</em>
              </div>
            </article>
          </div>
        </section>

        <section className="admin-analytics-card admin-analytics-card-side">
          <div className="admin-analytics-header">
            <h2>Sale and Revenue</h2>
          </div>

          <div className="admin-donut-layout">
            <div className="admin-donut-legend">
              {categoryBreakdown.slice(0, 4).map((item) => (
                <div className="admin-donut-legend-item" key={item.label}>
                  <i className={`admin-legend-dot admin-legend-dot-${item.accent}`} />
                  <div>
                    <strong>{item.label}</strong>
                    <span>{item.value}</span>
                  </div>
                </div>
              ))}
            </div>

            <div className="admin-donut-chart">
              <div className="admin-donut-ring">
                <div className="admin-donut-center">
                  <span>Total Product</span>
                  <strong>2,124</strong>
                </div>
              </div>
            </div>

            <div className="admin-donut-legend">
              {categoryBreakdown.slice(4).map((item) => (
                <div className="admin-donut-legend-item" key={item.label}>
                  <i className={`admin-legend-dot admin-legend-dot-${item.accent}`} />
                  <div>
                    <strong>{item.label}</strong>
                    <span>{item.value}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <button className="admin-details-button" type="button">
            See Details <span>→</span>
          </button>
        </section>
      </div>

      <div className="admin-dashboard-lists">
        <section className="admin-list-card">
          <div className="admin-list-header">
            <h2>Recently Added Shop</h2>
          </div>

          <div className="admin-list-body">
            {recentShops.map((shop) => (
              <article className="admin-list-item" key={shop.id}>
                <div className="admin-list-icon admin-list-icon-blue">
                  <DashboardListIcon type="shop" />
                </div>
                <div className="admin-list-copy">
                  <strong>{shop.name}</strong>
                  <span>{shop.location}</span>
                </div>
                <div className="admin-list-meta">
                  <small>{shop.date}</small>
                  <em>{shop.status}</em>
                </div>
              </article>
            ))}
          </div>

          <button className="admin-details-button" type="button">
            See Details <span>→</span>
          </button>
        </section>

        <section className="admin-list-card">
          <div className="admin-list-header">
            <h2>Recent Activities</h2>
          </div>

          <div className="admin-list-body">
            {recentActivities.map((activity) => (
              <article className="admin-list-item" key={activity.id}>
                <div className={`admin-list-icon admin-list-icon-${activity.accent}`}>
                  <DashboardListIcon type={activity.icon} />
                </div>
                <div className="admin-list-copy">
                  <strong>{activity.title}</strong>
                  <span>{activity.location}</span>
                </div>
                <div className="admin-list-meta">
                  <small>{activity.date}</small>
                </div>
              </article>
            ))}
          </div>

          <button className="admin-details-button" type="button">
            See Details <span>→</span>
          </button>
        </section>

        <section className="admin-list-card">
          <div className="admin-list-header">
            <h2>Recently Added Shop</h2>
          </div>

          <div className="admin-list-body">
            {systemStatus.map((item) => (
              <article className="admin-list-item" key={`${item.title}-${item.status}-${item.icon}`}>
                <div className={`admin-list-icon admin-list-icon-${item.accent}`}>
                  <DashboardListIcon type={item.icon} />
                </div>
                <div className="admin-list-copy">
                  <strong>{item.title}</strong>
                  <span>{item.location}</span>
                </div>
                <div className="admin-list-meta">
                  <em>{item.status}</em>
                </div>
              </article>
            ))}

            <div className="admin-storage-card">
              <div className="admin-list-item admin-list-item-storage">
                <div className="admin-list-icon admin-list-icon-violet">
                  <DashboardListIcon type="note" />
                </div>
                <div className="admin-list-copy">
                  <strong>Total Storage Used</strong>
                </div>
                <div className="admin-storage-meta">321.6GB / 1TB (32%)</div>
              </div>
              <div className="admin-storage-bar">
                <span />
              </div>
            </div>
          </div>

          <button className="admin-details-button" type="button">
            See Details <span>→</span>
          </button>
        </section>
      </div>
    </section>
  );
}
