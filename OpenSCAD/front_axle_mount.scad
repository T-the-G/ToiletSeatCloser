//include <NopSCADlib/core.scad>
//include <NopSCADlib/vitamins/pcbs.scad>
//include <NopSCADlib/vitamins/pcb.scad>

axle_mount_thickness=14;
axle_mount_tip_thickness=18;
root_height=25;
axle_mount_tip_radius=6;
axle_mount_length=30;

m3_hole_radius=1.5;

// Variables from backplate.scad
mount_support_radius=m3_hole_radius+1.6;
mount_support_height=5;

module plain_axle_mount() {
    color("PaleGreen",0.7) 
    difference() {
        // main body
        union() {
            // form the base
            points=[[root_height,0],[axle_mount_tip_radius,-axle_mount_length],[-axle_mount_tip_radius,-axle_mount_length],[-axle_mount_tip_radius,0]];
            linear_extrude(axle_mount_thickness, center = false, convexity = 4) 
                polygon(points);
            // form the tip
            linear_extrude(axle_mount_tip_thickness, center = false, convexity = 4) 
                translate([0,-axle_mount_length,0]) circle(r=axle_mount_tip_radius);
        }
        // cutout for the axle
        translate([0,-axle_mount_length,axle_mount_tip_thickness-axle_mount_thickness]) 
            cylinder(h=axle_mount_thickness+1, r=4.05);
        // holes for the screws
        translate([0,0.5,axle_mount_thickness/4]) rotate(a=90, v=[1,0,0]) cylinder(h=22+1, r=m3_hole_radius);
        translate([0,0.5,axle_mount_thickness*3/4]) rotate(a=90, v=[1,0,0]) cylinder(h=22+1, r=m3_hole_radius);
        translate([root_height/2,0.5,axle_mount_thickness/4]) rotate(a=90, v=[1,0,0]) cylinder(h=13+1, r=m3_hole_radius);
        translate([root_height/2,0.5,axle_mount_thickness*3/4]) rotate(a=90, v=[1,0,0]) cylinder(h=13+1, r=m3_hole_radius);
        // holes for the mount supports on the backplate
        translate([0,1,axle_mount_thickness/4]) rotate(a=90, v=[1,0,0]) 
            cylinder(h=mount_support_height+1, r=mount_support_radius);
        translate([0,1,axle_mount_thickness*3/4]) rotate(a=90, v=[1,0,0]) 
            cylinder(h=mount_support_height+1, r=mount_support_radius);
        translate([root_height/2,1,axle_mount_thickness/4]) rotate(a=90, v=[1,0,0]) 
            cylinder(h=mount_support_height+1, r=mount_support_radius);
        translate([root_height/2,1,axle_mount_thickness*3/4]) rotate(a=90, v=[1,0,0]) 
            cylinder(h=mount_support_height+1, r=mount_support_radius);
        // tiny hole to let air into the cylinder
        translate([0,-axle_mount_length,-0.5]) cylinder(h=axle_mount_tip_thickness-axle_mount_thickness+1, d=1);
    }
}

// guide holes for the screws
/*
translate([0,0.5,axle_mount_thickness/4]) rotate(a=90, v=[1,0,0]) cylinder(h=22+1, r=m3_hole_radius);
translate([0,0.5,axle_mount_thickness*3/4]) rotate(a=90, v=[1,0,0]) cylinder(h=22+1, r=m3_hole_radius);
translate([root_height/2,0.5,axle_mount_thickness/4]) rotate(a=90, v=[1,0,0]) cylinder(h=13+1, r=m3_hole_radius);
translate([root_height/2,0.5,axle_mount_thickness*3/4]) rotate(a=90, v=[1,0,0]) cylinder(h=13+1, r=m3_hole_radius);
*/

// standoffs for mounting the ULN2003 driver board using M3x4 screws
module standoff(support=false) {
    color("Crimson", 0.2)
    difference() {
        // main body
        if (support==true) cylinder(h=6, d=5);
        else cylinder(h=3, d=5);
        // cutout m3 hole
        if (support==true) translate([0,0,-1]) cylinder(h=3+1, r=m3_hole_radius);
        else translate([0,0,-0.5]) cylinder(h=3+1, r=m3_hole_radius);
    }
}
//standoff();

module front_axle_mount() {
    //color("PaleGreen",0.7)
    union() {
        // add the standoffs for the ULN2003 driver board
        translate([-3.5,-2.75,-3]) standoff();
        //translate([-2.75,-2.75,-3]) standoff();
        translate([-3.5+23.5+3,-2.75,-3]) standoff(support=true);
        translate([-3.5,-2.75-26.5-3,-3]) standoff(support=true);
        // main body using plain_axle_mount
        difference() {
            plain_axle_mount();
            // remove the protrusion for 3d-printing on the top face
            translate([-root_height/2,-axle_mount_length-axle_mount_tip_radius-1,axle_mount_thickness]) 
                cube([root_height,root_height,axle_mount_tip_thickness-axle_mount_thickness+1]);
        }

    }
}

front_axle_mount();


//translate([10,-18,-3]) rotate(a=90, v=[0,0,1]) rotate(a=180, v=[0,1,0]) pcb(ZC_A0591);

