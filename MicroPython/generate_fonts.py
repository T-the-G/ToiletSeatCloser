from oled.fonts import gen

# Generate fonts in the regular python interpreter (not micropython), because the pygame package is required.
# Guide here: https://espresso-ide.readthedocs.io/projects/micropython-oled/en/latest/content/getting_started.html
# I had to comment out "from machine import..." in lazy.py

# lightbulb icons
# Sadly "lightbulb-on" is a premium icon
characters = {'lightbulb': '\uf0eb'}
font = gen.generate_oled_font("Font Awesome 6 Free, Regular", 15, characters)
#print(font)

# battery status icons
characters = {'1': '\uf244',
              '2': '\uf243',
              '3': '\uf242',
              '4': "\uf241",
              '5': "\uf240",
             }
font = gen.generate_oled_font("Font Awesome 6 Free, Solid", 17, characters)
#print(font)

# ruler icon
characters = {'ruler': '\uf545'}
font = gen.generate_oled_font("Font Awesome 6 Free, Regular", 15, characters)
#print(font)

# horizontal arrows icon (maybe looks better than ruler)
characters = {'arrows-alt-h': '\uf337'}
font = gen.generate_oled_font("Font Awesome 6 Free, Regular", 15, characters)
print(font)