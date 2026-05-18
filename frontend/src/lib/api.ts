import type { HealthResponse } from "./api-client";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "";

export type { HealthResponse } from "./api-client";

export async function getHealth(): Promise<HealthResponse> {
  const response = await fetch(`${API_BASE_URL}/api/health`);

  if (!response.ok) {
    throw new Error(`Health check failed with status ${response.status}`);
  }

  return response.json() as Promise<HealthResponse>;
}
