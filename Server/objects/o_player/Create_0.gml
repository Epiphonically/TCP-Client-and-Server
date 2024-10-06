mouse_x_pos = 0;
mouse_y_pos = 0;
x_axis = 0;
y_axis = 0;
pickup_range = 20;
spd = 1.5;
fighting_class = class.NONE;
state = STATES.DEFAULT;
buffered_state = STATES.DEFAULT;
face = 0;
buffered_face = 0;
constant_face = 0;
whos_socket = 0;
charge_score = 0;
can_buffer_attack = true;
craft_range = 100;
mouse_select_range = 20;
is_crafting = false;
hp = 100;
maxhp = 100;

typing = false;

held_slot = 0;
drawing = false;
curr_drawing = array_create(MAX_DRAWING, -1);
drawing_index = 0;
needs_downpress = true;
function coordinate_vector(_x, _y) constructor {
	xx = _x;
	yy = _y;
}
