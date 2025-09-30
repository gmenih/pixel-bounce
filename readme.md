# Bounce Network — Prototype Spec (Love2D prototype)

**Goal:** Build a playable prototype of an idle/clicker game where a bouncing entity (“Bouncer”) ricochets inside a 2D arena, auto-collecting spawned points (“Sparks”). Corner hits trigger jackpot effects that drive exponential progression. Start minimal (single square arena, one Bouncer) and scaffold systems for upgrades, multi‑screen, and polygonal arenas.

> **Scope note for this prototype:** simple shapes only (circles/regular polygons), no art, minimal UI. Menu with a single **Play** button that starts a new run.

---

## 1) Thematic Glossary (prototype names)

- **Bouncer**: the moving logo/mascot (circle).
- **Spark**: collectible point (small circle).
- **Screen**: a bounded arena (regular polygon). Starts as a square; later unlocks hex, octagon, etc.
- **Corner Event**: special effect when Bouncer hits a corner with sufficient precision.
- **Channel**: an upgrade track (speed, size, magnetism, etc.).
- **Network**: meta-layer managing multiple Screens (late prototype stub).

(Names are placeholders; keep them in code/config as identifiers.)

---

## 2) Game States & Flow

1. **Main Menu** → centered title and a single **Play** button.
2. **Gameplay** → single Screen visible; HUD shows Sparks total, multiplier, Bouncer count, corner counter.
3. **Pause** (ESC) → resume/quit to menu.

No save/load in the initial cut (stub interfaces allowed).

---

## 3) Core Systems (MVP)

### 3.1 Physics & Arena

- **Arena**: regular polygon with N sides (N = 4 initially). Defined by center, radius, and vertex list.
- **Walls**: perfect reflection (elastic). Use surface normal to reflect velocity.
- **Corners**: vertices of the polygon; corner window defined by two thresholds:
  - **Distance**: closest-approach to vertex ≤ `cornerProximityPx`.
  - **Incidence**: angle between velocity vector and corner bisector ≤ `cornerAngleDeg`.

- **Time step**: fixed `dt` (e.g., 1/120s) with accumulator.

### 3.2 Bouncer

- Components: position, velocity, radius, speed scalar, magnet radius, multiplier contribution.
- Movement: `pos += vel * speed * dt`.
- Wall collision: reflect `vel` about wall normal.
- Spark collection: if distance ≤ (bouncerRadius + sparkRadius) → collect.
- Magnetism: Sparks within `magnetRadius` accelerate toward Bouncer (lerp/seek with capped accel).

### 3.3 Spark Spawning & Collection

- Spawn rate: base rate per second, capped by max concurrent Sparks.
- Spawn position: random inside polygon (rejection sampling or triangulation); ensure min distance from walls.
- Value: base value \* global multiplier.
- On collect: increment total Sparks, show tiny pop number (optional), remove Spark.

### 3.4 Corner Events (Jackpot)

- On qualified corner hit:
  - Increment **Corner Counter**.
  - Trigger one of the configured effects (weighted random or cycling list):
    1. **Clone**: spawn a new Bouncer with slight velocity variance.
    2. **Burst**: spawn `cornerBurstCount` Sparks at random positions.
    3. **Boost**: apply temporary global multiplier buff for `boostDuration`.

  - Play a distinct SFX/flash (placeholder: color invert for 0.1s).

### 3.5 Upgrades (Spend Sparks)

- Prototype a simple **Upgrades Panel** (toggle with `U`) with four Channels:
  1. **Speed** (multi-level): +`speedScalar` per level.
  2. **Size** (multi-level): +radius → (note: larger radius collects easier but reduces precision; intentional tradeoff).
  3. **Magnetism** (multi-level): +`magnetRadius`.
  4. **Cornering** (multi-level): relax thresholds (increase `cornerProximityPx`, increase `cornerAngleDeg`).

- Costs: geometric progression per channel.
- Purchasing immediately applies globally (affects all Bouncers).

---

## 4) Progression Hooks (within prototype)

- **Milestones**
  - M1: First corner hit → tutorial toast explains jackpots.
  - M2: 10 corner hits → unlock **Corner Event Choice** screen (player picks preferred effect weights).
  - M3: 100 corner hits → unlock **Second Screen** (stub Network UI; switch with `[ and ]`).

- **Second Screen behavior**: independent arena with its own Bouncers/Sparks but shared currency and upgrades.

---

## 5) Polygonal Arenas (Add Corner Feature)

- Player can unlock new **Screen Shapes**:
  - Square (N=4) → Hex (N=6) → Octagon (N=8).

- Each additional corner slightly increases base corner-hit opportunities but reduces direct wall lengths, subtly changing dynamics.
- For MVP, switch shape via milestone or a dummy upgrade; rebuild vertex list and recompute wall normals.

---

## 6) HUD & UI (minimal)

- **Top-left**: Sparks total (integer), **x Multiplier** (float), **Bouncers** count, **Corner Hits**.
- **Top-right**: Current Screen name (e.g., "Screen A — Square"), Shape (N), and per-screen corner hits.
- **Bottom**: Press `U` for Upgrades, `[ / ]` to switch Screen (after M3), `ESC` to pause.
- **Menu**: Title + **Play** button (starts a new run).

---

## 7) Data & Tuning (defaults)

Use a central config table/file to allow quick tuning without code changes to logic. Initial suggested values:

```
physics:
  fixedDt: 0.008333   # 120 Hz
  bouncerBaseSpeed: 180.0   # px/s
  bouncerRadius: 10.0       # px
  magnetRadius: 0.0         # px (level 0)
  sparkRadius: 4.0          # px
  maxSparks: 120
  spawnPerSecond: 8         # baseline
  wallPadding: 8            # min spawn distance from wall

corner:
  proximityPx: 14.0         # distance threshold to vertex
  angleDeg: 18.0            # within ± this of the corner bisector
  burstCount: 30            # Sparks spawned on Burst
  boostMultiplier: 2.0      # temporary multiplier
  boostDuration: 6.0        # seconds
  effectWeights: { Clone: 0.5, Burst: 0.35, Boost: 0.15 }

upgrades:
  speed:
    base: 100
    growth: 1.35
    delta: 0.10            # +10% speed per level
  size:
    base: 120
    growth: 1.35
    delta: 1.5             # +1.5 px radius per level
  magnet:
    base: 150
    growth: 1.4
    delta: 22              # +22 px per level
  cornering:
    base: 200
    growth: 1.45
    proximityDelta: 2.0
    angleDelta: 2.0

screens:
  shapes: [4, 6, 8]
  secondScreenUnlockCorners: 100
```

All costs are in Sparks; round to integers for display.

---

## 8) Randomness, Determinism, Debugging

- RNG: seed once at run start; expose seed in HUD for reproducibility.
- Debug overlay (toggle with `F3`):
  - Draw polygon vertices and normals.
  - Display Bouncer velocity vector and angle.
  - Highlight corner windows (proximity circles; angle cone).
  - Show current effectWeights.

---

## 9) Corner Hit Detection (precise rule)

Given vertex `V`, adjacent edges with unit normals `n1, n2`, let the **corner bisector** direction `b` be normalized sum of edge inward normals. A hit qualifies if **within the same frame**:

1. The segment from previous position `P0` to current `P1` intersects the union of proximity disks around `V` with radius `cornerProximityPx`.
2. The angle between Bouncer’s incoming velocity `v_in` and `b` satisfies: `acos( dot( normalize(v_in), normalize(b) ) ) ≤ cornerAngleDeg`.
3. The contact isn’t simultaneously resolving a wall overlap with both adjacent edges (prevent double-counting); clamp to one Corner Event per frame.

When qualified, reflect using the closest-edge normal as usual (no special physics), then trigger the event.

---

## 10) Multi-Screen (Network) Stub

- Maintain a list of Screens: each has shape (N), its own entities, and stats.
- Global systems: currency, upgrades, multiplier apply to all Screens.
- Input `[ / ]` cycles active Screen. Only active Screen renders; others simulate in background.
- Corner counts tracked per Screen and globally.

---

## 11) Upgrade Purchasing UX (prototype)

- Press `U` → modal panel with four upgrade rows.
- Each row: Name, Level, Cost (next), Effect summary, **Buy** button.
- If insufficient Sparks, button disabled.
- Close with `U` or click outside.

---

## 12) Performance Targets

- 60 FPS with up to: 50 Bouncers, 300 Sparks per Screen, 2 Screens simulating.
- Use object pools for Sparks; avoid table churn in tight loops.

---

## 13) Effects & Feel (placeholders)

- Corner Event flash: invert arena background for 0.1s; small screen shake.
- Collect pop: tiny number floats up 20px, fades over 0.4s.
- Boost aura: arena border pulses during active multiplier.

---

## 14) Telemetry (console only)

- Log: total runtime, corner hits, max concurrent Bouncers, Sparks collected/min, average time between Corner Events.

---

## 15) Acceptance Criteria

- [ ] Main Menu with **Play** starts a fresh run.
- [ ] Bouncer moves and reflects correctly within a square.
- [ ] Sparks spawn and are collectible; total increases.
- [ ] Corner Event fires with configured thresholds and plays a visible feedback.
- [ ] Corner Event randomly executes Clone/Burst/Boost with weights.
- [ ] Upgrades panel purchases levels and updates behavior in real time.
- [ ] After 100 Corner Events, a second Screen unlocks; switching works; both simulate.
- [ ] Shape change to Hex and Octagon is reachable (via milestone or dev toggle).
- [ ] Debug overlay visualizes normals, corner windows, and velocity.

---

## 16) Stretch Goals (if time permits)

- **Corner Vortex** effect: corners store Spark charges and periodically explode.
- **Event Choice**: on each Corner Event, present 3 random effect cards; pick one.
- **Prestige Stub**: a reset button that grants a permanent +5% multiplier.
- **Screen Traits**: per-Screen modifiers (e.g., +spawn rate, +corner proximity, -gravity).

---

## 17) Controls Summary

- **Mouse**: UI only.
- **Keyboard**: `U` Upgrades, `[` previous Screen, `]` next Screen, `F3` debug, `ESC` pause.

---

## 18) Visual Layout (wireframe cues)

- Arena centered, bordered polygon; HUD bands at edges; upgrades modal centered.
- Keep palettes minimal: background gray, Bouncer white, Sparks light gray, HUD white text.

---

## 19) Risks & Notes

- Corner detection must feel **rare but learnable**; start strict and let Cornering upgrades loosen it.
- Size upgrade reduces corner precision intentionally (tension between farming Sparks vs. chasing corners).
- Multi-Screen baseline must not tank FPS; simulate offscreen with lowered visual updates if needed.

---

## 20) Handoff Notes

- No external assets. No save file. Keep all constants in one config table for quick tuning.
- Keep systems modular: `Physics`, `Spawn`, `CornerEvents`, `Upgrades`, `Screens`.
- Provide a developer console command to force a Corner Event for testing (even if it bypasses thresholds).
