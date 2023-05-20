# General libraries
from machine import Pin, I2C, ADC
import utime
import math
import _thread
import micropython
import gc
gc.enable()
# SSD1300 OLED display, install the following packages from PyPI:
# micropython-ssd1306 by Stefan Lehmann
# micropython-oled by Yeison Cardona 
from ssd1306 import SSD1306_I2C, framebuf
from oled import Write
from oled.fonts import ubuntu_mono_15, ubuntu_mono_20, ubuntu_condensed_12
# handle interrupts
micropython.alloc_emergency_exception_buf(100)

####################################
# Variables that need callibration #
####################################
action_after_seconds        = 60       # seconds to wait after presence is no longer detected to close the lid or revert to AUTO mode
brightness_threshold        = 99        # phototransistor brightness (%) threshold for detecting restroom light
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
pin_ky040_clk       = Pin(12, Pin.IN, Pin.PULL_DOWN)
pin_ky040_dt        = Pin(11, Pin.IN, Pin.PULL_DOWN)
pin_ky040_sw        = Pin(10, Pin.IN, Pin.PULL_DOWN)
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
action_in_progress  = False # true if the motor is being actuated
button_pushed       = False # used to stop the motor if action is in progress
mode_debug          = False # true if DEBUG mode is engaged
mode_manual         = False # true if MAUNAL mode is engaged
mode_switch         = False # used in the main function to break out of loops


######################
#   Setup the OLED   #
######################
oled_width = 128
oled_height = 64
# the first argument of I2C is the set of i2c pins which should be initialised
i2c=I2C(0, scl=pin_oled_scl, sda=pin_oled_sda, freq=400000)
oled = SSD1306_I2C(oled_width, oled_height, i2c)
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
## test battery status icons
#while True:
#    for i in range(1, 6):
#        oled.fill(0)
#        battery.text(str(i), 108, 0)
#        oled.show()
#        utime.sleep(0.5)

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

## test static icons
#oled.fill(0)
#oled.contrast(0)    # dim
#lightbulb.char('lightbulb', 50, 0)
##ruler.char('ruler', 0, 0)
#arrows.char('arrows-alt-h', 100, 0)
#oled.show()

# Toilet icon
toilet_icon_array = bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xe0\x00\x00\x00\x00\x00\x00\xa0\x00\x00\x00\x00\x00\x07\xfc\x00\x00\x00\x00\x00\x0c\x06\x00\x00\x00\x00\x00\x18\x02\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\x00\x00\x00\x00\x00\x10\x01\xff\xff\xf8\x00\x00\x10\x01\x80\x00\x04\x00\x00\x1f\xff\xff\xff\xfc\x00\x00\x10\x00\x00\x00\x04\x00\x00\x10\x00\x00\x00\x04\x00\x00\x10\x00\x00\x00\x04\x00\x00\x08\x00\x00\x00\x08\x00\x00\x08\x00\x00\x00\x10\x00\x00\x04\x00\x00\x00`\x00\x00\x06\x00\x00\x01\x80\x00\x00\x02\x00\x00\x03\x00\x00\x00\x01\x00\x00\x04\x00\x00\x00\x00\x80\x00\x08\x00\x00\x00\x00@\x00\x18\x00\x00\x00\x00@\x00\x10\x00\x00\x00\x00 \x00\x10\x00\x00\x00\x00 \x00 \x00\x00\x00\x00 \x00 \x00\x00\x00\x00 \x00 \x00\x00\x00\x00`\x00 \x00\x00\x00\x00@\x00 \x00\x00\x00\x00@\x00\x10\x00\x00\x00\x00\xc0\x00\x10\x00\x00\x00\x00\x80\x00\x08\x00\x00\x00\x00\x80\x00\x08\x00\x00\x00\x00\xff\xff\xf0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00')
toilet_icon = framebuf.FrameBuffer(toilet_icon_array, 55, 55, framebuf.MONO_HLSB)

## test toilet icon
#oled.blit(toilet_icon, 82, 12)
#oled.show()

###########################
# Setup the stepper motor #
###########################
motor_direction=True # True for clockwise (closing seat), False for counter-clockwise (retracting arm) (as seen when looking from the back of the motor)
motor_retract_revolutions = 0 # If the action is interrupted, reverse the motor by this amount of revolutions
step_sequence = [[1,0,0,0],
                 [0,1,0,0],
                 [0,0,1,0],
                 [0,0,0,1]]
motor_pins = [pin_motor_1, pin_motor_2, pin_motor_3, pin_motor_4]

############################
# Setup the rotary encoder #
############################
last_button_time    = 0 # last time the button was pushed
rotary_counter      = 0 # position of the knob, 20 steps per 360 degrees
#last_clk_time       = 0 # last time the clk interrupt occured
#last_dt_time        = 0 # last time the dt interrupt occured
last_rotation_time  = 0 # last time either dt or clk interrupt occured
deadzone            = math.radians(40)  # rotation deadzone, 18 degrees per step, so 40 degrees is about two steps in either direction
max_rotation_steps  = 10    # limit how many steps in either direction can be made, 10 steps is half a rotation

#################
#   Functions   #
#################

def button_interrupt(pin):
    irq_state = machine.disable_irq()
    global button_pushed, last_button_time, mode_debug, mode_manual, mode_switch
    # <debounce>
    new_button_time = utime.ticks_ms()
    if utime.ticks_diff(new_button_time, last_button_time) < 200:
        machine.enable_irq(irq_state)
        return
    else:
        last_button_time = new_button_time
    # </debounce>
    button_pushed = True
    print("BUTTON PUSHED from button_interrupt")
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
        machine.enable_irq(irq_state)
        exit(1)
    machine.enable_irq(irq_state)

def clk_interrupt(pin):
    irq_state = machine.disable_irq()
    global button_pushed, last_rotation_time, rotary_counter
    # only do something in DEBUG mode
    if not mode_debug:
        machine.enable_irq(irq_state)
        return
    # debounce
    new_rotation_time = utime.ticks_ms()
    if utime.ticks_diff(new_rotation_time, last_rotation_time) < 20:
        machine.enable_irq(irq_state)
        return
    else:
        last_rotation_time = new_rotation_time
    # immediately stop motor if retraction is in progress during debug mode
    if action_in_progress:
        #print("ROTARY COUNTER: ", rotary_counter)
        button_pushed = True
    # don't register more than half a rotation
    if rotary_counter >= max_rotation_steps:
        rotary_counter = max_rotation_steps
        machine.enable_irq(irq_state)
        return
    # Increment counter
    clk_state   = pin_ky040_clk.value()
    dt_state    = pin_ky040_dt.value()
    if clk_state == 0 and dt_state == 1:
        rotary_counter += 1
    machine.enable_irq(irq_state)

def dt_interrupt(pin):
    irq_state = machine.disable_irq()
    global button_pushed, last_rotation_time, rotary_counter
    # only do something in DEBUG mode
    if not mode_debug:
        machine.enable_irq(irq_state)
        return
    # <debounce>
    new_rotation_time = utime.ticks_ms()
    if utime.ticks_diff(new_rotation_time, last_rotation_time) < 20:
        machine.enable_irq(irq_state)
        return
    else:
        last_rotation_time = new_rotation_time
    # immediately stop motor if retraction is in progress during debug mode
    if action_in_progress:
        #print("ROTARY COUNTER: ", rotary_counter)
        button_pushed = True
    # don't register more than half a rotation
    if rotary_counter <= -max_rotation_steps:
        rotary_counter = -max_rotation_steps
        machine.enable_irq(irq_state)
        return
    # Increment counter
    clk_state   = pin_ky040_clk.value()
    dt_state    = pin_ky040_dt.value()
    if clk_state == 1 and dt_state == 0:
        rotary_counter -= 1
    machine.enable_irq(irq_state)
        
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
    #print("Presence detected: ", presence_detected)
    #print("The distance from object is ", distance, "cm")
    #print("The brightness is ", brightness)
    return presence_detected

def draw_rotary_encoder(rotary_counter):
    global button_pushed, motor_retract_revolutions
    #micropython.mem_info()
    circle_radius = 20
    centre_x = 100
    centre_y = 39
    oled.fill_rect(80, 13, 128, 64, 0)
    angle = rotary_counter * 2 * math.pi / 20
    # draw the circle
    oled.ellipse(centre_x, centre_y, circle_radius, circle_radius, 1)
    # draw the deadzone
    inner_radius = 15
    for a in deadzone, -deadzone:
        outer_x = round(centre_x + circle_radius * math.sin(a))
        outer_y = round(centre_y - circle_radius * math.cos(a))
        inner_x = round(centre_x + inner_radius * math.sin(a))
        inner_y = round(centre_y - inner_radius * math.cos(a))
        oled.line(inner_x, inner_y, outer_x, outer_y, 1)
    # draw the dial
    dial_x = round(centre_x + circle_radius * math.sin(angle))
    dial_y = round(centre_y - circle_radius * math.cos(angle))
    oled.line(centre_x, centre_y, dial_x, dial_y, 1)
    # if outside the deadzone, draw a "progress bar" following the dial, and some text
    if angle > deadzone:
        deadzone_deg = round(math.degrees(deadzone))
        angle_deg = round(math.degrees(angle))
        for deg in range(deadzone_deg, angle_deg+1):
            a = math.radians(deg)
            outer_x = round(centre_x + circle_radius * math.sin(a))
            outer_y = round(centre_y - circle_radius * math.cos(a))
            inner_x = round(centre_x + inner_radius * math.sin(a))
            inner_y = round(centre_y - inner_radius * math.cos(a))
            oled.line(inner_x, inner_y, outer_x, outer_y, 1)
        oled.fill_rect(0, 48, 75, 64, 0)
        oled.fill_rect(10, 48, 60, 16, 1)
        write12.text("Extending", 20, 49, bgcolor=1, color=0)
    elif angle < -deadzone:
        deadzone_deg = round(math.degrees(deadzone))
        angle_deg = round(math.degrees(angle))
        for deg in range(-deadzone_deg, angle_deg-1, -1):
            a = math.radians(deg)
            outer_x = round(centre_x + circle_radius * math.sin(a))
            outer_y = round(centre_y - circle_radius * math.cos(a))
            inner_x = round(centre_x + inner_radius * math.sin(a))
            inner_y = round(centre_y - inner_radius * math.cos(a))
            oled.line(inner_x, inner_y, outer_x, outer_y, 1)
        oled.fill_rect(0, 48, 75, 64, 0)
        oled.fill_rect(10, 48, 60, 16, 1)
        write12.text("Retracting", 18, 49, bgcolor=1, color=0)
    else:
        if action_in_progress:
            oled.fill_rect(0, 48, 75, 64, 0)
            oled.fill_rect(10, 48, 60, 16, 1)
            write12.text("Retracting", 18, 49, bgcolor=1, color=0)
        else:
            oled.fill_rect(0, 48, 75, 64, 0)
            oled.rect(10, 48, 60, 16, 1)
            write12.text("Motor off", 20, 49, 1)
        # stop the motor if dial is moved into deadzone during DEBUG mode automatic retraction (which happens after switching from MANUAL to DEBUG)
        #if mode_debug and not mode_manual and action_in_progress:
        #    button_pushed = True
        #    motor_retract_revolutions = 0
            
    #micropython.mem_info()
    #oled.show()


#mode_debug = True
#def test_draw_rotary_encoder():
#    while True:
#        #draw_status_bar()
#        #draw_rotary_encoder(rotary_counter)
#        #clear_screen()
#        utime.sleep(1)
    

def draw_status_bar(): # display stuff at the top of the oled screen
    #global mode_debug, mode_manual
    oled.fill_rect(0, 0, 128, 15, 0)
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

def draw_toilet(frame=1):
    oled.fill_rect(80, 13, 128, 64, 0)
    oled.blit(toilet_icon, 80, 12)
    if frame == 1:
        oled.rect(105, 15, 3, 22, 1)
    elif frame == 2:
        oled.line(105, 35, 120, 20, 1)
        oled.line(107, 36, 122, 21, 1)
        oled.pixel(106, 35, 1)
        oled.pixel(121, 20, 1)
    elif frame == 3:
        oled.rect(105, 34, 22, 3, 1)
## test toilet animation
#oled.contrast(0)
#while True:
#    for i in 1,2,3:
#        draw_toilet(i)
#        oled.show()
#        utime.sleep(1)

def get_battery_icon(battery_percentage):
    # based on table at https://blog.ampow.com/lipo-voltage-chart/
    if battery_percentage >= 90:
        select_battery_icon = str(5)
    elif battery_percentage >= 70:
        select_battery_icon = str(4)
    elif battery_percentage >= 50:
        select_battery_icon = str(3)
    elif battery_percentage >= 30:
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

def motor_spin(revolutions=1, step_sleep=step_sleep_retract):
    print("MOTOR SPINNING from motor_spin thread")
    global action_in_progress, button_pushed, motor_direction, motor_retract_revolutions
    button_pushed = False
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
            irq_state = machine.disable_irq()
            motor_cleanup()
            #print("Motor interrupted from motor_spin thread")
            if motor_direction == True:
                motor_retract_revolutions = i/steps_per_revolution
            elif motor_direction == False:
                motor_retract_revolutions -= i/steps_per_revolution
            button_pushed = False
            action_in_progress = False
            motor_cleanup()
            machine.enable_irq(irq_state)
            _thread.exit()
            break
        utime.sleep(step_sleep)
    action_in_progress = False
    motor_cleanup()
    _thread.exit()

def main():
    global action_in_progress, mode_debug, mode_manual, mode_switch, motor_direction, motor_retract_revolutions, rotary_counter
    while True:

        # AUTO mode
        if not mode_debug and not mode_manual:
            # initialise
            motor_retract_revolutions = 0
            motor_cleanup()
            clear_screen()
            presence_detected = detect_presence()
            while presence_detected:
                if mode_switch:
                    clear_screen()
                    mode_switch = False
                    break
                show_something() # DISPLAY SOMETHING NICE
                draw_status_bar()
                oled.show()
                utime.sleep(polling_interval_presence)
                presence_detected = detect_presence()
                time_since_presence = 0
                while not presence_detected:
                    if mode_switch:
                        break
                    if time_since_presence >= action_after_seconds:
                        #perform_action = True
                        # Dewit
                        print("CLOSING THE SEAT from AUTO mode")
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
                draw_status_bar()
                write15.text("MANUAL mode", 0, 25)
                oled.show()
                # Dewit
                print("CLOSING THE SEAT from MANUAL mode")
                action_in_progress = True
                motor_direction = True
                thread_id = _thread.start_new_thread(motor_spin, ())
                while action_in_progress:
                    for i in 1,2,3:
                        draw_toilet(i)
                        oled.show()
                        if mode_switch: break
                        utime.sleep(1)
                #print("Switching back to AUTO mode")
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
            # initialise
            gc.collect()
            motor_cleanup()
            rotary_counter = 0
            oled.fill(0)
            write15.text("DEBUG mode", 0, 25)
            while True:
                gc.collect()
                # switch modes if button has been pushed
                if mode_switch:
                    clear_screen()
                    mode_switch = False
                    break
                # revert motor if ongoing action has been cancelled
                if motor_retract_revolutions > 0 and not action_in_progress:
                    rotary_counter = 0
                    motor_direction = False
                    action_in_progress = True
                    thread_id = _thread.start_new_thread(motor_spin, (motor_retract_revolutions,))
                    motor_retract_revolutions = 0
                draw_status_bar()
                #micropython.schedule(draw_rotary_encoder, rotary_counter)
                draw_rotary_encoder(rotary_counter)
                oled.show()
                utime.sleep(polling_interval_presence/3)
                presence_detected = detect_presence()
                time_since_presence = 0
                while not presence_detected:
                    draw_status_bar()
                    #micropython.schedule(draw_rotary_encoder, rotary_counter)
                    draw_rotary_encoder(rotary_counter)
                    oled.show()
                    if mode_switch:
                        break
                    if time_since_presence >= action_after_seconds:
                        print("Switching back to AUTO mode from DEBUG mode")
                        mode_debug = False
                        mode_switch = True
                        break
                    utime.sleep(polling_interval_presence/3)
                    time_since_presence += polling_interval_presence/3
                    presence_detected = detect_presence()

def show_something():
    write20.text("Hello", 15, 15)
    write20.text("World!", 15, 35)
    oled.show()

########################
#   Setup interrupts   #
########################
pin_ky040_clk.irq(trigger=Pin.IRQ_FALLING, handler=clk_interrupt)
pin_ky040_dt.irq(trigger=Pin.IRQ_FALLING, handler=dt_interrupt)
pin_ky040_sw.irq(trigger=Pin.IRQ_RISING, handler=button_interrupt)


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

#test()
main()
#show_something()
