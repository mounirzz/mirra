import express from "express";

import { requireAuth } from "./auth.js";
import { migrate } from "./migrate.js";
import { affirmationsRouter } from "./routes/affirmations.js";
import { preferencesRouter } from "./routes/preferences.js";
import { themesRouter } from "./routes/themes.js";

const app = express();
app.use(express.json({ limit: "1mb" }));

// Public health check (used by Railway).
app.get("/health", (_req, res) => res.json({ ok: true }));

// Everything else needs a valid Cognito id token.
app.use("/preferences", requireAuth, preferencesRouter);
app.use("/affirmations", requireAuth, affirmationsRouter);
app.use("/themes", requireAuth, themesRouter);

// eslint-disable-next-line no-unused-vars
app.use((err, _req, res, _next) => {
  console.error("unhandled:", err?.message);
  res.status(500).json({ error: "server_error" });
});

const port = process.env.PORT || 3000;
migrate()
  .catch((e) => console.error("migrate failed (continuing):", e.message))
  .finally(() => {
    app.listen(port, () => console.log(`mirra-server listening on :${port}`));
  });
