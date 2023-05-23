m3_hole_radius=1.5;

$fa=0.1;
$fs=0.1;

module mini_breadboard_mounting_bracket(breadboard_thickness=9, overhang=2) {
    color("YellowGreen",0.5)
    difference() {
        union() {
            // base
            cube([10,8,3]);
            // wall
            cube([10,2,breadboard_thickness+2]);
            // lip
            translate([0,-overhang,breadboard_thickness]) cube([10,overhang,2]);
            // support walls
            points=[[-6,0],[0,0],[0,breadboard_thickness+2-3]];
            translate([2,2,3]) rotate(a=-90, v=[0,0,1]) rotate(a=90, v=[1,0,0]) 
                linear_extrude(2, center=false, convexity=4) polygon(points);
            translate([10,2,3]) rotate(a=-90, v=[0,0,1]) rotate(a=90, v=[1,0,0]) 
                linear_extrude(2, center=false, convexity=4) polygon(points);
        }
        // m3 screw hole
        translate([5,5,-0.5]) cylinder(h=4, r=m3_hole_radius);
        // cutout for the breadboard knob/protrusion thing
        translate([5-4.5/2,-0.05,-1]) cube([4.5,2.1,6.5+1]);
    }
}
//cube([4.5,2,5.5]);







mini_breadboard_mounting_bracket();
//translate([0,-29,0]) import("Breadboard/Mini_Breadboard.stl", convexity=4);