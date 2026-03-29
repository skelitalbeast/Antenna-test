// Helical Antenna Former — 1280 MHz FPV
// Solid cylinder with a continuous helix groove.
// The wound copper wire sits in the groove to control diameter and pitch.

// ── Shared parameters ────────────────────────────────────────────────────────
freq_mhz        = 1280;     // target frequency [MHz]
turns           = 5;        // number of helix turns
wire_d          = 2.0;      // copper wire diameter [mm]
former_d_frac   = 0.28;     // helix CL diameter as fraction of λ
pitch_frac      = 0.23;     // helix pitch as fraction of λ
segs_per_turn   = 60;       // path resolution (segments per turn)
groove_clearance = 0.3;     // extra radial clearance in groove [mm]
end_pad         = 3.0;      // solid cylinder extension above/below helix [mm]
fn_sphere       = 14;       // $fn for hull spheres (keep modest for speed)
fn_cyl          = 80;       // $fn for main cylinder

// ── Derived ──────────────────────────────────────────────────────────────────
c_mm_per_s = 299792458e3;
lambda     = c_mm_per_s / (freq_mhz * 1e6);

helix_d   = former_d_frac * lambda;   // helix centreline diameter [mm]
helix_r   = helix_d / 2;
pitch     = pitch_frac  * lambda;     // axial pitch per turn [mm]
total_h   = pitch * turns;            // total helix height [mm]

former_r  = helix_r - wire_d / 2 - groove_clearance;  // outer radius of cylinder
cyl_h     = total_h + 2 * end_pad;

groove_r  = wire_d / 2 + groove_clearance;             // groove sphere radius

echo(str("λ = ", lambda, " mm"));
echo(str("Helix D = ", helix_d, " mm  Pitch = ", pitch, " mm  Total H = ", total_h, " mm"));
echo(str("Former OD = ", 2 * former_r, " mm  Cyl H = ", cyl_h, " mm"));

total_segs = turns * segs_per_turn;

// ── Helix path points (on surface of cylinder) ───────────────────────────────
function helix_pt(i) =
    let(angle = i * 360 / segs_per_turn,
        z     = end_pad + i * pitch / segs_per_turn)
    [helix_r * cos(angle), helix_r * sin(angle), z];

// ── Groove — chained hull() of sphere pairs ───────────────────────────────────
module helix_groove() {
    for (i = [0 : total_segs - 1]) {
        hull() {
            translate(helix_pt(i))
                sphere(r=groove_r, $fn=fn_sphere);
            translate(helix_pt(i + 1))
                sphere(r=groove_r, $fn=fn_sphere);
        }
    }
}

// ── Former ────────────────────────────────────────────────────────────────────
difference() {
    cylinder(r=former_r, h=cyl_h, center=false, $fn=fn_cyl);
    helix_groove();
}
