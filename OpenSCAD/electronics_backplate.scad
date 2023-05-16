$fa=0.1;
$fs=0.1;

breadboard_height=9;
breadboard_width=54;
breadboard_length=84;

backplate_height=20;
backplate_width=95;
backplate_length=100;

m4_hole_radius=2.05;
m3_hole_radius=1.5;
m2_hole_radius=1.05;
m1_4_hole_radius=0.8;

module m4_mount() {
    difference() {
        cylinder(h=5, r=m4_hole_radius+2);
        translate([0,0,-0.5]) cylinder(h=6, r=m4_hole_radius);
    }
}
//m4_mount();

// Rough outline of the backplate
module electronics_backplate_plain() {
    color("SteelBlue", 0.3)
    difference() {
        union() {
            // main body rectangle
            cube([backplate_length, backplate_width, backplate_height]);
        }
        // cutout for the breadboard
        translate([(backplate_length-breadboard_length)/2,5,backplate_height-breadboard_height]) 
            cube([breadboard_length, breadboard_width, breadboard_height+1]);
        // cutout below the breadboard
        translate([(backplate_length-breadboard_length+10)/2,10,-0.5]) 
            cube([breadboard_length-10, breadboard_width-10, backplate_height]);
        // cutout below the electronic components
        translate([(backplate_length-breadboard_length+10)/2,breadboard_width+4.99,3])
            cube([breadboard_length-10, breadboard_width, backplate_height-2]);
        // square hole below the HC-SR04
        translate([70,70,-0.5]) cube([10, 10, 10]);
        // bottom mounting holes for the m4 suction cups
        translate([5,5,-0.5]) cylinder(h=11, r=m4_hole_radius);
        translate([backplate_length-5,5,-0.5]) cylinder(h=11, r=m4_hole_radius);
        // top mounting holes for the m4 suction cups
        translate([5,backplate_width-5,-0.5]) cylinder(h=11, r=m4_hole_radius);
        translate([backplate_length-5,backplate_width-5,-0.5]) cylinder(h=11, r=m4_hole_radius);
        // parallel holes for ziptie cable management
        translate([-0.5,20,5]) cube([backplate_length+1, 1.5, 3]);
        translate([-0.5,30,5]) cube([backplate_length+1, 1.5, 3]);
        // m3 screw holes for mounting a top cover, below the breadboard
        translate([3,3,backplate_height-5]) cylinder(h=5+1, r=m3_hole_radius);
        translate([backplate_length-3,3,backplate_height-5]) cylinder(h=5+1, r=m3_hole_radius);
        // m3 screw holes for mounting a top cover, slightly above the breadboard
        translate([3,breadboard_width+5,backplate_height-5]) cylinder(h=5+1, r=m3_hole_radius);
        translate([backplate_length-3,breadboard_width+5,backplate_height-5]) cylinder(h=5+1, r=m3_hole_radius);
        // m3 screw holes for mounting a top cover, above the electronic components
        translate([3,backplate_width-3,backplate_height-5]) cylinder(h=5+1, r=m3_hole_radius);
        translate([backplate_length-3,backplate_width-3,backplate_height-5]) cylinder(h=5+1, r=m3_hole_radius);
        // left cutout for the breadboard mounting bracket
        translate([-0.5, breadboard_width/2-0.5, backplate_height-breadboard_height]) 
            cube([(backplate_length-breadboard_length)/2+1,10+1,breadboard_height+1]);
        // left m3 screw hole for the breadboard mounting bracket
        translate([(backplate_length-breadboard_length)/2-5, 
                (breadboard_width+10)/2, 
                backplate_height-breadboard_height-3])
            cylinder(h=3+1, r=m3_hole_radius);
        // right cutout for the breadboard mounting bracket
        translate([backplate_length-(backplate_length-breadboard_length)/2-0.5, 
                breadboard_width/2-0.5, 
                backplate_height-breadboard_height]) 
            cube([(backplate_length-breadboard_length)/2+1,10+1,breadboard_height+1]);
        // right m3 screw hole for the breadboard mounting bracket
        translate([backplate_length-(backplate_length-breadboard_length)/2+5, 
                (breadboard_width+10)/2, 
                backplate_height-breadboard_height-3])
            cylinder(h=3+1, r=m3_hole_radius);
    }
}

// Mounting protrusion between the HC-SR04 and KY-040
module right_mounting_column() {
    color("FireBrick",0.5)
    difference() {
        cube([12.5,27,backplate_height]);
        // cutout for the HC-SR04 left side chip under the circuit board
        translate([5.5,6,backplate_height-5]) cube([10,10,5+1]);
        // remove unnecessary material from top-right corner
        translate([12.5-7,27-5,-0.5]) cube([7+1,5+1,backplate_height+1]);
        // cutout for the KY-040 middle-right pin under the circuit board
        translate([0-1,9.5,backplate_height-4]) cube([2+1,4,4+1]);
    }
}

// Screw holes for the HC-SR04 ultrasonic distance sensor
module hcsr04_screw_holes() {
    cylinder(h=5+1, r=m1_4_hole_radius);
    translate([0,17.5,0]) cylinder(h=5+1, r=m1_4_hole_radius);
    translate([42.5,0,0]) cylinder(h=5+1, r=m1_4_hole_radius);
    translate([42.5,17.5,0]) cylinder(h=5+1, r=m1_4_hole_radius);
}

// Screw holes for the KY-040 rotary encoder
module ky040_screw_holes() {
    cylinder(h=5+1, r=m3_hole_radius);
    translate([0,16.8,0]) cylinder(h=4+1, r=m3_hole_radius);
}

// Mounting protrusion between the KY-040 and SSD1300
module left_mounting_column() {
    color("FireBrick",0.5)
    difference() {
        cube([8,27+2,backplate_height]);
        // remove material from the top-right corner, to not interfere with the KY-040 pins below the circuit board
        translate([7-2,27-5,-0.5]) cube([3+1,7+1,backplate_height+1]);
        // cutout for the KY-040 middle-left pin under the circuit board
        translate([7-2,9.5,backplate_height-4]) cube([3+1,4,4+1]);
    }
}

// Screw holes for the SSD1300 OLED display
module ssd1300_screw_holes() {
    cylinder(h=5+1, r=m2_hole_radius);
    translate([23.1,0,0]) cylinder(h=4+1, r=m2_hole_radius);
    translate([0,24,0]) cylinder(h=4+1, r=m2_hole_radius); // previous y offset = 23.4
    translate([23.1,24,0]) cylinder(h=4+1, r=m2_hole_radius);
}

// Final refined version of the backplate, with precise mounting for the electronic components
module electronics_backplate() {
    difference() {
        union() {
            electronics_backplate_plain();
            translate([48.5,63,0]) right_mounting_column();
            translate([30-0.5,63,0]) left_mounting_column();
        }
        // cutout for the HC-SR04 right side
        translate([backplate_length-15,67.5,backplate_height-5]) cube([15+1,13,5+1]);
        // cutout below the SSD1300 OLED display for the vertical cables
        translate([(backplate_length-breadboard_length+10)/2,backplate_width-10,-0.5]) 
            cube([16.5,11,3+1]);
        // cutout for the SSD1300 OLED display row of resistors on the underside
        translate([(backplate_length-breadboard_length+8.5)/2-4.9,backplate_width-29.5+9.5,backplate_height-3]) 
            cube([28.5,5,3+1]);
        // cutout for a resistor of the SSD1300 OLED display
        translate([(backplate_length-breadboard_length+10)/2+16,backplate_width-29.5+9.5+5+2,backplate_height-3]) 
            cube([6.5,5,3+1]);
        // m1.4 screw holes for the HC-SR04 supersonic distance sensor
        translate([backplate_length-2-42,65.5,backplate_height-5]) hcsr04_screw_holes();
        // m3 screw holes for the KY-040 rotary encoder
        translate([backplate_length-49,68.5,backplate_height-4]) ky040_screw_holes();
        // m2 screw holes for the SSD1300 OLED display
        translate([9,backplate_width-29.5,backplate_height-4]) ssd1300_screw_holes();
    }
}

//electronics_backplate_plain();
electronics_backplate();

