# Toilet Seat Closer
Lever that closes the toilet seat

##### Table of Contents  

- [Bill of Materials](#bill-of-materials)  
  - [3D-printed parts](#3d-printed-parts)  
  - [Electronics](#electronics)
  - [Fasteners](#fasteners)


# Bill of Materials

## 3D-printed parts

| Item        | Quantity  |
| :---        | :----     |
| Axle                  | 1     |
| Backplate             | 1     |
| Breadboard mounting bracket   | 3     |
| Electronics backplate | 1     |
| Front axle mount      | 1     |
| Gearbox cover         | 2     |
| Main gear and arm     | 1     |
| Planet carrier        | 2     |
| Planet gear           | 6     |
| Rear axle mount       | 1     |
| Ring gear base        | 1     |
| Ring gear base mount  | 1     |
| Sun gear              | 1     |

## Electronics

| Item        | Quantity  | Description   | 
| :---        | :----       | :---        |
| RaspberryPi Pico            | 1     | Controlls the device  |
| 28BYJ stepper motor         | 1     | Actuates the arm      |
| ULN2003 based driver board  | 1     | For driving the 28BYJ stepper motor |
| SFH 300 phototransistor     | 1     | For detecting the ambient light level |
| HC-SR04 ultrasonic distance sensor  | 1     | For detecting movement |
| KY-040 rotary encoder       | 1     | For manual control of the system |
| SSD1300 OLED display        | 1     | Displays information about the device status, 0.96 inch, 128 x 64 resolution |
| 3S LiPo battery             | 1     | Rated at 52Ah @ 11.1V (57.72Wh) |
| LiPo battery charger        | 1     | Used to charge the LiPo battery |
| Mini breadboard             | 1     | Used as a power supply, has 170 pinholes, measures approximately 46\*35\*9mm |
| Small breadboard            | 1     | Used as a motherboard, has 400 pinholes, measures approximately 82\*54\*9mm |
| 22AWG wires                 | 1     | For connecting components on the breadboards |
| 680kΩ resistor              | 2     | Used in the 11.1V-to-5V and 11.1V-to-3V voltage dividers |
| 470kΩ resistor              | 1     | Used in the 11.1V-to-5V voltage divider |
| 220kΩ resistor              | 1     | Used in the 11.1V-to-3V voltage divider |
| 100kΩ resistor              | 1     | Used for the SFH 300 phototransistor |

## Fasteners

Note that the screw hole diameters on electronic components may vary between manufacturers.

| Item        | Quantity  | Description   | 
| :---        | :----       | :---        |
| M4\*35      | 3           | For holding the 28BYJ stepper motor and epicyclic gearbox in place  |
| M4 washers  | 4           | To space out the M4 screws holding the stepper motor and gearbox in place |
| M3\*25      | 4           | For connecting the front and rear axle mounts to the backplate      |
| M3\*18      | 4           | For connecting the epicyclic ring gear base to the backplate        |
| M3\*16      | 4           | For connecting the front and rear axle mounts to the backplate      |
| M3\*6       | 2           | For connecting the small breadboard to the electronics backplate via the mounting brackets |
| M3\*4       | 5           | For mounting the ULN2003 driver board and KY-040 rotary encoder     |
| M2\*4       | 4           | For mounting the SSD1300 OLED display to the electronics backplate  |
| M1.4\*6     | 4           | For mounting the HC-SR04 ultrasonic distance sensor to the electronics backplate |
