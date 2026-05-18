import { expect, test } from "@playwright/test";

const apiBaseUrl = process.env.E2E_API_BASE_URL ?? "http://127.0.0.1:8000";

test("renders runtime readiness from the API", async ({ page }) => {
  await page.goto("/");

  await expect(page.getByRole("heading", { name: "codex-2 delivery starter" })).toBeVisible();
  await expect(page.getByText("Runtime status")).toBeVisible();
  await expect(page.locator(".health strong")).toHaveText("OK");
  await expect(page.getByText("Database", { exact: true })).toBeVisible();
  await expect(page.getByText("Redis", { exact: true })).toBeVisible();
  await expect(page.getByText("Migrations", { exact: true })).toBeVisible();
});

test("ready endpoint reports every runtime dependency", async ({ request }) => {
  const response = await request.get(`${apiBaseUrl}/api/ready`);

  expect(response.status()).toBe(200);
  const payload = await response.json();
  expect(payload).toMatchObject({
    status: "ok",
    database: { status: "ok" },
    redis: { status: "ok" },
    migrations: { status: "ok" },
  });
});
