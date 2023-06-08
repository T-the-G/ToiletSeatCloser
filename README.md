# Toilet Seat Closer
Lever that closes the toilet seat

# Table of Contents  

- [Bill of Materials](#bill-of-materials)  
  - [3D-printed parts](#3d-printed-parts)  
  - [Electronics](#electronics)
  - [Fasteners and other mechanical parts](#fasteners-and-other-mechanical-parts)


# Bill of Materials

This bill of materials is based on components I had lying around. It is perfectly possible to use different components. For example, one could use a photoresistor instead of a phototransistor, or a voltage regulator module instead of the DC-DC stepdown converter (or power the whole thing from a USB power supply plugged into the wall).

## 3D-printed parts

| Item        | Quantity  |
| :---        | :----     |
| Axle                  | 1     |
| Backplate             | 1     |
| Breadboard mounting bracket   | 3     |
| Electronics backplate | 1     |
| Gearbox cover         | 1     |
| m4 standoff 2.8mm     | 2     |
| m4 standoff 3.2mm     | 1     |
| Main gear and arm     | 1     |
| Planet carrier        | 2     |
| Planet gear           | 6     |
| Rear axle mount       | 1     |
| Ring gear base        | 1     |
| Ring gear and front axle mount      | 1     |
| Sun gear              | 1     |

## Electronics

| Item        | Quantity  | Description   | 
| :---        | :----       | :---        |
| RaspberryPi Pico            | 1     | Controlls the device  |
| 28BYJ-48 stepper motor      | 1     | Actuates the arm      |
| ULN2003 based driver board  | 1     | For driving the 28BYJ stepper motor |
| SFH 300 phototransistor     | 1     | For detecting the ambient light level |
| HC-SR04 ultrasonic distance sensor  | 1     | For detecting movement |
| KY-040 rotary encoder       | 1     | For manual control of the system |
| SSD1306 OLED display        | 1     | Displays information about the device status, 0.96 inch, 128 x 64 resolution |
| 3S LiPo battery             | 1     | Rated at 52Ah @ 11.1V (57.72Wh) |
| LiPo battery charger        | 1     | Used to charge the LiPo battery |
| MP1584EN DC-DC buck module  | 1     | Provides steady voltage for the RPi Pico and the stepper motor, input 4.5-28V, output 0.8-20V 3A |
| Mini breadboard             | 1     | Used as a power supply, has 170 pinholes, measures approximately 46\*35\*9mm |
| Small breadboard            | 1     | Used as a motherboard, has 400 pinholes, measures approximately 82\*54\*9mm |
| 22AWG wires                 | 1     | For connecting components on the breadboards |
| Breadboard pin headers      | 4     | For connecting the MP1584EN DC-DC stepdown module to the mini breadboard |
| 680KΩ resistor              | 1     | Used in the 11.1V-to-3V voltage divider |
| 220KΩ resistor              | 1     | Used in the 11.1V-to-3V voltage divider |
| 100KΩ resistor              | 1     | Used for the SFH 300 phototransistor |
| T-plug or Deans connector   | 1     | For connecting the battery to the mini breadboard |

## Fasteners and other mechanical parts

Note that the screw hole position/diameter on electronic components may vary between manufacturers. The relevant modifications can be made in front_axle_mount.scad (for the ULN2003 based driver board), and in electronics_backplate.scad (for the remaining components).

| Item        | Quantity  | Description   | 
| :---        | :----       | :---        |
| Suction cup | 8           | For attaching the backplates to a wall, 4cm diameter, M4\*10 thread  |
| M4\*35      | 3           | For holding the 28BYJ stepper motor and epicyclic gearbox in place  |
| M3 washer   | 12          | To spread the load of the m3 screws on the backplate |
| M3\*25      | 4           | For connecting the front and rear axle mounts to the backplate      |
| M3\*18      | 4           | For connecting the epicyclic ring gear base to the backplate        |
| M3\*16      | 4           | For connecting the front and rear axle mounts to the backplate      |
| M3\*6       | 3           | For connecting the breadboards to the backplates via the mounting brackets |
| M3\*4       | 5           | For mounting the ULN2003 driver board and KY-040 rotary encoder     |
| M2\*4       | 4           | For mounting the SSD1300 OLED display to the electronics backplate  |
| M1.4\*6     | 4           | For mounting the HC-SR04 ultrasonic distance sensor to the electronics backplate |
| Spring      | 1           | For pushing the axle back into place after manual adjustment, diameter 7mm, length 12.5mm |
| Cable sleeve  | 1         | Woven sheath that wraps around a 5-10mm bundle of cables, length approximately 50cm |
| 608RS bearing | 1         | Deep groove ball bearing which sits between the main gear and axle, bore diameter 8mm, external diameter 22mm, width 7mm |
| Lubricant   | 1           | For the epicyclic gearbox |