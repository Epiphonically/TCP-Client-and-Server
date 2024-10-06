randomize();
enum network {
	PLAYER_JOIN,
	OTHER_JOIN,
	START_TYPING,
	CHANGE_USERNAME,
	CONTINUOUS_SENDBACK,
	POPULATE_WITH_DROPS,
	POPULATE_WITH_GRASS,
	POPULATE_WITH_TREES,
	LEAVE,
	MOVE,
	SET_IMAGE,
	SET_DEFAULT_STATE,
	ACTION_ONE,
	ACTION_TWO,
	PLAYER_FRAME_INFO,
	ITEM_DROP,
	ITEM_DESTROY,
	ITEM_MOVE,
	PLAYER_DROP_ITEM,
	PLAYER_PICKUP_ITEM,
	INVENTORY_SWAP,
	INVENTORY_INCREMENT,
	OPEN_CRAFTING,
	RECEIVE_DRAWING,
	WRITE_MESSAGE
}

enum STATES {
	DEFAULT,
	ATTACK,
	CHARGING,
	DASH,
	CRAFTING
}

enum class {
	NONE,
	SHARPSHOOTER,
	DUELIST,
	CASTER,
	ROUGUE
}

function item_vector(_item_type, _item_id, _stack, _item_obj) constructor {
	item_type = _item_type;
	item_id = _item_id;
	stack = _stack;
	item_obj = _item_obj;
}

function inventory_vector(_item_id, _stack) constructor {
	item_id = _item_id;
	stack = _stack;
}	

function tree_vector(_tree_id, _tree_obj) constructor {
	tree_id = _tree_id;
	tree_obj = _tree_obj;
}

function enemy_vector(_enemy_id, _enemy_type, _enemy_obj) constructor {
	enemy_id = _enemy_id;
	enemy_type = _enemy_type;
	enemy_obj = _enemy_obj;
}
tick = 0;
port = 60000;
max_clients = 10;
socket_list = ds_list_create();
socket_to_player = ds_map_create();
socket_to_username = ds_map_create();
socket_to_inventories = ds_map_create();
socket_to_inventories_stacks = ds_map_create();
socket_to_can_craft_list = ds_map_create();
server_buffer = buffer_create(1024, buffer_fixed, 1);
network_create_server(network_socket_tcp, port, max_clients);

/*
How Do I do the items???????
List of all items??
OK ITS FINAL EACH AND EVERY ITEM DROP NEEDS ITS OWN UNIQUE ID OR ELSE ITS REALL BAD TO DIFFERENTIATE THEM
Server needs to calculate all interactions with items not client or else
DUPE GLITCH 
*/ 
curr_drop_id = 0;
//The keys are the drop_id
items_dropped_map = ds_map_create();
//The keys are the enemy_id
enemies_map = ds_map_create();
#region Map Generation
num_grass = (room_width * room_height) / 100;
num_trees = ((room_width * room_height) / 1000);

grass_coords = array_create(num_grass * 2, 0);
tree_coords = array_create(num_trees * 2, 0);

for (var i = 0; i < num_grass * 2; i += 2) {
	grass_coords[i] = irandom(room_width);
	grass_coords[i + 1] = irandom(room_height);
	
}

for (var i = 0; i < num_trees * 2; i += 2) {
	tree_coords[i] = irandom(room_width);
	tree_coords[i + 1] = irandom(room_height);
	
}

#endregion

// CHAT

chat = ds_list_create();
max_characters_per_line = 25;
chat_max_history_lines = 30;

#region start and end indices for items
materials_start = 0;
marterials_end = 1;

weapon_start = 1;
weapon_end = 2;

offhand_start = 2;
offhand_end = 3;

helmet_start = 2;
helmet_end = 3;

pants_start = 3;
pants_end = 4;

boots_start = 4;
boots_end = 5;
#endregion

#region Recipes
model_drawings = array_create(1, 1);
recipes = ds_grid_create(sprite_get_number(s_items), sprite_get_number(s_items));
recipes[# 0, 0] = 1;
#endregion