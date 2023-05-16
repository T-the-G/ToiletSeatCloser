use <NopSCADlib/utils/gears.scad>


module epicyclic_sun_gear() {
    // homemade using NopSCADlib
    gear_height=6;
        difference() {
            linear_extrude(gear_height, center = true, convexity = 12)
                involute_gear_profile(0.8, 12, 20);

            // cutout for the 28BYJ motor shaft
            cutout_height=gear_height+0.1;
            intersection() {
                cube([3,5.1,cutout_height], center=true);
                cylinder(h = cutout_height, d = 5, center = true);
            }   
        }
}
module epicyclic_sun_gear_comparison() {
    // homemade using NopSCADlib
    epicyclic_sun_gear();
    // from the stl file
    color("red",0.2) translate ([0,0,5])
        rotate(a=90, v=[0,0,1])
            import("Planetary_Gearbox_for_the_28BYJ-48_Stepper_Motor/Sun_Gear.stl", convexity=4);
}
//epicyclic_sun_gear_comparison();
distance_between_gears=centre_distance(0.8, 12, 60, pa = 20);
echo(str("Distance between gears: ", distance_between_gears));

gear_height=10;
module main_gear() {
    difference() {
        linear_extrude(gear_height, center = false, convexity = 12)
            // arguments: modulus, num_teeth, pressure_angle
            involute_gear_profile(0.8, 60, 20);

        // cutout for the bearing (the inner diameter is 8mm)
        cutout_height=7;
        translate([0,0,-0.1]) cylinder(h = cutout_height+0.1, d = 22, center = false);
        // cutout for the shaft going through the bearing
        translate([0,0,cutout_height-0.1]) cylinder(h = gear_height-cutout_height+0.2, d = 8.1, center = false);
    }        
}

arm_thickness=10;
tip_radius=5;
root_radius=10;
arm_length=200-25-tip_radius;
module pusher_arm() {
    // main arm
    linear_extrude(arm_thickness, center = false, convexity = 4) union() {
        // form the tip
        translate([-arm_length,0,0]) circle(r=tip_radius);
        // form the base
        circle(r=root_radius);
        // connect tip and base with a polygon
        points=[[0,root_radius],[-arm_length,tip_radius],[-arm_length,-tip_radius],[0,-root_radius]];
        polygon(points);
    }
}

arm_support_offset=50;
module arm_support() {
    // extra bit for the arm, makes the tip wider and adds support for printing
    intersection() {
        translate([-arm_length-tip_radius,-root_radius,0]) 
            cube([arm_length+tip_radius-arm_support_offset,root_radius*2,gear_height]);
        pusher_arm();
    }
}

module main_gear_and_arm() {
    union() {
        color("Olive", 0.7) main_gear();
        color("DarkSalmon", 0.7) translate([0,15,gear_height]) pusher_arm();
        color("DarkSalmon", 0.7) translate([0,15,0]) arm_support();
    }
}
main_gear_and_arm();
//pusher_arm();
//main_gear();
//color("red",0.2) translate([0,0,10]) cylinder(h=0.1, d=50, center=true);

