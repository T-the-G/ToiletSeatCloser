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
use <gears.scad>
use <ring_gear_and_front_axle_mount.scad>

//axle();                                             // axle.stl, quantity 1
//backplate();                                        // backplate.stl, quantity 1
//mini_breadboard_mounting_bracket();                 // breadboard_mounting_bracket.stl, quantity 3
//electronics_backplate();                            // electronics_backplate.stl, quantity 1
//gearbox_cover();                                    // gearbox_cover.stl, quantity 1
//main_gear_and_arm();                                // main_gear_and_arm.stl, quantity 1
//rotate(a=90, v=[1,0,0]) import("Planetary_Gearbox_for_the_28BYJ-48_Stepper_Motor/Planet_Carrier.stl", convexity=4); // planet_carrier.stl, quantity 2
//rear_axle_mount();                                  // rear_axle_mount.stl, quantity 1
//ring_gear_base_mount();                             // ring_gear_base_mount.stl, quantity 1
//import("Planetary_Gearbox_for_the_28BYJ-48_Stepper_Motor/Sun_Gear.stl", convexity=4); // sun_gear.stl, quantity 1
//ring_gear_and_front_axle_mount();                   // ring_gear_and_front_axle_mount.stl, quantity 1
//// New gears, because the downloaded ones are terrible
//epicyclic_sun_gear();                               //sun_gear.stl, quantity 1
//epicyclic_planet_gear();                            //planet_gear.stl, quantity 6