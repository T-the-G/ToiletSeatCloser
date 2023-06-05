include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/geared_steppers.scad>
include <NopSCADlib/vitamins/pcbs.scad>
include <NopSCADlib/vitamins/pcb.scad>
include <NopSCADlib/vitamins/ball_bearings.scad>
include <NopSCADlib/vitamins/ball_bearing.scad >

// Show threads on parts made by NopSCADlib
$show_threads = false;


// Include the individual parts and their relevant variables
use <backplate.scad>
backplate_thickness=3;
use <epicyclic_gear_subassembly.scad>
use <main_gear.scad>
distance_between_gears=29.0385-1.5;
//use <ring_gear_base_mount.scad>
mount_length = 30; // distance from wall
//use <front_axle_mount.scad>
use <rear_axle_mount.scad>
use <axle.scad>
use <breadboard_mounting_bracket.scad>
use <ring_gear_and_front_axle_mount.scad>

// Assembly variables
gearbox_x_offset=0;
gearbox_z_offset=60;
main_gear_y_offset=30;

// 3 screws and 1 washer per screw to hold the motor and gearbox in place (except for one screw which takes 2 washers)
translate([gearbox_x_offset-16.5-1.6,-mount_length,gearbox_z_offset]) 
    rotate(a=-90, v=[0,1,0]) rotate(a=180, v=[0,0,1]) {
        translate([0,0.02,0])
            translate ([19.23,0,0]) {
                // screw 1
                screw(M5_pan_screw, 35);
                // washer 1,1
                translate([0,0,-0.8]) washer(M5_washer);
                // washer 1,2
                translate([0,0,-1.6]) washer(M5_washer);
            }
        translate([2.1,0.02,0])
            rotate(a=120, v=[0,0,1]) translate([20.20725942,0,0]) {
                // screw 2
                screw(M5_pan_screw, 35);
                // washer 2,1
                translate([0,0,-0.8]) washer(M5_washer);
                // washer 2,2
                //translate([0,0,-1.6]) washer(M4_washer);
            }
        translate([2.1,0.02,0])
            rotate(a=240, v=[0,0,1]) translate([20.20725942,0,0]) {
                // screw 3
                screw(M5_pan_screw, 35);
                // washer 3,1
                translate([0,0,-0.8]) washer(M5_washer);
                // washer 3,2
                //translate([0,0,-1.6]) washer(M4_washer);
            }   
    }

// Base mount with 1 stage of the epicyclic gear
translate([gearbox_x_offset,-mount_length,gearbox_z_offset]) rotate(a=90, v=[0,1,0]) 
    epicyclic_gear_subassembly(include_base=false);
translate([gearbox_x_offset,-mount_length,gearbox_z_offset]) rotate(a=90, v=[0,1,0]) 
    //ring_gear_base_mount();
    ring_gear_and_front_axle_mount();

// Motor with 1 stage of the epicyclic gear
translate([gearbox_x_offset-16.5,-mount_length,gearbox_z_offset]) rotate(a=90, v=[0,1,0]) {
    // Epicyclic gear
    epicyclic_gear_subassembly();
    
    // 28BYJ stepper motor module from NopSCADlib
    rotate(a=-90, v=[0,0,1])
        translate([0,0,0.95-1])
            rotate(a=-180, v=[0,1,0])
                geared_stepper(28BYJ_48);
}

// Axle
translate([gearbox_x_offset+4,-30,gearbox_z_offset-distance_between_gears])
    rotate(a=90, v=[0,1,0]) axle();

// Bearing for the main gear
translate([gearbox_x_offset+16.5+2+3.5,-main_gear_y_offset,gearbox_z_offset-distance_between_gears])
    rotate(a=90, v=[0,1,0]) ball_bearing(BB608);

// Main gear
translate([gearbox_x_offset+16.5+2,-main_gear_y_offset,gearbox_z_offset-distance_between_gears]) 
    rotate(a=90, v=[0,1,0]) rotate(a=-3-3, v=[0,0,1]) main_gear_and_arm();

/*
// Front axle mount
translate([gearbox_x_offset+0,0,gearbox_z_offset-distance_between_gears]) 
    rotate(a=90, v=[0,1,0]) front_axle_mount();
*/

// Rear axle mount
translate([gearbox_x_offset+50,0,gearbox_z_offset-distance_between_gears]) 
    rotate(a=90, v=[0,1,0]) rear_axle_mount();
    
// Power distribution mini-breadboard
color("DarkSlateGray",0.4) translate([63.8+2,0,63+4.5]) rotate(a=180, v=[0,1,0]) rotate(a=90, v=[1,0,0]) 
    import("Breadboard/Mini_Breadboard.stl", convexity=4);
    
// Mini-breadboard mounting bracket
translate([64-(10-8.5)/2,0,41.3+46.5]) rotate(a=90, v=[1,0,0]) mini_breadboard_mounting_bracket();

// ULN2003 based stepper motor driver board
translate([-3,-18,gearbox_z_offset-distance_between_gears-10]) 
    rotate(a=0, v=[1,0,0]) rotate(a=-90, v=[0,0,1]) rotate(a=90, v=[1,0,0]) pcb(ZC_A0591);

// Backplate
translate([0,backplate_thickness,0]) rotate(a=90, v=[1,0,0]) 
    backplate();

