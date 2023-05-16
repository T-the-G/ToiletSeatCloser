use <front_axle_mount.scad>

axle_mount_thickness=14;
root_height=25;
m3_hole_radius=1.5;

$fa=0.1;
$fs=0.1;

module rear_axle_mount() {
    difference() {
        translate([0,0,axle_mount_thickness]) mirror([0,0,1]) plain_axle_mount();
        // hole for power cables ziptie
        translate([-4.5,-5,-0.5]) cube([1.5,3,axle_mount_thickness+1]);
        translate([-7,-5,axle_mount_thickness-5]) cube([3,3,6]);
        // parallel holes for ziptie cable management
        translate([5,-5,-0.5]) cube([3,1.5,axle_mount_thickness+1]);
        translate([5,-15,-0.5]) cube([3,1.5,axle_mount_thickness+1]);
    }
}

/*
union() {
    translate([-4.5,-5,-1]) cube([1.5,3,9]);
    translate([-3.75,-2,8]) rotate(a=90, v=[1,0,0]) difference() {
        cylinder(h=3, r=0.75);
        translate([-2,-2,-1]) cube([4,2,5]);
    }
    translate([-4-4.5+0.75,-5,7.25]) cube([4,3,1.5]);
}
*/
// guide holes for the screws
/*
translate([0,0,axle_mount_thickness]) mirror([0,0,1]) {
    translate([0,0.5,axle_mount_thickness/4]) rotate(a=90, v=[1,0,0]) cylinder(h=20+1, r=m3_hole_radius);
    translate([0,0.5,axle_mount_thickness*3/4]) rotate(a=90, v=[1,0,0]) cylinder(h=20+1, r=m3_hole_radius);
    translate([root_height/2,0.5,axle_mount_thickness/4]) rotate(a=90, v=[1,0,0]) cylinder(h=12+1, r=m3_hole_radius);
    translate([root_height/2,0.5,axle_mount_thickness*3/4]) rotate(a=90, v=[1,0,0]) cylinder(h=12+1, r=m3_hole_radius);
}
*/
rear_axle_mount();






//axle_mount_thickness=10;
//axle_mount_tip_thickness=15;
//root_height=25;
//axle_mount_tip_radius=6;
//axle_mount_length=30;
//module rear_axle_mount() {
//    color("PaleGreen",0.7) difference() {
//        // main body
//        union() {
//            // form the base
//            points=[[root_height,0],[axle_mount_tip_radius,-axle_mount_length],[-axle_mount_tip_radius,-axle_mount_length],[-axle_mount_tip_radius,0]];
//            linear_extrude(axle_mount_thickness, center = false, convexity = 4) 
//                polygon(points);
//            // form the tip
//            translate([0,0,-axle_mount_tip_thickness+axle_mount_thickness])
//                linear_extrude(axle_mount_tip_thickness, center = false, convexity = 4) 
//                    translate([0,-axle_mount_length,0]) circle(r=axle_mount_tip_radius);
//        }
//        // cutout for the axle
//        translate([0,-axle_mount_length,-axle_mount_tip_thickness+axle_mount_thickness-1]) cylinder(h=axle_mount_thickness+1, r=4.05);
//    }
//}
//rear_axle_mount();