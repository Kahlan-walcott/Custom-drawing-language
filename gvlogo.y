// Kahlan Walcott
%{
#define WIDTH 640
#define HEIGHT 480

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_thread.h>

static SDL_Window* window;
static SDL_Renderer* rend;
static SDL_Texture* texture;
static SDL_Thread* background_id;
static SDL_Event event;
static int running = 1;
static const int PEN_EVENT = SDL_USEREVENT + 1;
static const int DRAW_EVENT = SDL_USEREVENT + 2;
static const int COLOR_EVENT = SDL_USEREVENT + 3;

typedef struct color_t {
	unsigned char r;
	unsigned char g;
	unsigned char b;
} color;

static color current_color;
static double x = WIDTH / 2;
static double y = HEIGHT / 2;
static int pen_state = 1;
static double direction = 0.0;

double symbol_table[26];

int yylex(void);
int yyerror(const char* s);
void startup();
int run(void* data);
void prompt();
// Raise the pen so the turtle can move without drawing
void penup();
// Lower the pen so movement creates a line.
void pendown();
// Takes a number of pixels, and moves the turtle in the current direction that many pixels. For instance, move 25. If the pen is up, no drawing occurs.
void move(int num);
// Requires an angle. Reorients the turtle by a number of degrees (clockwise positive). Is cumulative; turn 45 and turn 55 would end up turning the turtle 100 degrees.
void turn(int dir);
// Print (to the console) a quoted string. For instance, print "Hello world!".
void output(const char* s);
// Change the current draw color. Requires a red, green, and blue value (0-255). For instance, color 255 255 0 would set the current color to yellow.
void change_color(int r, int g, int b);
// Clears the screen to the current draw color. Paints over anything currently drawn.
void clear();
// Save the current picture to a bitmap file. Needs a pathname; i.e. save picture.bmp.
void save(const char* path);
// Moves the turtle to a particular coordinate. Draws if the pen is down, otherwise does not.
void gotos(int xcord, int ycord);
// Prints the current coordinates.
void where();
void shutdown();

%}

%union {
	float f;
	char* str;
    char var;
}

%locations

%token SEP
%token PENUP
%token PENDOWN
%token PRINT
%token CHANGE_COLOR
%token COLOR
%token CLEAR
%token TURN
%token LOOP
%token MOVE
%token GOTO
%token WHERE

%token NUMBER
%token END
%token EQUALS
%token SAVE
%token PLUS SUB MULT DIV
%token <var> VARIABLE
%token<str> STRING QSTRING
%type<f> expression NUMBER

%%

program:		statement_list END				{ printf("Program complete."); shutdown(); exit(0); }
		;
statement_list:		statement					
		|	statement statement_list
		;
statement:		command SEP					{ prompt(); }
		|	error '\n' 					{ yyerrok; prompt(); }
		|	expression SEP					{ printf("%f\n", $1); yyerrok; prompt(); }
		;
command:		PENUP			{ penup(); }
        |       PENDOWN                     { pendown(); }
        |       PRINT QSTRING                { output($2); } // This helped me understand the syntax: https://stackoverflow.com/questions/39246662/how-to-return-function-name-with-bison#:~:text=Although%20OP%20has%20found%20the,variable%20and%20then%20return%20it.&text=the%20following%20rule-,function_l:%20function%20%7C%20function_l%20function%20%3B,from%20the%20rule%20%22function%22.
        |       SAVE STRING                 { save($2); }
        |       COLOR  { printf("Color is: %d, %d, %d.\n", current_color.r, current_color.g, current_color.b); }
	|	CHANGE_COLOR  NUMBER NUMBER NUMBER  { change_color($2, $3, $4); printf("Color changed.\n"); }
        |       CLEAR                       { clear(); printf("Your drawing has been erased.\n"); }
        |       TURN NUMBER                 { turn($2); printf("Turned %f degrees.\n", $2); }
        |       MOVE NUMBER             { move($2); printf("You moved %f pixles.\n", $2); }
        |       GOTO NUMBER NUMBER          { gotos($2, $3); }
        |       WHERE  	            { where(); }
	|	VARIABLE EQUALS expression       { symbol_table[$1] = $3; printf("Variable stored.\n"); }
	;
expression:		NUMBER PLUS expression				{ $$ = $1 + $3; }
        | VARIABLE                            { $$ = symbol_table[$1];}
		|	NUMBER MULT expression				{ $$ = $1 * $3; }
		|	NUMBER SUB expression				{ $$ = $1 - $3; }
		|	NUMBER DIV expression				{ $$ = $1 / $3; }
		|	NUMBER                              { $$ = $1; }
		;

%%

int main(int argc, char** argv){
	startup();
	return 0;
}

int yyerror(const char* s){
	printf("Error: %s\n", s);
	return -1;
};

void prompt(){
	printf("gv_logo > ");
}

void penup(){
	event.type = PEN_EVENT;		
	event.user.code = 0;
	SDL_PushEvent(&event);
}

void pendown() {
	event.type = PEN_EVENT;		
	event.user.code = 1;
	SDL_PushEvent(&event);
}

void move(int num){
	event.type = DRAW_EVENT;
	event.user.code = 1;
	event.user.data1 = num;
	SDL_PushEvent(&event);
}

void turn(int dir){
	event.type = PEN_EVENT;
	event.user.code = 2;
	event.user.data1 = dir;
	SDL_PushEvent(&event);
}

void output(const char* s){
	printf("%s\n", s);
}

void change_color(int r, int g, int b){
	event.type = COLOR_EVENT;
	current_color.r = r;
	current_color.g = g;
	current_color.b = b;
	SDL_PushEvent(&event);
}

void clear(){
	event.type = DRAW_EVENT;
	event.user.code = 2;
	SDL_PushEvent(&event);
}

void gotos(int xcord, int ycord){
    double dist_x = xcord - x;
    double dist_y = ycord - y;
    double pix_x = x + dist_x; //*cos(0);
    double pix_y = y + dist_y; //*sin(90);
    move(pix_x);
    turn(90);
    move(pix_y);
    // sets the cooridates to the new ones
    x = xcord;
    y = ycord;
}

void where(){
    printf("You are currently at the coordinate (%f, %f).\n", x, y);
}

void startup(){
    // initializes the SDL's subsystems
	SDL_Init(SDL_INIT_VIDEO);
    // creates a wndow
	window = SDL_CreateWindow("GV-Logo", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WIDTH, HEIGHT, SDL_WINDOW_SHOWN);
    // cheacks for an error
    if (window == NULL){
		yyerror("Can't create SDL window.\n");
	}
	
	//rend = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_TARGETTEXTURE);
    // creates a 2D rendering context for a window (render surface)
	rend = SDL_CreateRenderer(window, -1, SDL_RENDERER_SOFTWARE | SDL_RENDERER_TARGETTEXTURE);
    // set the blend mode used for drawing operations (fill and line)
	SDL_SetRenderDrawBlendMode(rend, SDL_BLENDMODE_BLEND);
    // create a texture for rendering context - returns a pointer to the created texture or NULL if no rendering context was active
	texture = SDL_CreateTexture(rend, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, WIDTH, HEIGHT);
	// error checking for the texture
    if(texture == NULL){
		printf("Texture NULL.\n");
		exit(1);
	}
    // set a texture as the current rendering target 
	SDL_SetRenderTarget(rend, texture);
    // set the drawing scale for rendering on the current target 
	SDL_RenderSetScale(rend, 3.0, 3.0);
    
    // create a new thread with a default stack size - returns an opaque pointer (something only the code knows) to the new thread object on success and NULL for not. 
	background_id = SDL_CreateThread(run, "Parser thread", (void*)NULL);
	// error cheacking for thread
    if(background_id == NULL){
		yyerror("Can't create thread.");
	}
    // when it is running
	while(running){
        // general event structure
		SDL_Event e;
        // poll for currently pending event-returns 1 if there is a pending event and 0 if there are none.
		while( SDL_PollEvent(&e) ){
            // when there is no pending event
			if(e.type == SDL_QUIT){
				running = 0;
			}
            // if the user wants to use the pen
			if(e.type == PEN_EVENT){
                // turn the pen 
				if(e.user.code == 2){
					double degrees = ((int)e.user.data1) * M_PI / 180.0;
					direction += degrees;
				}
				pen_state = e.user.code;
			}
            // if the user wants to draw
			if(e.type == DRAW_EVENT){
                // if the user wants to turn 
				if(e.user.code == 1){
					int num = (int)event.user.data1;
					double x2 = x + num * cos(direction);
					double y2 = y + num * sin(direction);
					if(pen_state != 0){
						SDL_SetRenderTarget(rend, texture);
                        // draw a line on the current rendering target (start coordinates and end coordinate)
						SDL_RenderDrawLine(rend, x, y, x2, y2);
						SDL_SetRenderTarget(rend, NULL);
						SDL_RenderCopy(rend, texture, NULL, NULL);
					}
					x = x2;
					y = y2;
				} else if(e.user.code == 2){
					SDL_SetRenderTarget(rend, texture);
					SDL_RenderClear(rend);
					SDL_SetTextureColorMod(texture, current_color.r, current_color.g, current_color.b);
					SDL_SetRenderTarget(rend, NULL);
					SDL_RenderClear(rend);
				}
			}
			if(e.type == COLOR_EVENT){
				SDL_SetRenderTarget(rend, NULL);
				SDL_SetRenderDrawColor(rend, current_color.r, current_color.g, current_color.b, 255);
			}
			if(e.type == SDL_KEYDOWN){
			}

		}
		//SDL_RenderClear(rend);
		SDL_RenderPresent(rend);
		SDL_Delay(1000 / 60);
	}
}

int run(void* data){
	prompt();
	yyparse();
}

void shutdown(){
	running = 0;
	SDL_WaitThread(background_id, NULL);
	SDL_DestroyWindow(window);
	SDL_Quit();
}

void save(const char* path){
	SDL_Surface *surface = SDL_CreateRGBSurface(0, WIDTH, HEIGHT, 32, 0, 0, 0, 0);
	SDL_RenderReadPixels(rend, NULL, SDL_PIXELFORMAT_ARGB8888, surface->pixels, surface->pitch);
	SDL_SaveBMP(surface, path);
	SDL_FreeSurface(surface);
}
