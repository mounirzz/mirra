import { pool } from "./db.js";

const isPrivate = (ip) =>
  !ip ||
  ip.startsWith("127.") ||
  ip.startsWith("10.") ||
  ip.startsWith("192.168.") ||
  ip.startsWith("::") ||
  ip === "::1";

/** Coarse country/region/city from an IP (free ip-api.com, no key). */
async function geolocate(ip) {
  if (isPrivate(ip)) return null;
  try {
    const res = await fetch(
      `http://ip-api.com/json/${ip}?fields=status,country,regionName,city`,
      { signal: AbortSignal.timeout(3000) },
    );
    const j = await res.json();
    if (j.status !== "success") return null;
    return { country: j.country, region: j.regionName, city: j.city };
  } catch {
    return null;
  }
}

/** Best client IP behind Railway's proxy. */
export function clientIp(req) {
  const fwd = req.headers["x-forwarded-for"];
  if (typeof fwd === "string" && fwd) return fwd.split(",")[0].trim();
  return req.ip || "";
}

/**
 * Middleware: records last-seen + IP and geolocates once (when country is
 * still unknown). Non-blocking — it calls next() immediately and updates in the
 * background so it never slows a request down.
 */
export function touchUser(req, _res, next) {
  next();
  const uid = req.userId;
  if (!uid) return;
  const ip = clientIp(req);
  (async () => {
    try {
      await pool.query(
        `INSERT INTO users (id, email, last_seen_at, last_ip)
         VALUES ($1, $2, now(), $3)
         ON CONFLICT (id) DO UPDATE SET
           last_seen_at = now(),
           last_ip = COALESCE($3, users.last_ip),
           email = COALESCE(EXCLUDED.email, users.email)`,
        [uid, req.email ?? null, ip || null],
      );
      if (ip && !isPrivate(ip)) {
        const r = await pool.query("SELECT country FROM users WHERE id = $1", [uid]);
        if (!r.rows[0]?.country) {
          const geo = await geolocate(ip);
          if (geo) {
            await pool.query(
              "UPDATE users SET country = $2, region = $3, city = $4 WHERE id = $1",
              [uid, geo.country, geo.region, geo.city],
            );
          }
        }
      }
    } catch (e) {
      console.error("touchUser:", e.message);
    }
  })();
}
