const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "";

export interface HealthResponse {
  status: string;
  app: string;
  version: string;
  environment: string;
  database_configured: boolean;
  redis_configured: boolean;
}

export async function getHealth(): Promise<HealthResponse> {
  const response = await fetch(`${API_BASE_URL}/api/health`);

  if (!response.ok) {
    throw new Error(`Health check failed with status ${response.status}`);
  }

  return response.json() as Promise<HealthResponse>;
}
