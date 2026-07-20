import express from "express";

import { requireAuth } from "./auth.js";
import { touchUser } from "./geo.js";
import { migrate } from "./migrate.js";
import { affirmationsRouter } from "./routes/affirmations.js";
import { engagementRouter } from "./routes/engagement.js";
import { preferencesRouter } from "./routes/preferences.js";
import { subscriptionRouter } from "./routes/subscription.js";
import { themesRouter } from "./routes/themes.js";

const app = express();
app.set("trust proxy", true); // Railway sits behind a proxy → real client IP
app.use(express.json({ limit: "1mb" }));

// Public health check (used by Railway).
app.get("/health", (_req, res) => res.json({ ok: true }));

// Everything else needs a valid Cognito id token; `touchUser` records activity
// + IP location (non-blocking) for every authenticated call.
const auth = [requireAuth, touchUser];
app.use("/preferences", auth, preferencesRouter);
app.use("/affirmations", auth, affirmationsRouter);
app.use("/themes", auth, themesRouter);
app.use("/subscription", auth, subscriptionRouter);
app.use("/engagement", auth, engagementRouter);

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
