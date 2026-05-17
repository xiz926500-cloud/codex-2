import { useEffect, useState } from "react";

import { getHealth, type HealthResponse } from "./lib/api";

type HealthState =
  | { status: "loading" }
  | { status: "ready"; data: HealthResponse }
  | { status: "error"; message: string };

const checks = [
  { label: "Repository", value: "Protected main + PR workflow" },
  { label: "Frontend", value: "React + TypeScript + Vite" },
  { label: "Backend", value: "FastAPI health endpoint" },
  { label: "Data", value: "PostgreSQL + Redis ready" },
];

function App() {
  const [health, setHealth] = useState<HealthState>({ status: "loading" });

  useEffect(() => {
    let active = true;

    getHealth()
      .then((data) => {
        if (active) {
          setHealth({ status: "ready", data });
        }
      })
      .catch((error: unknown) => {
        if (active) {
          const message = error instanceof Error ? error.message : "Unknown health check error";
          setHealth({ status: "error", message });
        }
      });

    return () => {
      active = false;
    };
  }, []);

  return (
    <main className="shell">
      <section className="status-panel" aria-labelledby="status-title">
        <div>
          <p className="eyebrow">Project baseline</p>
          <h1 id="status-title">codex-2 delivery starter</h1>
          <p className="lede">
            A practical full-stack baseline for building, testing, reviewing, and shipping small
            product features with Codex.
          </p>
        </div>

        <div className={`health health-${health.status}`}>
          <span className="pulse" aria-hidden="true" />
          <div>
            <span className="health-label">API status</span>
            <strong>
              {health.status === "loading" && "Checking"}
              {health.status === "ready" && health.data.status.toUpperCase()}
              {health.status === "error" && "Unavailable"}
            </strong>
          </div>
        </div>
      </section>

      <section className="grid" aria-label="Project stack">
        {checks.map((check) => (
          <article className="metric" key={check.label}>
            <span>{check.label}</span>
            <strong>{check.value}</strong>
          </article>
        ))}
      </section>

      <section className="details" aria-label="Runtime details">
        <h2>Runtime details</h2>
        {health.status === "ready" && (
          <dl>
            <div>
              <dt>App</dt>
              <dd>{health.data.app}</dd>
            </div>
            <div>
              <dt>Version</dt>
              <dd>{health.data.version}</dd>
            </div>
            <div>
              <dt>Environment</dt>
              <dd>{health.data.environment}</dd>
            </div>
            <div>
              <dt>Data services</dt>
              <dd>
                {health.data.database_configured && health.data.redis_configured
                  ? "Configured"
                  : "Needs configuration"}
              </dd>
            </div>
          </dl>
        )}
        {health.status === "loading" && <p>Waiting for the API health endpoint.</p>}
        {health.status === "error" && <p>{health.message}</p>}
      </section>
    </main>
  );
}

export default App;
