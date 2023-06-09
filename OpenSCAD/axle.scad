module axle_old() {
    color("DarkGoldenrod",0.7) union() {
        // main body
        cylinder(h=47, r=4);
        // spacer
        translate([0,0,12+1]) cylinder(h=1.5, r=6);
    }
}

module axle() {
    color("DarkGoldenrod",0.7) union() {
        // main body
        cylinder(h=47, r=4-0.2);
        // spacer
        translate([0,0,12+1]) cylinder(h=1.5, r=6);
        // friction fit onto bearing
        translate([0,0,14.5]) cylinder(h=7, r=4.05);
    }
}

axle();