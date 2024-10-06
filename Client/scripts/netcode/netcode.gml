//You can use your network queue for continuous packets (i.e. Movement)
//Instantaneous packets just process immediately (i.e. Picking up items)

function network_vector(_type_event, _tick, _data_list) constructor {
	type_event = _type_event;
	tick = _tick;
	data_list = _data_list;
}

function recieved_packet(buffer) {
	var task = buffer_read(buffer, buffer_u8);
	
	switch (task) {
		case network.PLAYER_JOIN:
			var socket = buffer_read(buffer, buffer_u8);
		
			var username = buffer_read(buffer, buffer_string);
			o_client.socket = socket;
			o_client.socket_to_username[? socket] = username;
			var player = instance_create_depth(0, 0, 1, o_player);
			ds_list_add(o_client.socket_list, socket);
			ds_map_add(o_client.socket_to_player, socket, player);
			ds_map_add(o_client.socket_to_network_queues, socket, ds_list_create());
			ds_map_add(o_client.socket_to_network_queues_frame, socket, ds_list_create()); //network queue

		break;
		
		case network.OTHER_JOIN:
			var socket = buffer_read(buffer, buffer_u8);
			var username = buffer_read(buffer, buffer_string);
			o_client.socket_to_username[? socket] = username;
			var other_player_x = buffer_read(buffer, buffer_u16);
			var other_player_y = buffer_read(buffer, buffer_u16);
			var other_player = instance_create_depth(other_player_x, other_player_y, 1, o_other_player);
			other_player.my_socket = socket;
			ds_list_add(o_client.socket_list, socket);
			ds_map_add(o_client.socket_to_player, socket, other_player);
			ds_map_add(o_client.socket_to_network_queues, socket, ds_list_create());
			ds_map_add(o_client.socket_to_network_queues_frame, socket, ds_list_create()); //network_queue
	
		break;
		
		case network.START_TYPING:
			var _typing = buffer_read(buffer, buffer_bool);
			o_game.typing = _typing;
		
		break;
		
		case network.CHANGE_USERNAME:
			var socket = buffer_read(buffer, buffer_u8);
			var _username = buffer_read(buffer, buffer_string);
			o_client.socket_to_username[? socket] = _username;
		break; 
		
		case network.CONTINUOUS_SENDBACK:
			
			var item_id = buffer_read(buffer, buffer_u16);
			
			var arr = ds_map_keys_to_array(o_client.items_dropped_map);
			if (item_id != -1) {
				for (var i = 0; i < array_length(arr); i++) {
					var item_vec = o_client.items_dropped_map[? arr[i]];
					if (item_vec.item_id == item_id) {
						item_vec.item_obj.is_hovering = true;	
					} else {
						item_vec.item_obj.is_hovering = false;
					}
				}
			} else {
				for (var i = 0; i < array_length(arr); i++) {
					item_vec.item_obj.is_hovering = false;
				}
			}
			
		break;
		
		case network.POPULATE_WITH_DROPS:
			var item_type = buffer_read(buffer, buffer_u8);
			var item_id = buffer_read(buffer, buffer_u16);
			var stack = buffer_read(buffer, buffer_u8);
			var x_pos = buffer_read(buffer, buffer_u16);
			var y_pos = buffer_read(buffer, buffer_u16);	
			o_client.items_dropped_map[? item_id] = new item_vector(
			item_type, 
			item_id,
			stack, 
			instance_create_layer(x_pos, y_pos, "Instances", o_item_drop));
		break;
		
		case network.POPULATE_WITH_GRASS:		
			var grass_x = buffer_read(buffer, buffer_u16);
			var grass_y = buffer_read(buffer, buffer_u16);
			var the_end = buffer_read(buffer, buffer_u8);
			var _depth = -(grass_y + sprite_get_height(s_grass));
			var uvs = sprite_get_uvs(s_grass, irandom(sprite_get_number(s_grass)) - 1);
				
			vertex_position_3d(o_game.vbuff, grass_x, grass_y, _depth);
			vertex_texcoord(o_game.vbuff, uvs[0], uvs[1]);
			vertex_color(o_game.vbuff, c_white, 1);
				
			vertex_position_3d(o_game.vbuff, grass_x + sprite_get_width(s_grass), grass_y, _depth);
			vertex_texcoord(o_game.vbuff, uvs[2], uvs[1]);
			vertex_color(o_game.vbuff, c_white, 1);
				
			vertex_position_3d(o_game.vbuff, grass_x, grass_y + sprite_get_height(s_grass), _depth);
			vertex_texcoord(o_game.vbuff, uvs[0], uvs[3]);
			vertex_color(o_game.vbuff, c_white, 1);
				
			vertex_position_3d(o_game.vbuff, grass_x + sprite_get_width(s_grass), grass_y, _depth);
			vertex_texcoord(o_game.vbuff, uvs[2], uvs[1]);
			vertex_color(o_game.vbuff, c_white, 1);
				
			vertex_position_3d(o_game.vbuff, grass_x, grass_y + sprite_get_height(s_grass), _depth);
			vertex_texcoord(o_game.vbuff, uvs[0], uvs[3]);
			vertex_color(o_game.vbuff, c_white, 1);
				
			vertex_position_3d(o_game.vbuff, grass_x + sprite_get_width(s_grass), grass_y + sprite_get_height(s_grass), _depth);
			vertex_texcoord(o_game.vbuff, uvs[2], uvs[3]);
			vertex_color(o_game.vbuff, c_white, 1);
			
			if (the_end) {
				vertex_end(o_game.vbuff);
				vertex_freeze(o_game.vbuff);
				o_game.can_gen_grass = true;	
			}
		break;
		
		case network.POPULATE_WITH_TREES:
			var tree_id = buffer_read(buffer, buffer_u16);
			var tree_x = buffer_read(buffer, buffer_u16);
			var tree_y = buffer_read(buffer, buffer_u16);
			o_client.trees_map[? tree_id] = new tree_vector(tree_id, instance_create_layer(tree_x, tree_y, "Instances", o_tree));
		break;
		
		case network.LEAVE:
			var socket = buffer_read(buffer, buffer_u8);
			instance_destroy(ds_map_find_value(o_client.socket_to_player, socket));
			ds_map_delete(o_client.socket_to_player, socket);
			ds_list_destroy(o_client.socket_to_network_queues[? socket]);
			ds_list_destroy(o_client.socket_to_network_queues_frame[? socket]);
			ds_map_delete(o_client.socket_to_network_queues, socket);
			ds_map_delete(o_client.socket_to_network_queues_frame, socket);
			ds_list_delete(o_client.socket_list, socket);
		break;
		
		case network.MOVE:
			var socket = buffer_read(buffer, buffer_u8);
			var player_to_move = ds_map_find_value(o_client.socket_to_player, socket);
			var x_pos = buffer_read(buffer, buffer_f16);
			var y_pos = buffer_read(buffer, buffer_f16);
			var server_tick = buffer_read(buffer, buffer_u8); 
			var arr = array_create(3, -1);
			arr[0] = player_to_move;
			arr[1] = x_pos;
			arr[2] = y_pos;
			//Move that certain player at the same priority as the other players
			ds_list_add(o_client.socket_to_network_queues[? socket], new network_vector(network.MOVE, server_tick, arr));
		break;
		
		case network.SET_IMAGE:
			var socket = buffer_read(buffer, buffer_u8);
			var _image_index = buffer_read(buffer, buffer_u8);
			var _sprite_index = buffer_read(buffer, buffer_u16);
			var _image_xscale = buffer_read(buffer, buffer_s8);
			var is_dead_tick = buffer_read(buffer, buffer_bool);
			var _tick = buffer_read(buffer, buffer_u8);
			var arr = array_create(3, -1);
			var who = o_client.socket_to_player[? socket];
			if (!is_dead_tick) {
				arr[0] = who;
				arr[1] = _image_index;
				arr[2] = _sprite_index;
				arr[3] = _image_xscale;
				//SET_IMAGE NETWORK QUEUE
				ds_list_add(o_client.socket_to_network_queues_frame[? socket], new network_vector(network.SET_IMAGE, _tick, arr));
			} else {
				var network_queue = o_client.socket_to_network_queues_frame[? socket];
			
				if (ds_list_empty(network_queue) || (ds_list_size(network_queue) > 0 && (network_queue[| (ds_list_size(network_queue) - 1)]).data_list[1] != 0)) {
					arr[0] = who;
					arr[1] = 0;
					arr[2] = _sprite_index;
					arr[3] = _image_xscale;
					ds_list_add(o_client.socket_to_network_queues_frame[? socket], new network_vector(network.SET_IMAGE, _tick, arr));
				}
			}
			
		break;
		
		case network.SET_DEFAULT_STATE:
			var which_socket = buffer_read(buffer, buffer_u8);
			var which_player = o_client.socket_to_player[? which_socket];
			which_player.state = STATES.DEFAULT;
		break;
		
		case network.ACTION_ONE:
			var which_socket = buffer_read(buffer, buffer_u8);
			var which_player = o_client.socket_to_player[? which_socket];
			which_player.state = STATES.ATTACK;
		
		break;
		
		case network.ACTION_TWO:
			var which_socket = buffer_read(buffer, buffer_u8);
			var which_player = o_client.socket_to_player[? which_socket];
			which_player.state = STATES.DASH;
		break;
		
		
		case network.ITEM_DROP: //Makes item
			var item_type = buffer_read(buffer, buffer_u8);
			var stack = buffer_read(buffer, buffer_u8);
			var item_x_pos = buffer_read(buffer, buffer_u16);
			var item_y_pos = buffer_read(buffer, buffer_u16);
			var item_id = buffer_read(buffer, buffer_u16);
			o_client.items_dropped_map[? item_id] = new item_vector(
			item_type,
			item_id,
			stack,
			instance_create_layer(item_x_pos, item_y_pos, "Instances", o_item_drop));
			o_client.items_dropped_map[? item_id].item_obj.image_index = item_type;
			o_client.items_dropped_map[? item_id].item_obj.image_speed = 0;
		break;
		
		case network.ITEM_DESTROY: //Destroys Drop
			var item_id = buffer_read(buffer, buffer_u16);
			var new_stack = buffer_read(buffer, buffer_u8);
			var item_vec = o_client.items_dropped_map[? item_id];
			item_vec.stack = new_stack;
			if (new_stack == 0) {
				instance_destroy(item_vec.item_obj)	;
				ds_map_delete(o_client.items_dropped_map, item_id);
			}
		break;
		
		case network.ITEM_MOVE:
			var item_id = buffer_read(buffer, buffer_u16);
			var x_pos = buffer_read(buffer, buffer_f16);
			var y_pos = buffer_read(buffer, buffer_f16);
			var server_tick = buffer_read(buffer, buffer_u8); 
			var arr = array_create(3, -1);
			arr[0] = o_client.items_dropped_map[? item_id].item_obj;
			arr[1] = x_pos;
			arr[2] = y_pos;
			//Move that certain player at the same priority as the other players
			ds_list_add(o_client.socket_to_network_queues[? -1], new network_vector(network.ITEM_MOVE, server_tick, arr));
			
		break;
		
		case network.PLAYER_DROP_ITEM:
			var index = buffer_read(buffer, buffer_u8);
			var type = buffer_read(buffer, buffer_s8);
			var stack = buffer_read(buffer, buffer_u8);
			if (index = INVENTORY_SIZE) { // The server stores the mouse slot at the end of its arrays
				o_game.mouse_slot = type;
				o_game.mouse_stack = stack;
			} else {
				o_game.inventory[index] = type;
				o_game.inventory_stacks[index] = stack;
			}
		break;
		
		case network.PLAYER_PICKUP_ITEM:
			var index = buffer_read(buffer, buffer_u8);
			var type = buffer_read(buffer, buffer_s8);
			var stack = buffer_read(buffer, buffer_u8);
			o_game.inventory[index] = type;
			o_game.inventory_stacks[index] = stack;
		break;
		
		case network.INVENTORY_SWAP:
			var edits_mouse = buffer_read(buffer, buffer_u8);
			var index = buffer_read(buffer, buffer_u8);
			var put_inv_item = buffer_read(buffer, buffer_s8);
			var put_inv_stack = buffer_read(buffer, buffer_u8);
			o_game.inventory[index] = put_inv_item;
			o_game.inventory_stacks[index] = put_inv_stack;
			if (edits_mouse) { 
				var put_mouse_item = buffer_read(buffer, buffer_s8);
				var put_mouse_stack = buffer_read(buffer, buffer_u8);	
				o_game.mouse_slot = put_mouse_item;
				o_game.mouse_stack = put_mouse_stack;
			}
		break;
		
		case network.INVENTORY_INCREMENT:
			var index = buffer_read(buffer, buffer_u8);
			var put_inv_item = buffer_read(buffer, buffer_s8);
			var put_inv_stack = buffer_read(buffer, buffer_u8);
			var put_mouse_item = buffer_read(buffer, buffer_s8);
			var put_mouse_stack = buffer_read(buffer, buffer_u8);	
			o_game.inventory[index] = put_inv_item;
			o_game.inventory_stacks[index] = put_inv_stack;
			o_game.mouse_slot = put_mouse_item;
			o_game.mouse_stack = put_mouse_stack;
		break;
		
		case network.OPEN_CRAFTING:
			o_game.is_crafting = buffer_read(buffer, buffer_bool);
			if (o_game.is_crafting) {
				if (instance_exists(o_player)) {
					o_player.state = STATES.CRAFTING;	
				}
			}
		break;
		
		case network.RECIEVE_DRAWING:
			var x_pos = buffer_read(buffer, buffer_u16);
			var y_pos = buffer_read(buffer, buffer_u16);
			var drawing_index = buffer_read(buffer, buffer_u16);
			o_game.drawing_index = drawing_index;
			o_game.curr_drawing[drawing_index] = new coordinate_vector(x_pos, y_pos);
		break;
		
		case network.WRITE_MESSAGE:
			var the_message = buffer_read(buffer, buffer_string);
			if (ds_list_size(o_client.chat) == o_game.chat_max_history_lines) {
				for (var i = 0; i < ds_list_size(o_client.chat) - 1; i++) {
					o_client.chat[| i] = o_client.chat[| i + 1];
				}
				o_client.chat[| o_game.chat_max_history_lines - 1] = the_message;
			} else {
				ds_list_add(o_client.chat, the_message);
			}
			if (o_game.chat_portion_shown_index + o_game.chat_max_lines == ds_list_size(o_client.chat) - 1) {
				o_game.chat_portion_shown_index++;	
			}
		break;
	}
	
}