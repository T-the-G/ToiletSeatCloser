include <NopSCADlib/core.scad>
include <NopSCADlib/vitamins/pcbs.scad>
include <NopSCADlib/vitamins/pcb.scad>
include <NopSCADlib/vitamins/led.scad>
include <NopSCADlib/vitamins/leds.scad>
use <electronics_backplate.scad>
use <breadboard_mounting_bracket.scad>



// Small breadboard
color("Seashell", 0.5) translate([52.5,7,11]) rotate(a=90, v=[0,0,1])
    import("Breadboard/Small_Breadboard.stl", convexity=4);



// RaspberryPi Pico
translate([40,32,21]) rotate(a=180, v=[0,0,1]) pcb(RPI_Pico);

// Rotary encoder KY-040
translate([44,77.06,20]) rotate(a=90, v=[0,0,1]) pcb(KY_040);

// OLED display SSD1300
color("LightSeaGreen",0.5) translate([21,76.8,21])
    import("Breadboard/SSD1306_OLED_Display(128x64).stl", convexity=4);

// Ultrasonic distance sensor HC-SR04
color("LightSeaGreen",0.5) translate([54.5,84.2,21.6]) rotate(a=180, v=[0,0,1]) rotate(a=180, v=[0,1,0]) import("Breadboard/HC-SR04.stl", convexity=4);
    
// Phototransistor SFH 300
translate([50,17,21+5]) led(LED5mm, "white");

// Left breadboard mounting bracket
translate([8,54/2,11]) rotate(90) mini_breadboard_mounting_bracket(9,2);

// Right breadboard mounting bracket
translate([100-8,54/2+10,11]) rotate(-90) mini_breadboard_mounting_bracket(9,2);

// Electronics backplate
electronics_backplate();