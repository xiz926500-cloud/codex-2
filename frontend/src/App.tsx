import { useEffect, useState } from "react";

import { getReadiness, type ReadyResponse } from "./lib/api";

type ReadinessState =
  | { status: "loading" }
  | { status: "ready"; data: ReadyResponse }
  | { status: "error"; message: string };

const checks = [
  { label: "Repository", value: "Protected main + PR workflow" },
  { label: "Frontend", value: "React + TypeScript + Vite" },
  { label: "Backend", value: "FastAPI live + ready checks" },
  { label: "Data", value: "PostgreSQL + Redis + Alembic" },
];

function App() {
  const [readiness, setReadiness] = useState<ReadinessState>({ status: "loading" });

  useEffect(() => {
    let active = true;

    getReadiness()
      .then((data) => {
        if (active) {
          setReadiness({ status: "ready", data });
        }
      })
      .catch((error: unknown) => {
        if (active) {
          const message = error instanceof Error ? error.message : "Unknown readiness check error";
          setReadiness({ status: "error", message });
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

        <div className={`health health-${readiness.status}`}>
          <span className="pulse" aria-hidden="true" />
          <div>
            <span className="health-label">Runtime status</span>
            <strong>
              {readiness.status === "loading" && "Checking"}
              {readiness.status === "ready" && readiness.data.status.toUpperCase()}
              {readiness.status === "error" && "Unavailable"}
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
        {readiness.status === "ready" && (
          <dl>
            <div>
              <dt>App</dt>
              <dd>{readiness.data.app}</dd>
            </div>
            <div>
              <dt>Version</dt>
              <dd>{readiness.data.version}</dd>
            </div>
            <div>
              <dt>Environment</dt>
              <dd>{readiness.data.environment}</dd>
            </div>
            <div>
              <dt>Database</dt>
              <dd>{readiness.data.database.status}</dd>
            </div>
            <div>
              <dt>Redis</dt>
              <dd>{readiness.data.redis.status}</dd>
            </div>
            <div>
              <dt>Migrations</dt>
              <dd>{readiness.data.migrations.status}</dd>
            </div>
          </dl>
        )}
        {readiness.status === "loading" && <p>Waiting for runtime readiness.</p>}
        {readiness.status === "error" && <p>{readiness.message}</p>}
      </section>
    </main>
  );
}

export default App;
