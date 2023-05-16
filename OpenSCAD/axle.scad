module axle() {
    color("DarkGoldenrod",0.7) union() {
        // main body
        cylinder(h=47, r=4);
        // spacer
        translate([0,0,12+1]) cylinder(h=1.5, r=6);
    }
}
axle();