m4_hole_radius=2.05;

module m4_standoff(height=2.8) {
    difference() {
        // main body
        cylinder(h=height, r=6.5/2);
        // cutout hole
        translate([0,0,-1]) cylinder(h=height+2, r=m4_hole_radius+0.2);
    }
}

m4_standoff();