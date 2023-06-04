use <NopSCADlib/utils/gears.scad>

$fa=0.1;
$fs=0.1;

module epicyclic_sun_gear() {
    // homemade using NopSCADlib
    gear_height=6.5;
        difference() {
            linear_extrude(gear_height, center = true, convexity = 12)
                involute_gear_profile(0.78, 12, 20);

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

epicyclic_sun_gear_comparison();

module epicyclic_planet_gear() {
    // homemade using NopSCADlib
    gear_height=6.4;
        difference() {
            linear_extrude(gear_height, center = true, convexity = 12)
                involute_gear_profile(0.78, 12, 20);

            // cutout for the planet ring
            cutout_height=gear_height+0.1;
            cylinder(h = cutout_height, d = 5.7, center = true);
        }
}

module epicyclic_planet_gear_comparison() {
    // homemade using NopSCADlib
    epicyclic_planet_gear();
    color("red",0.2) translate ([0,0,5-8.2])
        rotate(a=90, v=[0,0,1])
            import("Planetary_Gearbox_for_the_28BYJ-48_Stepper_Motor/Planet_Gear.stl", convexity=4);
}

//epicyclic_planet_gear_comparison();