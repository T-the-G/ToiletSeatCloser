use <../electronics_backplate.scad>
use <../front_axle_mount.scad>

$fs=0.1;
$fa=0.1;

module driver_board_mounting_test() {
    union() {
        difference() {
            front_axle_mount();
            translate([-20,-45,-0.01]) cube([50,50,20]);
        }
    }
}

module electronics_mounting_test() {
    difference() {
        union() {
            difference() {
                // remove all except for the mounting protrusions for the electronics
                electronics_backplate();
                // cutout the bottom breadboard frame
                translate([-1,-1,-1]) cube([110, 65, 30]);
                // cutout material from the top
                translate([-1,91,-1]) cube([110, 10, 30]);
                // cutout material from the left
                translate([-3,60,-1]) cube([10, 35, 30]);
                // cutout material from the bottom (leave only the mounting platforms, not the backplate)
                translate([-1,60,-1]) cube([110, 40, 14+1]);
            }
            // add a backplate to hold the mounting platforms together
            color("LightBlue", 0.5) translate([9,64-5,14]) cube([91, 26+5, 2]);
            // add the standoffs for the driver board
            translate([60+23,85-21,14+2-0.01]) rotate(a=180, v=[0,0,1]) rotate(a=180, v=[1,0,0]) 
                driver_board_mounting_test();
            // extend the backplate for the final driver board standoff
            color("LightBlue", 0.5) translate([83.5,29,14]) cube([6, 30+1, 2]); // translate([9+44.5,64+25.9,14])
        }
        // cutout material from the top-right
        translate([86.9,86,-1]) cube([15, 10, 30]);
        // cutout the base from the bottom-left
        translate([6,54,-1]) cube([51, 10, 20]);
        // make hole in base at left
        translate([14,70+8,-1]) cube([15, 15, 30]);
        // make hole in base at right top
        translate([61,68+8,-1]) cube([25+1, 16, 30]);
        // make hole in base at right bottom
        translate([63,50,-1]) cube([20, 16, 30]);
        // make hole in base at middle
        translate([37.5,70,-1]) cube([11, 15, 30]);
    }
}

electronics_mounting_test();

