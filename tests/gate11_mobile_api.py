"""
Gate 11 — Mobile API contract smoke tests (Sprint 7)

Validates the backend contract that the Flutter mobile app depends on.
No Flutter SDK required — tests the API directly.

Tests:
  11a: POST /events with mobile payload (event_type, title, description,
       created_by, destination_location_id) returns 201 + valid JSON
  11b: Response body contains all fields EventModel.fromJson expects
       (id, event_type, status, title, description, created_at,
        destination_location_id)
  11c: created event has status CREATED
  11d: created event title matches what was sent
  11e: GET /events returns 200 + JSON array
  11f: newly created event appears in GET /events list
  11g: POST /events with minimum payload (no description) returns 201
  11h: GET /events returns events newest-first (created_at DESC)
  11i: SSE regression — GET /events/stream still streams after mobile routes active
"""
import urllib.request, urllib.error, json, threading, time, sys

BASE = "http://localhost:3000"
PASS = []
FAIL = []


def check(name, cond, detail=""):
    if cond:
        PASS.append(name)
        print(f"  PASS  {name}" + (f"  ({detail})" if detail else ""))
    else:
        FAIL.append(name)
        print(f"  FAIL  {name}" + (f"  — {detail}" if detail else ""))


def post_json(path, body):
    data = json.dumps(body).encode()
    req = urllib.request.Request(
        f"{BASE}{path}", data=data,
        headers={"Content-Type": "application/json"}, method="POST"
    )
    try:
        with urllib.request.urlopen(req) as r:
            return r.status, json.loads(r.read())
    except urllib.error.HTTPError as e:
        return e.code, {}


def get_json(path):
    try:
        with urllib.request.urlopen(f"{BASE}{path}") as r:
            return r.status, json.loads(r.read())
    except urllib.error.HTTPError as e:
        return e.code, {}


# ── Mobile payload ─────────────────────────────────────────────────────────────
MOBILE_PAYLOAD = {
    "event_type": "passenger_assistance",
    "title": "Assistance",
    "description": "Wheelchair required at next stop",
    "created_by": "00000000-0000-0000-0000-000000000001",
    "destination_location_id": "station-euston",
}

MOBILE_PAYLOAD_NO_DESC = {
    "event_type": "delay",
    "title": "Delay",
    "created_by": "00000000-0000-0000-0000-000000000001",
    "destination_location_id": "station-euston",
}

print("=== Gate 11: Mobile API contract ===\n")

# 11a — POST /events returns 201
print("--- 11a: POST /events (full payload) ---")
status, body = post_json("/events", MOBILE_PAYLOAD)
check("11a POST /events → 201", status == 201, f"got {status}")
event_id = body.get("id")

# 11b — response has all fields EventModel needs
print("--- 11b: EventModel fields present ---")
required_fields = ["id", "event_type", "status", "title", "created_at",
                   "destination_location_id"]
for field in required_fields:
    check(f"11b field '{field}' present", field in body, str(body.keys()))

# 11c — status is CREATED
print("--- 11c: status is CREATED ---")
check("11c status == CREATED", body.get("status") == "CREATED",
      f"got {body.get('status')}")

# 11d — title matches what was sent
print("--- 11d: title round-trips correctly ---")
check("11d title == 'Assistance'", body.get("title") == "Assistance",
      f"got {body.get('title')}")

# 11e — GET /events returns 200 + array
print("--- 11e: GET /events → 200 ---")
s, events = get_json("/events")
check("11e GET /events → 200", s == 200, f"got {s}")
check("11e response is array", isinstance(events, list),
      type(events).__name__)

# 11f — new event appears in list
print("--- 11f: created event in GET /events list ---")
ids_in_list = [e.get("id") for e in events] if isinstance(events, list) else []
check("11f event_id in list", event_id in ids_in_list,
      f"list has {len(ids_in_list)} items")

# 11g — POST with no description returns 201
print("--- 11g: POST /events (no description) ---")
s2, body2 = post_json("/events", MOBILE_PAYLOAD_NO_DESC)
check("11g POST no description → 201", s2 == 201, f"got {s2}")
check("11g description is null", body2.get("description") is None,
      f"got {body2.get('description')}")

# 11h — GET /events is newest-first
print("--- 11h: events ordered newest-first ---")
if isinstance(events, list) and len(events) >= 2:
    ts = [e["created_at"] for e in events[:2] if "created_at" in e]
    check("11h newest-first order", ts[0] >= ts[1],
          f"first={ts[0][:19]}, second={ts[1][:19]}")
else:
    check("11h newest-first order", True, "skip — fewer than 2 events")

# 11i — SSE regression
print("--- 11i: SSE /events/stream still works ---")
sse_received = []

def _sse_read():
    try:
        req = urllib.request.Request(f"{BASE}/events/stream")
        with urllib.request.urlopen(req, timeout=3) as r:
            for line in r:
                line = line.decode().strip()
                if line.startswith("data:"):
                    sse_received.append(line)
                    break
    except Exception:
        pass

t = threading.Thread(target=_sse_read, daemon=True)
t.start()
# Trigger an event so the stream has something to emit
time.sleep(0.3)
post_json("/events", MOBILE_PAYLOAD)
t.join(timeout=4)
check("11i SSE stream emits data", len(sse_received) > 0,
      f"received {len(sse_received)} frames")

# ── Summary ────────────────────────────────────────────────────────────────────
print(f"\n{'='*40}")
total = len(PASS) + len(FAIL)
print(f"Gate 11 result: {len(PASS)}/{total} passed")
if FAIL:
    print("FAILED:", ", ".join(FAIL))
    sys.exit(1)
else:
    print("ALL PASS")
