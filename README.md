# Custom Drawing Language with bison and flex
## How to use:
Type *bison -d gvlogo.y* first, then type *flex gvlogo.l* and then *gcc \*.c -lSDL2 -lm* to compile it. Now you can run the program by typing *./a.out*.
### Commands you can use to draw:
In the terminal, you can type the following commands:<br>
● penup - Raise the pen so the turtle can move without drawing.<br>
● pendown - Lower the pen so movement creates a line.<br>
● print - Print (to the console) a quoted string. For instance, print "Hello world!".<br>
● save - Save the current picture to a bitmap file. Needs a pathname; i.e., save picture.bmp.<br>
● color - Change the current draw color. Requires a red, green, and blue value (0-255). For
instance, color 255 255 0 would set the current color to yellow.<br>
● clear - Clears the screen to the current draw color. Paints over anything currently
drawn.<br>
● turn - Requires an angle. Reorients the turtle by a number of degrees (clockwise
positive). Is cumulative; turning 45 and turning 55 would end up turning the turtle 100
degrees.<br>
● move - Takes a number of pixels, and moves the turtle in the current direction that
many pixels. For instance, move 25. If the pen is up, no drawing occurs.<br>
● goto - Moves the turtle to a particular coordinate. Draws if the pen is down, otherwise
does not.<br>
● where - Prints the current coordinates.

You can also do basic calculations by typing: 34+8; or 34+4\*2; <br>
Note: You have to type the semi-colon to end the equation for this program.
