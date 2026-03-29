// Helical Antenna Holder — 1280 MHz FPV
// Cross-pattern support (two perpendicular arms + central hub).
// A continuous helix channel is cut through the arms so the wire threads
// through wherever the helix path intersects the arm material.

// ── Shared parameters ────────────────────────────────────────────────────────
freq_mhz       = 1280;     // target frequency [MHz]
turns          = 5;        // number of helix turns
wire_d         = 2.0;      // copper wire diameter [mm]
former_d_frac  = 0.28;     // helix CL diameter as fraction of λ
pitch_frac     = 0.23;     // helix pitch as fraction of λ
segs_per_turn  = 60;       // path resolution
hole_clearance = 0.4;      // extra radial clearance in channel [mm]

// Cross arm geometry
arm_width      = 8.0;      // width of each arm [mm]
arm_thickness  = 4.0;      // thickness (axial depth) of each arm [mm]
hub_r          = 12.0;     // central hub radius [mm]
fn_sphere      = 14;
fn_hub         = 80;
fn_arm         = 4;        // box arms need no fn

// ── Derived ──────────────────────────────────────────────────────────────────
c_mm_per_s = 299792458e3;
lambda     = c_mm_per_s / (freq_mhz * 1e6);

helix_d  = former_d_frac * lambda;
helix_r  = helix_d / 2;
pitch    = pitch_frac * lambda;
total_h  = pitch * turns;

channel_r = wire_d / 2 + hole_clearance;

// Arms reach from hub edge to just beyond helix radius
arm_reach = helix_r + arm_width;

total_segs = turns * segs_per_turn;

echo(str("λ = ", lambda, " mm"));
echo(str("Helix D = ", helix_d, " mm  Pitch = ", pitch, " mm  H = ", total_h, " mm"));

// ── Helix path ────────────────────────────────────────────────────────────────
function helix_pt(i) =
    let(angle = i * 360 / segs_per_turn,
        z     = i * pitch / segs_per_turn)
    [helix_r * cos(angle), helix_r * sin(angle), z];

// ── Helix channel — chained hull() of sphere pairs ────────────────────────────
module helix_channel() {
    for (i = [0 : total_segs - 1]) {
        hull() {
            translate(helix_pt(i))
                sphere(r=channel_r, $fn=fn_sphere);
            translate(helix_pt(i + 1))
                sphere(r=channel_r, $fn=fn_sphere);
        }
    }
}

// ── Cross body ────────────────────────────────────────────────────────────────
module cross_body() {
    // Central hub
    cylinder(r=hub_r, h=total_h, center=false, $fn=fn_hub);

    // Arm along X axis
    translate([-arm_reach, -arm_width/2, 0])
        cube([2 * arm_reach, arm_width, arm_thickness]);

    // Arm along Y axis
    translate([-arm_width/2, -arm_reach, 0])
        cube([arm_width, 2 * arm_reach, arm_thickness]);
}

// ── Final part ────────────────────────────────────────────────────────────────
difference() {
    cross_body();
    helix_channel();
}
