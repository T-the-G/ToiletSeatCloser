use <epicyclic_gear_subassembly.scad>

m3_hole_radius=1.5;
m4_hole_radius=2.05;
// Variables from backplate.scad
mount_support_radius=m3_hole_radius+1.6;
mount_support_height=5;

// Cutout for the arm
module cutout(plate_thickness = 15) {
    // 3 screw holes
    color("red",0.7) translate([0,0.02,0])
        translate ([19.23,0,-plate_thickness/2-0.05]) 
            cylinder(h = plate_thickness+0.9, r = m4_hole_radius, center = false);
    color("red",0.7) translate([2.1,0.02,0])
        rotate(a=120, v=[0,0,1]) translate([20.20725942,0,0]) 
            cylinder(h = plate_thickness+0.1, r = m4_hole_radius, center = true);
    color("red",0.7) translate([2.1,0.02,0])
        rotate(a=240, v=[0,0,1]) translate([20.20725942,0,0]) 
            cylinder(h = plate_thickness+0.1, r = m4_hole_radius, center = true);
    // Main cutout cylinder
    color("DarkSlateGray",0.7) translate([0,0,0]) cylinder(h = plate_thickness, r = 18.60-1.5, center = true);
}

// Cutout for a ziptie
module ziptie_cutout() {
    difference() {
        union() {
            cylinder(h=3, r=10);
        }
        translate([0,0,-0.5]) cylinder(h=3+1, r=8.5);
        translate([-10.5,-21,-0.5]) cube([21,21,3+1]);
    }
}
//ziptie_cutout();

// Epicyclic ring gear base mounted to backplate
mount_length = 30; // distance from wall
mount_side = 37.2; // diameter of the epicyclic ring gear base
base_height = 13.96;  // height of the epicyclic ring gear base
module ring_gear_base_mount() {
    union() {
        // Arm which connects the ring gear base to the backplate
        color("BurlyWood", 0.7) 
        difference() {
            // Main arm
            translate([-mount_side/2,0,0]) cube([mount_side,mount_length,base_height]);
            // Cutout
            translate([0,0,base_height/2]) cutout(base_height+1);
            // Screw holes
            translate([-14,mount_length+1,14/4]) rotate(a=90, v=[1,0,0]) cylinder(r=m3_hole_radius, h=16+1);
            translate([-14,mount_length+1,14*3/4]) rotate(a=90, v=[1,0,0]) cylinder(r=m3_hole_radius, h=16+1);
            translate([14,mount_length+1,14/4]) rotate(a=90, v=[1,0,0]) cylinder(r=m3_hole_radius, h=16+1);
            translate([14,mount_length+1,14*3/4]) rotate(a=90, v=[1,0,0]) cylinder(r=m3_hole_radius, h=16+1);
            // holes for the mount supports on the backplate
            translate([-14,mount_length+1,14/4]) rotate(a=90, v=[1,0,0]) 
                cylinder(r=mount_support_radius, h=mount_support_height+1);
            translate([-14,mount_length+1,14*3/4]) rotate(a=90, v=[1,0,0]) 
                cylinder(r=mount_support_radius, h=mount_support_height+1);
            translate([14,mount_length+1,14/4]) rotate(a=90, v=[1,0,0]) 
                cylinder(r=mount_support_radius, h=mount_support_height+1);
            translate([14,mount_length+1,14*3/4]) rotate(a=90, v=[1,0,0]) 
                cylinder(r=mount_support_radius, h=mount_support_height+1);
            // parallel holes for ziptie cable management
            translate([7,27,-0.5]) cube([3,1.5,base_height+1]);
            translate([7,17,-0.5]) cube([3,1.5,base_height+1]);
        }
        // Epicyclic ring gear base
        color("PaleTurquoise",0.3) ring_gear_base();
    }
}

// Screw hole guides
/*
translate([-14,mount_length+1,14/4]) rotate(a=90, v=[1,0,0]) cylinder(r=m3_hole_radius, h=16+1);
translate([-14,mount_length+1,14*3/4]) rotate(a=90, v=[1,0,0]) cylinder(r=m3_hole_radius, h=16+1);
translate([14,mount_length+1,14/4]) rotate(a=90, v=[1,0,0]) cylinder(r=m3_hole_radius, h=16+1);
translate([14,mount_length+1,14*3/4]) rotate(a=90, v=[1,0,0]) cylinder(r=m3_hole_radius, h=16+1);
*/
ring_gear_base_mount();