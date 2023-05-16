color("DarkRed", 0.7) import("Hole_Size_Gauge.STL", convexity=32);

$fs=0.01;
$fa=0.01;

translate([5,5,0]) cylinder(h=10, d=3);
translate([77,15,0]) cylinder(h=10, d=3);