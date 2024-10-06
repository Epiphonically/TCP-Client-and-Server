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
	RECIEVE_DRAWING,
	WRITE_MESSAGE
}

function coordinate_vector(_x, _y) constructor {
	xx = _x;
	yy = _y;
}

function item_vector(_item_type, _item_id, _stack, _item_obj) constructor {
	item_type = _item_type;
	item_id = _item_id;
	stack = _stack;
	item_obj = _item_obj;
}

function tree_vector(_tree_id, _tree_obj) constructor {
	tree_id = _tree_id;
	tree_obj = _tree_obj;
}


ip = "127.0.0.1";
port = 60000;
client = network_create_socket(network_socket_tcp);
network_connect(client, ip, port);		
client_buffer = buffer_create(1024, buffer_fixed, 1);
socket_list = ds_list_create();
socket_to_player = ds_map_create();
socket_to_network_queues = ds_map_create();
socket_to_network_queues[? -1] = ds_list_create();
socket_to_network_queues_frame = ds_map_create();
socket_to_username = ds_map_create();
//Im a network connector so when I send a packet I send myself
//The server is a network creator so they specify who to send the packet to
items_dropped_map = ds_map_create();
trees_map = ds_map_create();
chat = ds_list_create();
socket = 0;