# General libraries
from machine import Pin, I2C, ADC
import utime
# SSD1300 OLED display
from ssd1306 import SSD1306_I2C, framebuf
from oled import Write, GFX
from oled.fonts import ubuntu_mono_15, ubuntu_mono_20, ubuntu_condensed_12
# handle interrupts
from micropython import alloc_emergency_exception_buf, schedule
alloc_emergency_exception_buf(100)

####################################
# Variables that need callibration #
####################################
action_after_seconds        = 60       # seconds to wait after presence is no longer detected to close the lid or revert to AUTO mode
brightness_threshold        = 50        # phototransistor brightness (%) threshold for detecting restroom light
motion_threshold            = 5         # difference in distance (cm) between successive measurements to detect motion 
polling_interval_presence   = 1         # seconds between polling when presence has been detected
polling_interval_standby    = 5         # seconds between polling during standby
previous_distance           = 165       # initialise typical distance (cm) measured when nobody is in the restroom
steps_per_revolution        = 2048      # stepper motor steps per revolution
step_sleep_close            = 0.003     # seconds between stepper motor steps during lid close action
step_sleep_retract          = 0.002     # seconds between stepper motor steps during retract action

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

##########################################
# Glabal variables for the state machine #
##########################################
# Pushing the button cycles between three modes:
# AUTO:     poll sensors and close lid after presence is no longer detected
# MANUAL:   immediately close the lid, ignoring presence detection
# DEBUG:    manually adjust position, and display sensor output. Useful for callibration
mode_debug  = False
mode_manual = False

######################
#   Setup the OLED   #
######################
oled_width = 128
oled_height = 64
# the first argument of I2C is the set of i2c pins which should be initialised
i2c=I2C(0, scl=pin_oled_scl, sda=pin_oled_sda, freq=400000)
oled = SSD1306_I2C(oled_width, oled_height, i2c)
gfx = GFX(oled_width, oled_height, oled.pixel)
# fonts
write12 = Write(oled, ubuntu_condensed_12)
write15 = Write(oled, ubuntu_mono_15)
write20 = Write(oled, ubuntu_mono_20)
# Battery icons
class battery_status:
    _FONT = {
        49: [20, 1099511627775, 1099511627775, 1099511627775, 824633720832, 824633720832, 17179869168, 17179869168, 68719476720, 68719476720, 17179869168, 17179869168, 824633720832, 824633720832, 1099511627775],
        50: [20, 1099511627775, 1099511627775, 1099511627775, 824633720832, 824633720832, 17179869168, 17179852848, 68719460400, 68719460400, 17179852848, 17179869168, 824633720832, 824633720832, 1099511627775],
        51: [20, 1099511627775, 1099511627775, 1099511627775, 824633720832, 824633720832, 17179869168, 17178820656, 68718428208, 68718428208, 17178820656, 17179869168, 824633720832, 824633720832, 1099511627775],
        52: [20, 1099511627775, 1099511627775, 1099511627775, 824633720832, 824633720832, 17179869168, 17112760368, 68652367920, 68652367920, 17112760368, 17179869168, 824633720832, 824633720832, 1099511627775],
        53: [20, 1099511627775, 1099511627775, 1099511627775, 824633720832, 824633720832, 17179869168, 12884901936, 64424509488, 64424509488, 12884901936, 17179869168, 824633720832, 824633720832, 1099511627775],
        }
battery = Write(oled, battery_status)

# Lightbulb icon
class lightbulb_icon:
    _FONT = {
        'lightbulb': [11, 4128831, 3932175, 3146691, 3145779, 3145776, 3145731, 3145731, 3932163, 4128783, 4128831, 4194303, 4177983, 4177983, 4190463, 4194303],
        }
lightbulb = Write(oled, lightbulb_icon)

## Ruler icon
#class ruler_icon:
#    _FONT = {
#        'ruler': [16, 4291035135, 4278255615, 4228120575, 4026732543, 4026545151, 4227859455, 4278193983, 4290773055, 4293918915, 4294705152, 4294901760, 4294950915, 4294963215, 4294966335, 4294967295],
#        }
#ruler = Write(oled, ruler_icon)

# Horizontal arrows icon (might look better than the ruler icon)
class horizontal_arrows_icon:
    _FONT = {
        'arrows-alt-h': [14, 268435455, 268435455, 268435455, 268435455, 265289535, 252706575, 201326595, 0, 201326592, 252706575, 265289535, 268435455, 268435455, 268435455, 268435455],
        }
arrows = Write(oled, horizontal_arrows_icon)

# Toilet icon
toilet_icon_array = bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xe0\x00\x00\x00\x00\x00\x00\xa0\x00\x00\x00\x00\x00\x07\xfc\x00\x00\x00\x00\x00\x0c\x06\x00\x00\x00\x00\x00\x18\x02\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\xff\xff\xf8\x00\x00\x10\x01\x80\x00\x04\x00\x00\x1f\xff\xff\xff\xfc\x00\x00\x10\x00\x00\x00\x04\x00\x00\x10\x00\x00\x00\x04\x00\x00\x10\x00\x00\x00\x04\x00\x00\x08\x00\x00\x00\x08\x00\x00\x08\x00\x00\x00\x10\x00\x00\x04\x00\x00\x00`\x00\x00\x06\x00\x00\x01\x80\x00\x00\x02\x00\x00\x03\x00\x00\x00\x01\x00\x00\x04\x00\x00\x00\x00\x80\x00\x08\x00\x00\x00\x00@\x00\x18\x00\x00\x00\x00@\x00\x10\x00\x00\x00\x00 \x00\x10\x00\x00\x00\x00 \x00 \x00\x00\x00\x00 \x00 \x00\x00\x00\x00 \x00 \x00\x00\x00\x00`\x00 \x00\x00\x00\x00@\x00 \x00\x00\x00\x00@\x00\x10\x00\x00\x00\x00\xc0\x00\x10\x00\x00\x00\x00\x80\x00\x08\x00\x00\x00\x00\x80\x00\x08\x00\x00\x00\x00\xff\xff\xf0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00')
toilet_icon = framebuf.FrameBuffer(toilet_icon_array, 55, 55, framebuf.MONO_HLSB)

## test static icons
#oled.fill(0)
#oled.contrast(0)    # dim
#lightbulb.char('lightbulb', 50, 0)
##ruler.char('ruler', 0, 0)
#arrows.char('arrows-alt-h', 100, 0)
#oled.show()

## test toilet icon
#oled.blit(toilet_icon, 82, 12)
#oled.show()

###########################
# Setup the stepper motor #
###########################
motor_retract_revolutions = 0 # If the action is interrupted, reverse the motor by this amount of revolutions
step_sequence = [[1,0,0,0],
                 [0,1,0,0],
                 [0,0,1,0],
                 [0,0,0,1]]
motor_pins = [pin_motor_1, pin_motor_2, pin_motor_3, pin_motor_4]


#################
#   Functions   #
#################

button_pushed   = False # used to stop the motor if action is in progress
mode_switch     = False # used in the main function to break out of loops
last_button_time = 0    # last time the button was pushed
def button_interrupt(pin):
    global button_pushed, last_button_time, mode_debug, mode_manual, mode_switch
    new_button_time = utime.ticks_ms()
    if (new_button_time - last_button_time) < 200:
        return
    else:
        last_button_time = new_button_time
    button_pushed = True
    print("BUTTON PUSHED WOOOOOOO")
    # switch from AUTO to MANUAL
    if not mode_debug and not mode_manual:
        mode_manual = True
        mode_switch = True
    # switch from MANUAL to DEBUG
    elif not mode_debug and mode_manual:
        mode_debug = True
        mode_manual = False
        mode_switch = True
    # switch from DEBUG to AUTO
    elif mode_debug and not mode_manual:
        mode_debug = False
        mode_switch = True
    # Defensive programming
    else:
        motor_cleanup()
        write15.text("State machine error", 0, 0)
        oled.show()
        print("State machine error")
        exit(1)
        
def clear_screen():
    oled.fill(0)
    oled.show()

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
    print("Presence detected: ", presence_detected)
    print("The distance from object is ", distance, "cm")
    print("The brightness is ", brightness)
    return presence_detected

def draw_status_bar(): # display stuff at the top of the oled screen
    #global mode_debug, mode_manual
    gfx.fill_rect(0, 0, 128, 15, 0)
    battery_percentage = measure_battery()
    select_battery_icon = get_battery_icon(battery_percentage)
    battery.text(select_battery_icon, 108, -1)
    # DEBUG mode shows sensor output
    if mode_debug and not mode_manual:
        brightness = round(measure_brightness())
        write12.text(str(brightness) + "%", 15, 0)
        lightbulb.char('lightbulb', 0, 0)
        distance = round(measure_distance())
        write12.text(str(distance) + "cm", 63, 0)
        arrows.char('arrows-alt-h', 45, 0)
    oled.show()

def draw_toilet(frame=1):
    gfx.fill_rect(80, 13, 128, 64, 0)
    oled.blit(toilet_icon, 80, 12)
    if frame == 1:
        gfx.rect(105, 15, 3, 22, 1)
    elif frame == 2:
        gfx.line(105, 34+1, 120, 19+1, 1)
        gfx.line(107, 36, 122, 21, 1)
        oled.pixel(106, 35, 1)
        oled.pixel(121, 20, 1)
    elif frame == 3:
        gfx.rect(105, 34, 22, 3, 1)
    oled.show()

def get_battery_icon(battery_percentage):
    # based on table at https://blog.ampow.com/lipo-voltage-chart/
    if battery_percentage >= 95:
        select_battery_icon = str(5)
    elif battery_percentage >= 75:
        select_battery_icon = str(4)
    elif battery_percentage >= 55:
        select_battery_icon = str(3)
    elif battery_percentage >= 35:
        select_battery_icon = str(2)
    else:
        select_battery_icon = str(1)
    return select_battery_icon

def measure_battery():
    battery_percentage=100
    return battery_percentage

def measure_brightness():
    brightness = pin_sfh300_adc.read_u16() * 0.00152590218 # 100%/65535 = 0.00152590218
    return(brightness)

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
    distance = timepassed * 0.01715 # (0.0343 cm per us)/2 = 0.01715
    #print("The distance from object is ", distance, "cm")
    return(distance)

def motor_cleanup():
    for pin in range(0, len(motor_pins)):
        motor_pins[pin].low()

def motor_spin(revolutions=1, motor_direction=False, step_sleep=step_sleep_retract):
    global button_pushed, motor_retract_revolutions
    motor_retract_revolutions = 0
    i = 0
    motor_step_counter = 0
    motor_cleanup()
    for i in range(revolutions*steps_per_revolution):
        for pin in range(0, len(motor_pins)):
            motor_pins[pin].value(step_sequence[motor_step_counter][pin])
        if motor_direction==True:
            motor_step_counter = (motor_step_counter - 1) % 4
        elif motor_direction==False:
            motor_step_counter = (motor_step_counter + 1) % 4
        else: # defensive programming
            print( "uh oh... direction should *always* be either True or False" )
            motor_cleanup()
            exit(1)
        if button_pushed:
            motor_cleanup()
            motor_retract_revolutions = i/steps_per_revolution
            button_pushed = False
            break
        utime.sleep(step_sleep)


def main():
    global mode_debug, mode_manual, mode_switch
    while True:
        # initialise
        motor_cleanup()
        clear_screen()
        presence_detected = False

        # AUTO mode
        if not mode_debug and not mode_manual:
            presence_detected = detect_presence()
            while presence_detected:
                if mode_switch:
                    clear_screen()
                    mode_switch = False
                    break
                show_something() # DISPLAY SOMETHING NICE
                draw_status_bar()
                utime.sleep(polling_interval_presence)
                presence_detected = detect_presence()
                time_since_presence = 0
                while not presence_detected:
                    if mode_switch:
                        break
                    if time_since_presence >= action_after_seconds:
                        #perform_action = True
                        # Dewit
                        print("CLOSING THE SEAT WOOOO")
                        oled.poweroff()
                        break
                    utime.sleep(polling_interval_presence)
                    time_since_presence += polling_interval_presence
                    presence_detected = detect_presence()
            if not mode_switch:
                utime.sleep(polling_interval_standby)

        # MANUAL mode
        if not mode_debug and mode_manual:
            while True:
                if mode_switch:
                    clear_screen()
                    mode_switch = False
                    break
                # initialise
                motor_cleanup()
                oled.fill(0)
                write15.text("MANUAL mode", 0, 25)
                oled.show()
                # Dewit
                draw_status_bar()
                print("CLOSING THE SEAT WOOOO")
                utime.sleep(5)
                print("Switching back to AUTO mode")
                mode_manual = False
                break
                #presence_detected = detect_presence()
                #time_since_presence = 0
                #while not presence_detected:
                #    if mode_switch:
                #        break
                #    if time_since_presence >= action_after_seconds:
                #        print("Switching back to AUTO mode")
                #        clear_screen()
                #        mode_manual = False
                #        mode_switch = True
                #        break
                #    utime.sleep(polling_interval_presence)
                #    time_since_presence += polling_interval_presence
                #    presence_detected = detect_presence()

        # DEBUG mode
        if mode_debug and not mode_manual:
            while True:
                if mode_switch:
                    clear_screen()
                    mode_switch = False
                    break
                # initialise
                motor_cleanup()
                #clear_screen()
                write15.text("DEBUG mode", 0, 25)
                draw_status_bar()
                presence_detected = detect_presence()
                time_since_presence = 0
                while not presence_detected:
                    if mode_switch:
                        break
                    if time_since_presence >= action_after_seconds:
                        print("Switching back to AUTO mode")
                        mode_debug = False
                        mode_switch = True
                        break
                    draw_status_bar()
                    utime.sleep(polling_interval_presence)
                    time_since_presence += polling_interval_presence
                    presence_detected = detect_presence()
                utime.sleep(polling_interval_presence)

def show_something():
    write20.text("Hello", 15, 15)
    write20.text("World!", 15, 35)
    oled.show()

########################
#   Setup interrupts   #
########################
interrupt_clk = Pin(pin_ky040_button, Pin.IN, Pin.PULL_DOWN)
interrupt_clk.irq(trigger=Pin.IRQ_RISING, handler=button_interrupt)

###############
#   Execute   #
###############
#while True:
#    presence = detect_presence()
#    #print("The distance from object is ", distance, "cm")
#    #print("The brightness is ", brightness)
#    print("Presence detected: ", presence)
#    #motor_spin()
#    #motor_cleanup()
#    utime.sleep(1)

main()
#show_something()


# test battery status icons
#while True:
#    for i in range(1, 6):
#        oled.fill(0)
#        battery.text(str(i), 108, 0)
#        oled.show()
#        utime.sleep(0.5)

# test toilet animation
while True:
    for i in 1,2,3:
        draw_toilet(i)
        utime.sleep(1)