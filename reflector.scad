// Helical Antenna Reflector — 1280 MHz FPV
// Convex conical reflector based on:
// Ilic et al., IEEE AWPL 2006, DOI 10.1109/LAWP.2006.873625
//
// Geometry (wavelengths):
//   Base diameter  D1 = 0.75λ
//   Aperture diam  D2 = 2.50λ
//   Height          H = 0.50λ
// Profile: convex using t → 1-(1-t)²  (fast open near base, gradual near aperture)

// ── Shared parameters ────────────────────────────────────────────────────────
freq_mhz       = 1280;          // target frequency [MHz]
wall_thickness = 2.0;           // shell wall thickness [mm]
base_thickness = 3.0;           // solid base plate thickness [mm]
fn_profile     = 120;           // $fn for rotational surfaces
fn_base        = 120;           // $fn for base disc

// ── Derived ──────────────────────────────────────────────────────────────────
c_mm_per_s = 299792458e3;       // speed of light [mm/s]
lambda     = c_mm_per_s / (freq_mhz * 1e6);   // wavelength [mm]

D1 = 0.75 * lambda;             // base diameter [mm]
D2 = 2.50 * lambda;             // aperture diameter [mm]
H  = 0.50 * lambda;             // height [mm]

R1 = D1 / 2;
R2 = D2 / 2;

echo(str("λ = ", lambda, " mm"));
echo(str("D1 = ", D1, " mm  D2 = ", D2, " mm  H = ", H, " mm"));

// ── Convex profile helper ────────────────────────────────────────────────────
// Returns radius at normalised height t ∈ [0,1]
// t=0 → base (R1), t=1 → aperture (R2)
// Convex: r(t) = R1 + (R2-R1)*(1-(1-t)^2)
function convex_r(t) = R1 + (R2 - R1) * (1 - pow(1 - t, 2));

// Build polygon points for the outer profile (base→aperture, bottom→top)
profile_steps = 80;
function profile_pts(r_offset) =
    [ for (i = [0 : profile_steps])
        let(t = i / profile_steps,
            z = t * H,
            r = convex_r(t) + r_offset)
        [r, z] ];

// ── Shell construction ────────────────────────────────────────────────────────
// Outer surface polygon (outer wall)
outer_pts = profile_pts(0);
// Inner surface polygon (inner wall, offset inward by wall_thickness)
inner_pts = profile_pts(-wall_thickness);

module reflector_shell() {
    difference() {
        // Outer solid of revolution
        rotate_extrude(angle=360, $fn=fn_profile)
            polygon(concat(
                [[0, 0]],            // centre bottom
                outer_pts,           // outer profile base→aperture
                [[0, H]]             // centre top (aperture)
            ));

        // Hollow interior (inner solid)
        translate([0, 0, base_thickness])
        rotate_extrude(angle=360, $fn=fn_profile)
            polygon(concat(
                [[0, 0]],
                inner_pts,
                [[0, H]]
            ));
    }
}

// ── Final part ───────────────────────────────────────────────────────────────
reflector_shell();
