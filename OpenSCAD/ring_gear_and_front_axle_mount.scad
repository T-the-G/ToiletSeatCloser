use <ring_gear_base_mount.scad>
m4_hole_radius=2.05;
mount_length = 30; // distance from wall
mount_side = 37.2; // diameter of the epicyclic ring gear base
base_height = 13.96;  // height of the epicyclic ring gear base
use <front_axle_mount.scad>
axle_mount_thickness=14;

distance_between_gears=29.0385-1.5; // previously correction factor was +0.1

module ring_gear_and_front_axle_mount() {
    union() {
        // ring gear base mount
        ring_gear_base_mount();
        // front axle mount
        translate([distance_between_gears, mount_length, 0]) front_axle_mount(standoff_offset=2);
        // bridge the gap between them 
        difference() {
            translate([mount_side/2-0.1,0,0]) cube([3.5,mount_length,axle_mount_thickness]);
            // cutout for the screw hole where the two parts meet
            translate ([19.23,0.02,-0.1])  cylinder(h = base_height+0.2, r = m4_hole_radius, center = false);
        }
    }
}

ring_gear_and_front_axle_mount();