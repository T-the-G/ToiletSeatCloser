// for the 28BYJ_48 stepper motor
include <NopSCADlib/vitamins/geared_steppers.scad>

$fs=0.1;

m4_hole_radius=2.05;

// modify ring gear base to take m4 screws instead of American 38 screws
module ring_gear_base() {
    plate_thickness = 13.97;
    difference() {
        union() {
            // fill the screw holes
            color("red",0.7) translate([0,0.02,0])
                translate ([19.23,0,0]) 
                    cylinder(h = plate_thickness, r = 3, center = false);
            color("red",0.7) translate([2.1,0.02,0])
                rotate(a=120, v=[0,0,1]) translate([20.20725942,0,0]) 
                    cylinder(h = plate_thickness, r = 3, center = false);
            color("red",0.7) translate([2.1,0.02,0])
                rotate(a=240, v=[0,0,1]) translate([20.20725942,0,0]) 
                    cylinder(h = plate_thickness, r = 3, center = false);
            // ring gear base
            translate ([9.16,10.8,0]) rotate(a=90, v=[1,0,0]) rotate(a=180, v=[0,1,0])
                import("Planetary_Gearbox_for_the_28BYJ-48_Stepper_Motor/Ring_Gear_Base.stl", convexity=32);
        }
        // screw holes
        color("red",0.7) translate([0,0.02,0])
            translate ([19.23,0,-0.5]) 
                cylinder(h = plate_thickness+1, r = m4_hole_radius, center = false);
        color("red",0.7) translate([2.1,0.02,0])
            rotate(a=120, v=[0,0,1]) translate([20.20725942,0,-0.5]) 
                cylinder(h = plate_thickness+1, r = m4_hole_radius, center = false);
        color("red",0.7) translate([2.1,0.02,0])
            rotate(a=240, v=[0,0,1]) translate([20.20725942,0,-0.5]) 
                cylinder(h = plate_thickness+1, r = m4_hole_radius, center = false);
    }
}
//ring_gear_base();

// modify gearbox cover to take m4 screws instead of American 38 screws
module gearbox_cover() {
    cover_thickness=2.5;
    difference() {
        union() {
            // fill the screw holes
            color("red",0.7) translate([0,0.02,0])
                translate ([19.23,0,0]) 
                    cylinder(h = cover_thickness, r = 3, center = false);
            color("red",0.7) translate([2.1,0.02,0])
                rotate(a=120, v=[0,0,1]) translate([20.20725942,0,0]) 
                    cylinder(h = cover_thickness, r = 3, center = false);
            color("red",0.7) translate([2.1,0.02,0])
                rotate(a=240, v=[0,0,1]) translate([20.20725942,0,0]) 
                    cylinder(h = cover_thickness, r = 3, center = false);
            // gearbox cover
            translate([14.11,16.75,0]) rotate(180) rotate(a=90, v=[1,0,0])
                import("Planetary_Gearbox_for_the_28BYJ-48_Stepper_Motor/Gearbox_Cover.stl", convexity=4);
        }
        // screw holes
        color("red",0.7) translate([0,0.02,0])
            translate ([19.23,0,-0.5]) 
                cylinder(h = cover_thickness+1, r = m4_hole_radius, center = false);
        color("red",0.7) translate([2.1,0.02,0])
            rotate(a=120, v=[0,0,1]) translate([20.20725942,0,-0.5]) 
                cylinder(h = cover_thickness+1, r = m4_hole_radius, center = false);
        color("red",0.7) translate([2.1,0.02,0])
            rotate(a=240, v=[0,0,1]) translate([20.20725942,0,-0.5]) 
                cylinder(h = cover_thickness+1, r = m4_hole_radius, center = false);
    }
}
//gearbox_cover();

// #########################################
// ASSEMBLY SECTION
// #########################################

module epicyclic_gear_subassembly(include_base=true) {    
    // Begin epicyclic gear section:
    // Epicyclic sun gear
    color("yellow",0.2) translate ([0,0,5-1])
        rotate(a=90, v=[0,0,1])
            import("Planetary_Gearbox_for_the_28BYJ-48_Stepper_Motor/Sun_Gear.stl", convexity=4);
    // Epicyclic ring
    color("LightCoral",0.2) translate([22.5,-8.5,6-1.25]) rotate(a=180, v=[0,0,1]) rotate(a=90, v=[1,0,0])
        import("Planetary_Gearbox_for_the_28BYJ-48_Stepper_Motor/Planet_Carrier.stl", convexity=4);
    // Epicyclic planet gears
    color("blue",0.2) translate ([10.15,0,5-1])
        rotate(a=15, v=[0,0,1])
            import("Planetary_Gearbox_for_the_28BYJ-48_Stepper_Motor/Planet_Gear.stl", convexity=4);
    color("blue",0.2) rotate(120) translate ([10.15,0,5-1])
        rotate(a=15, v=[0,0,1])
            import("Planetary_Gearbox_for_the_28BYJ-48_Stepper_Motor/Planet_Gear.stl", convexity=4);
    color("blue",0.2) rotate(240) translate ([10.15,0,5-1])
        rotate(a=15, v=[0,0,1])
            import("Planetary_Gearbox_for_the_28BYJ-48_Stepper_Motor/Planet_Gear.stl", convexity=4);
    // Gearbox cover
    //color("PaleGreen",0.2) translate([14.11,16.75,15-1]) rotate(180) rotate(a=90, v=[1,0,0])
    //    import("Planetary_Gearbox_for_the_28BYJ-48_Stepper_Motor/Gearbox_Cover.stl", convexity=4);
    color("PaleGreen",0.2) translate([0,0,14]) gearbox_cover();
    // Epicyclic ring gear base
    if (include_base)
    //color("PaleTurquoise",0.2) translate ([9.16,10.8,1-1])
    //    rotate(a=90, v=[1,0,0])
    //        rotate(a=180, v=[0,1,0])
    //            import("Planetary_Gearbox_for_the_28BYJ-48_Stepper_Motor/Ring_Gear_Base.stl", convexity=32);
        color("PaleTurquoise",0.3) ring_gear_base();
    // End epicyclic gear section. 
}

translate([0,0,0])
    // 28BYJ stepper motor module from NopSCADlib
    rotate(a=-90, v=[0,0,1])
        translate([0,0,0.95-1])
            rotate(a=-180, v=[0,1,0])
                geared_stepper(28BYJ_48);
translate([0,0,0]) epicyclic_gear_subassembly();