// Uncomment each line one by one, Press F6, export as STL

$fa=0.1;
$fs=0.1;

use <axle.scad>
use <backplate.scad>
use <breadboard_mounting_bracket.scad>
use <electronics_backplate.scad>
use <front_axle_mount.scad>
use <epicyclic_gear_subassembly.scad>
use <main_gear.scad>
use <rear_axle_mount.scad> 
use <ring_gear_base_mount.scad>

axle();                                             // axle.stl, quantity 1
//backplate();                                        // backplate.stl, quantity 1
//mini_breadboard_mounting_bracket();                 // breadboard_mounting_bracket.stl, quantity 3
//electronics_backplate();                            // electronics_backplate.stl, quantity 1
//front_axle_mount();                                 // front_axle_mount.stl, quantity 1
//gearbox_cover();                                    // gearbox_cover.stl, quantity 2
//main_gear_and_arm();                                // main_gear_and_arm.stl, quantity 1
//rotate(a=90, v=[1,0,0]) import("Planetary_Gearbox_for_the_28BYJ-48_Stepper_Motor/Planet_Carrier.stl", convexity=4); // planet_carrier.stl, quantity 2
//import("Planetary_Gearbox_for_the_28BYJ-48_Stepper_Motor/Planet_Gear.stl", convexity=4); // planet_gear.stl, quantity 6
//rear_axle_mount();                                  // rear_axle_mount.stl, quantity 1
//ring_gear_base();                                   // ring_gear_base.stl, quantity 1
//ring_gear_base_mount();                             // ring_gear_base_mount.stl, quantity 1
//import("Planetary_Gearbox_for_the_28BYJ-48_Stepper_Motor/Sun_Gear.stl", convexity=4); // sun_gear.stl, quantity 1