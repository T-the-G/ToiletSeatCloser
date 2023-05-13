# General libraries
from machine import Pin, I2C, ADC
import utime
# SSD1300 OLED display
from ssd1306 import SSD1306_I2C, framebuf
from oled import Write, SSD1306_I2C
from oled.fonts import ubuntu_mono_15, ubuntu_mono_20
# handle interrupts
from micropython import alloc_emergency_exception_buf, schedule
alloc_emergency_exception_buf(100)

####################################
# Variables that need callibration #
####################################
action_after_seconds        = 600       # seconds to wait after presence is no longer detected to close the lid
brightness_threshold        = 25000      # phototransistor brightness threshold for detecting restroom light
motion_threshold            = 5         # difference in distance (cm) between successive measurements to detect motion 
polling_interval_presence   = 1         # seconds between polling when presence has been detected
polling_interval_standby    = 5         # seconds between polling during standby
step_count                  = 2048      # stepper motor steps per revolution
step_sleep_close            = 0.003     # seconds between stepper motor steps during lid close action
step_sleep_open             = 0.002     # seconds between stepper motor steps during lid open action
previous_distance           = 165       # typical distance (cm) measured when nobody is in the restroom

###################
#   Define pins   #
###################
# SSD1300 OLED I2C
pin_oled_sda        = Pin(16)
pin_oled_scl        = Pin(17)
# KY-040 rotary encoder
pin_ky040_button    = 10
# HC-SR04 ultrasonic distance sensor
pin_hcsr04_trigger  = Pin(14, Pin.OUT)
pin_hcsr04_echo     = Pin(15, Pin.IN)
# SFH 300 phototransistor
pin_sfh300_adc      = ADC(26)
# 28BYJ-48 stepper motor
pin_motor_1         = Pin(18, Pin.OUT)
pin_motor_2         = Pin(19, Pin.OUT)
pin_motor_3         = Pin(20, Pin.OUT)
pin_motor_4         = Pin(21, Pin.OUT)

####################
# Glabal variables #
####################
# Pushing the button cycles between three modes:
# AUTO:     poll sensors and close lid after presence is no longer detected
# MANUAL:   immediately close the lid, ignoring presence detection
# DEBUG:    manually adjust position, and display sensor output. Useful for callibration
mode_debug  = False
mode_manual = False

##################
# Setup the OLED #
##################
oled_width=128
oled_height= 64
# the first argument of I2C is the set of i2c pins which should be initialised
i2c=I2C(0,scl=pin_oled_scl,sda=pin_oled_sda,freq=200000)
oled = SSD1306_I2C(oled_width,oled_height,i2c)
# fonts
write15 = Write(oled, ubuntu_mono_15)
write20 = Write(oled, ubuntu_mono_20)

###########################
# Setup the stepper motor #
###########################
motor_direction = False # True for clockwise, False for counter-clockwise
# defining stepper motor sequence
step_sequence = [[1,0,0,0],
                 [0,1,0,0],
                 [0,0,1,0],
                 [0,0,0,1]]
motor_pins = [pin_motor_1, pin_motor_2, pin_motor_3, pin_motor_4]


#################
#   Functions   #
#################

button_pushed = False
def button_interrupt(pin):
    global button_pushed
    button_pushed = True

def detect_presence():
    global previous_distance
    brightness_detected = False
    motion_detected = False
    presence_detected = False
    brightness = measure_brightness()
    if brightness > brightness_threshold:
        brightness_detected = True
    distance = measure_distance()
    if distance > previous_distance + motion_threshold or distance < previous_distance - motion_threshold:
        motion_detected = True
    if brightness_detected or motion_detected:
        presence_detected = True
    previous_distance = distance
    return presence_detected, distance, brightness

def show_something(pin):
    write20.text("Hello", 15, 0)
    write20.text("World!", 15, 20)
    oled.show()

def measure_brightness():
    reading = pin_sfh300_adc.read_u16()
    return(reading)

def measure_distance():
    pin_hcsr04_trigger.low()
    utime.sleep_us(2)
    pin_hcsr04_trigger.high()
    utime.sleep_us(5)
    pin_hcsr04_trigger.low()
    while pin_hcsr04_echo.value() == 0:
        signaloff = utime.ticks_us()
    while pin_hcsr04_echo.value() == 1:
        signalon = utime.ticks_us()
    timepassed = signalon - signaloff
    distance = timepassed * 0.01715 # (0.0343 cm per us) / 2 = 0.01715
    #print("The distance from object is ", distance, "cm")
    return(distance)

def motor_cleanup():
    for pin in range(0, len(motor_pins)):
        motor_pins[pin].low()

def motor_spin():
    i = 0
    motor_step_counter = 0
    motor_cleanup()
    for i in range(step_count):
        for pin in range(0, len(motor_pins)):
            motor_pins[pin].value(step_sequence[motor_step_counter][pin])
        if motor_direction==True:
            motor_step_counter = (motor_step_counter - 1) % 4
        elif motor_direction==False:
            motor_step_counter = (motor_step_counter + 1) % 4
        else: # defensive programming
            print( "uh oh... direction should *always* be either True or False" )
            motor_cleanup()
            exit( 1 )
        if button_pushed:
            motor_cleanup()
            print(i)
            break
        utime.sleep( step_sleep_open )


def main():
    # initialise
    motor_cleanup()
    presence_detected   = False
    perform_action      = False
    while True:
        # AUTO mode
        if not mode_debug and not mode_manual:
            presence_detected = detect_presence()
            while presence_detected:
                presence_detected = False
                # DISPLAY SOMETHING NICE
                utime.sleep(polling_interval_presence)
                presence_detected = detect_presence()
                time_since_presence = 0
                while not presence_detected:
                    if time_since_presence >= action_after_seconds:
                        perform_action = True
                        # Dewit
                        break
                    utime.sleep(polling_interval_presence)
                    time_since_presence += polling_interval_presence
                    presence_detected = detect_presence()
            utime.sleep(polling_interval_standby)

########################
#   Setup interrupts   #
########################
interrupt_clk = Pin(pin_ky040_button, Pin.IN, Pin.PULL_DOWN)
interrupt_clk.irq(trigger=Pin.IRQ_RISING, handler=button_interrupt)
#print("hello world")

while True:
    presence, distance, brightness = detect_presence()
    print("The distance from object is ", distance, "cm")
    print("The brightness is ", brightness)
    print("Presence detected: ", presence)
    #motor_spin()
    #motor_cleanup()
    utime.sleep(1)

