enum STATES {
	DEFAULT,
	INTERMISSION,
	ATTACK,
	CHARGING,
	DASH,
	CRAFTING
}

#region Controls
w = keyboard_check(ord("W"));
a = keyboard_check(ord("A"));
s = keyboard_check(ord("S"));
d = keyboard_check(ord("D"));
e = keyboard_check_pressed(ord("E"));
q = keyboard_check_pressed(ord("Q"));
t = keyboard_check_pressed(ord("T"));
c = keyboard_check_pressed(ord("C"));
left_click = mouse_check_button_pressed(mb_left);
left_hold = mouse_check_button(mb_left);
left_let_go = mouse_check_button_released(mb_left);
right_click = mouse_check_button_pressed(mb_right);
left_hold = mouse_check_button(mb_left);
right_hold = mouse_check_button(mb_right);
escape = keyboard_check_pressed(vk_escape);
enter = keyboard_check_pressed(vk_enter);
space = keyboard_check_pressed(vk_space);
back_space = keyboard_check_pressed(vk_backspace);
back_space_hold = keyboard_check(vk_backspace);
back_space_up = keyboard_check_released(vk_backspace);

#endregion

function option_vector(_option, _next_options) constructor {
	option = _option;
	next = _next_options;
}

text_margin = 20;
inv_margin = 0;
extra_space = 0;
paused = false;
can_pause = true;
curr_choice = 0;
options_stack = ds_list_create();

#region Menu Option Tree
option_tree_menu = ds_list_create();
option_tree_menu[| 0] = new option_vector("Play", 0);
option_tree_menu[| 1] = new option_vector("Settings", ds_list_create());
option_tree_menu[| 2] = new option_vector("Quit", 0);
option_tree_menu[| 1].next[| 0] = new option_vector("Sound", 0);
option_tree_menu[| 1].next[| 1] = new option_vector("Back", 0);
#endregion 

#region Game Option Tree
option_tree_game = ds_list_create();
option_tree_game[| 0] = new option_vector("Resume", 0);
option_tree_game[| 1] = new option_vector("Settings", ds_list_create());
option_tree_game[| 2] = new option_vector("Quit", 0);
option_tree_game[| 1].next[| 0] = new option_vector("Sound", 0);
option_tree_game[| 1].next[| 1] = new option_vector("Back", 0);
#endregion

options_shown = ds_list_create();
options_shown[| 0] = "Play";
options_shown[| 1] = "Settings";
options_shown[| 2] = "Quit";
menu_layer = 0;

inventory = array_create(INVENTORY_SIZE, -1);
inventory_stacks = array_create(INVENTORY_SIZE, 0);
inventory_x = room_width - (sprite_get_width(s_inventory_frame) * INVENTORY_COLUMNS) - text_margin;
inventory_y = room_height - sprite_get_height(s_inventory_frame) - text_margin;
inv_opened_height = 0;
working_with_inventory = false;
mouse_slot = -1;
mouse_stack = 0;

inv_open = false;
can_gen_grass = false;
gpu_set_ztestenable(true);
gpu_set_alphatestenable(true);
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_texcoord();
vertex_format_add_color();

format = vertex_format_end();
vbuff = vertex_create_buffer();
vertex_begin(vbuff, format);


chat_input = "";
typing = false;
can_delete_chat = false;
chat_max_lines = 10;
chat_max_history_lines = 30;
chat_is_empty = true;
chat_portion_shown_index = 0;
max_characters_per_lines = 50;
chat_width = 25 * 10;
chat_height = text_margin * (chat_max_lines + 1);

chat_x = text_margin;
chat_y = room_height - text_margin - chat_height;

is_crafting = false;
can_craft_list = array_create(sprite_get_number(s_items), 0);
which_drop_to_craft_on_id = -1;
curr_drawing = array_create(MAX_DRAWING, -1);
drawing_index = -1;