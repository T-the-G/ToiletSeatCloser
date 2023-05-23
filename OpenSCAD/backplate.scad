$fa=0.1;
$fs=0.1;

// Mounting holes are 10cm apart along X and Y
mounting_holes_x_distance=100;
mounting_holes_y_distance=100;

// Mounting hole radii
m4_hole_radius=2.05;
m3_hole_radius=1.5;
mount_support_radius=m3_hole_radius+1.5;

// Height above backplate of supporting holes for the axle mounts and the ring gear base mount
mount_support_height=5;

// Height of screw holes for the suction cups
mounting_hole_height=5;

// Curvature of the ends of the mounting protrusions
mounting_web_radius=7.5;

backplate_thickness=3;
backplate_width=64;
backplate_height=90;

// Variables from full_assembly.scad
distance_between_gears=29.0385+0.15+0.05;
gearbox_z_offset=60;
gearbox_x_offset=0;

// Variables from front_axle_mount.scad
axle_mount_thickness=14;
root_height=25;

// Mounting protrusion
module mounting_web() {
    difference() {
        union() {
            // round tip of the mounting protrusion
            cylinder(h=backplate_thickness, r=mounting_web_radius);
            // extra height for the screw hole
            cylinder(h=mounting_hole_height, r=m4_hole_radius+2);
            // polygon which forms the web (connects the tip to the main rectangle)
            linear_extrude(backplate_thickness, center = false, convexity = 4) {
                // polygon points
                p1=[0,-mounting_web_radius];
                p2=[backplate_width/3-backplate_width/2+mounting_holes_x_distance/2,
                    -backplate_height/2+mounting_holes_y_distance/2];
                p3=[-backplate_width/2+mounting_holes_x_distance/2,
                    backplate_height/3+backplate_height/2-mounting_holes_y_distance/2];
                p4=[0,mounting_web_radius];
                polygon([p1,p2,p3,p4]);
            }
        }
        // cutout for the mounting hole
        translate([0,0,-0.5]) cylinder(h=mounting_hole_height+1, r=m4_hole_radius);
    }
}
//translate([backplate_width/2-mounting_holes_x_distance/2,backplate_height/2-mounting_holes_y_distance/2,0]) mounting_web();

module m3_hole_support() {
    color("Crimson", 0.9)
    difference() {
        // main body
        cylinder(h=backplate_thickness+mount_support_height, r=mount_support_radius);
        // cutout m3 hole
        translate([0,0,-0.5]) cylinder(h=backplate_thickness+5+1, r=m3_hole_radius);
    }
}
//m3_hole_support();

module axle_mount_hole_supports() {
    translate([axle_mount_thickness/4,0,0]) m3_hole_support();
    translate([axle_mount_thickness*3/4,0,0]) m3_hole_support();
    translate([axle_mount_thickness/4,root_height/2,0]) m3_hole_support();
    translate([axle_mount_thickness*3/4,root_height/2,0]) m3_hole_support();
}
//axle_mount_hole_supports();

module axle_mount_holes() {
    translate([axle_mount_thickness/4,0,-0.5]) cylinder(h=backplate_thickness+1, r=m3_hole_radius);
    translate([axle_mount_thickness*3/4,0,-0.5]) cylinder(h=backplate_thickness+1, r=m3_hole_radius);
    translate([axle_mount_thickness/4,root_height/2,-0.5]) cylinder(h=backplate_thickness+1, r=m3_hole_radius);
    translate([axle_mount_thickness*3/4,root_height/2,-0.5]) cylinder(h=backplate_thickness+1, r=m3_hole_radius);
}
//axle_mount_holes();

module ring_gear_base_mount_hole_supports() {
    translate([14/4,14,0]) m3_hole_support();
    translate([14/4,-14,0]) m3_hole_support();
    translate([14*3/4,14,0]) m3_hole_support();
    translate([14*3/4,-14,0]) m3_hole_support();
}
//ring_gear_base_mount_hole_supports();

module ring_gear_base_mount_holes() {
    translate([14/4,14,-0.5]) cylinder(h=backplate_thickness+1, r=m3_hole_radius);
    translate([14/4,-14,-0.5]) cylinder(h=backplate_thickness+1, r=m3_hole_radius);
    translate([14*3/4,14,-0.5]) cylinder(h=backplate_thickness+1, r=m3_hole_radius);
    translate([14*3/4,-14,-0.5]) cylinder(h=backplate_thickness+1, r=m3_hole_radius);
}
//ring_gear_base_mount_holes();

module backplate() {
    color("Indigo",0.6) 
    difference() {
        union() {
            // 4 mounting webs
            translate([backplate_width/2-mounting_holes_x_distance/2,backplate_height/2-mounting_holes_y_distance/2,0])
                mounting_web();
            translate([backplate_width/2+mounting_holes_x_distance/2,backplate_height/2-mounting_holes_y_distance/2,0])
                mirror([1,0,0]) mounting_web();
            translate([backplate_width/2-mounting_holes_x_distance/2,backplate_height/2+mounting_holes_y_distance/2,0])
                mirror([0,1,0]) mounting_web();
            translate([backplate_width/2+mounting_holes_x_distance/2,backplate_height/2+mounting_holes_y_distance/2,0])
                mirror([0,1,0]) mirror([1,0,0]) mounting_web();
            // main rectangle
            cube([backplate_width,backplate_height,backplate_thickness]);
            // bottom latch for the power distribution mini-breadboard
            translate([backplate_width,30.7615+6+0.5,0]) 
            difference() {
                union() {
                    // main latch body
                    cube([8.5,4,9+backplate_thickness]);
                    // small triangular support
                    linear_extrude(backplate_thickness, center = false, convexity = 4) {
                        points=[[8.5,0],[0,-10],[0,0]];
                        polygon(points);
                    }
                }
                // square hole cutout to hold the mini-breadboard by the notch
                translate([8.5/4,2.01,backplate_thickness+0.75]) cube([4.5,2,6]);
            }
            // m3 mounting supports for front axle mount
            translate([gearbox_x_offset+0,gearbox_z_offset-distance_between_gears-root_height/2,0]) 
                axle_mount_hole_supports();
            // m3 mounting supports for rear axle mount
            translate([gearbox_x_offset+50,gearbox_z_offset-distance_between_gears-root_height/2,0]) 
                axle_mount_hole_supports();
            // m3 mounting supports for the ring gear base mount (gearbox)
            translate([gearbox_x_offset,gearbox_z_offset,0]) 
                ring_gear_base_mount_hole_supports();
        }
        // hole for the power cables from the battery, and for the 6 wires going to the stepper driver board
        translate([backplate_width-12-6,30.7615+6,-0.5]) cube([5,16,backplate_height+1]);
        // parallel holes for ziptie cable management on top left web
        translate([-10,backplate_height-0,-0.5]) cube([1.5,3,backplate_thickness+1]);
        translate([0,backplate_height-0,-0.5]) cube([1.5,3,backplate_thickness+1]);
        // parallel holes for ziptie cable management in bottom center
        translate([backplate_width/2+5,15,-0.5]) cube([3,1.5,backplate_thickness+1]);
        translate([backplate_width/2+5,5,-0.5]) cube([3,1.5,backplate_thickness+1]);
        // m3 mounting holes for front axle mount
        translate([gearbox_x_offset+0,gearbox_z_offset-distance_between_gears-root_height/2,0]) 
            axle_mount_holes();
        // m3 mounting holes for rear axle mount
        translate([gearbox_x_offset+50,gearbox_z_offset-distance_between_gears-root_height/2,0])
            axle_mount_holes();
        // m3 mounting holes for the ring gear base mount (gearbox)
        translate([gearbox_x_offset,gearbox_z_offset,0]) 
            ring_gear_base_mount_holes();
        // m3 mounting hole for the mini-breadboard mounting bracket
        translate([64-(10-8.5)/2+5, 41.3+46.5+5, -0.5])
            cylinder(h=backplate_thickness+1, r=m3_hole_radius);
        // cutout for the main arm, so it can swing back beyond 3 degrees
        translate([18.5-2, backplate_height-20, -0.5]) cube([30,30,backplate_thickness+1]);
        
    }
}

backplate();







// Guides for the mounting holes
/*
translate([backplate_width/2-mounting_holes_x_distance/2,backplate_height/2-mounting_holes_y_distance/2,0]) 
    cylinder(h=backplate_thickness, r=m4_hole_radius);
translate([backplate_width/2+mounting_holes_x_distance/2,backplate_height/2-mounting_holes_y_distance/2,0]) 
    cylinder(h=backplate_thickness, r=m4_hole_radius);
translate([backplate_width/2-mounting_holes_x_distance/2,backplate_height/2+mounting_holes_y_distance/2,0]) 
    cylinder(h=backplate_thickness, r=m4_hole_radius);
translate([backplate_width/2+mounting_holes_x_distance/2,backplate_height/2+mounting_holes_y_distance/2,0]) 
    cylinder(h=backplate_thickness, r=m4_hole_radius);
*/
