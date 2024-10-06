function recieved_packet(buffer, socket) {
	var task = buffer_read(buffer, buffer_u8);
	show_debug_message("Socket " + string(socket));
	switch (task) {
		
		case network.START_TYPING:
		
		if (ds_map_exists(o_server.socket_to_player, socket)) {
			var the_player = o_server.socket_to_player[? socket];
			if (the_player.typing) {
				the_player.typing = false;	
			} else {
				the_player.typing = true;	
			}
			buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
			buffer_write(o_server.server_buffer, buffer_u8, network.START_TYPING);
			buffer_write(o_server.server_buffer, buffer_bool, the_player.typing);
			network_send_packet(socket, o_server.server_buffer, buffer_tell(o_server.server_buffer));
		}
		break;
		
		case network.MOVE: 
		if (ds_map_exists(o_server.socket_to_player, socket)) {
			var player_to_move = ds_map_find_value(o_server.socket_to_player, socket);
			if (player_to_move.state != STATES.DASH) {
				var x_axis = buffer_read(buffer, buffer_s8);
				var y_axis = buffer_read(buffer, buffer_s8);
				player_to_move.x_axis = x_axis;
				player_to_move.y_axis = y_axis;
			}
			
		}
		break;
		
		case network.ACTION_ONE: // Left clicks to do an action
		if (ds_map_exists(o_server.socket_to_player, socket)) {
			var angle_to_mouse = buffer_read(buffer, buffer_u16);
			var pressed_down = buffer_read(buffer, buffer_u8);
			var player = o_server.socket_to_player[? socket];
			if (pressed_down == 1) {
				if (player.state == STATES.CRAFTING) {
					player.drawing = true;
				} else if (player.state == STATES.DEFAULT) {
					player.needs_downpress = false;
					player.state = STATES.CHARGING;	
					player.face = angle_to_mouse;
					player.image_index = 0;
					player.image_speed = 0;
					buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
					buffer_write(o_server.server_buffer, buffer_u8, network.ACTION_ONE);
					buffer_write(o_server.server_buffer, buffer_u8, socket);
					buffer_write(o_server.server_buffer, buffer_u16, angle_to_mouse);
					buffer_write(o_server.server_buffer, buffer_u8, 0); // Charging
					for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
						var socket_send_to = o_server.socket_list[| i];	
						network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
					}
				} else if (player.image_index >= (sprite_get_number(player.sprite_index) - 2) && player.buffered_state == STATES.DEFAULT) {
					player.needs_downpress = false;
					player.buffered_state = STATES.CHARGING;	
					player.buffered_face = angle_to_mouse;
				}
			} else { //Make sure after every attack you need a new downpress
				if (player.state == STATES.CRAFTING) {
					player.drawing = false;
				} else if (player.state == STATES.CHARGING && !player.needs_downpress) {
					player.state = STATES.ATTACK;	
					player.face = angle_to_mouse;
					player.image_index = 0;
					player.image_speed = 1;
					buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
					buffer_write(o_server.server_buffer, buffer_u8, network.ACTION_ONE);
					buffer_write(o_server.server_buffer, buffer_u8, socket);
					buffer_write(o_server.server_buffer, buffer_u16, angle_to_mouse);
					buffer_write(o_server.server_buffer, buffer_u8, 1); // Release
					for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
						var socket_send_to = o_server.socket_list[| i];	
						network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
					}
				} else if (player.state != STATES.DEFAULT
						   && !player.needs_downpress 
						   && player.can_buffer_attack 
						   && player.image_index >= (sprite_get_number(player.sprite_index) - 2) 
						   && (player.buffered_state == STATES.DEFAULT || player.buffered_state == STATES.CHARGING)) {
					
					player.buffered_state = STATES.ATTACK;	
					player.buffered_face = angle_to_mouse;
				}
			}
		}
		break;
		
		case network.ACTION_TWO:
		if (ds_map_exists(o_server.socket_to_player, socket)) {
			var angle_to_mouse = buffer_read(buffer, buffer_u16);
			var player = o_server.socket_to_player[? socket];
			
			if (player.state == STATES.DEFAULT) {
				player.state = STATES.DASH;	
				player.face = angle_to_mouse;
				player.image_index = 0;
				player.image_speed = 1;
				buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
				buffer_write(o_server.server_buffer, buffer_u8, network.ACTION_TWO);
				buffer_write(o_server.server_buffer, buffer_u8, socket);
				buffer_write(o_server.server_buffer, buffer_u16, angle_to_mouse);
				for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
					var socket_send_to = o_server.socket_list[| i];	
					network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
				}
			} else if (player.image_index >= (sprite_get_number(player.sprite_index) - 2) && player.buffered_state = STATES.DEFAULT) { 
				player.buffered_state = STATES.DASH;	
				player.buffered_face = angle_to_mouse;
			}
			
		}
		break;
		
		case network.PLAYER_FRAME_INFO:
			
			if (ds_map_exists(o_server.socket_to_player, socket)) {
				var angle_to_mouse = buffer_read(buffer, buffer_u16);
				var mouse_x_pos = buffer_read(buffer, buffer_u16);
				var mouse_y_pos = buffer_read(buffer, buffer_u16);
				var need_to_send_to_everyone = buffer_read(buffer, buffer_u8);
				var player = o_server.socket_to_player[? socket];
				player.constant_face = angle_to_mouse;
				player.mouse_x_pos = mouse_x_pos;
				player.mouse_y_pos = mouse_y_pos;
				// Maybe set player im spd
				if (need_to_send_to_everyone == 1 && player.state == STATES.DEFAULT) { // This frame info is only valid if the player is default state 
					
					buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
					buffer_write(o_server.server_buffer, buffer_u8, network.PLAYER_FRAME_INFO);
					buffer_write(o_server.server_buffer, buffer_u8, socket); //Send who??
					buffer_write(o_server.server_buffer, buffer_u16, angle_to_mouse);
					for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
						var socket_send_to = o_server.socket_list[| i];
						network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
					}
				}
			}
			
		break;
		
		case network.ITEM_DROP: // ADMIN DROP
			if (ds_map_exists(o_server.socket_to_player, socket)) {
				var player = o_server.socket_to_player[? socket];
				var item_type = buffer_read(buffer, buffer_u8);
				var stack = buffer_read(buffer, buffer_u8);
				//Send only to player update inventory
				network_drop_item(item_type, stack, player.x, player.y, player.constant_face);
			}
		break;
		
		case network.ITEM_DESTROY: // ADMIN DESTROY
			
		break;
		
		case network.PLAYER_DROP_ITEM: // Drops from an index and an ammount to drop
			if (ds_map_exists(o_server.socket_to_player, socket)) {
				var index = buffer_read(buffer, buffer_u8);
				var ammount = buffer_read(buffer, buffer_u8);
			
				var stacks_arr = o_server.socket_to_inventories_stacks[? socket];
				var inv_arr = o_server.socket_to_inventories[? socket]
				var item_type = inv_arr[index];
				var player = o_server.socket_to_player[? socket];
				if (inv_arr[index] != -1) {
					stacks_arr[index] -= ammount;
			
					if (stacks_arr[index] < 0) {
						ammount += stacks_arr[index];
						stacks_arr[index] = 0;	 
						show_debug_message("WE SHOUld NOT BE IN HERE");
					}
			
					if (stacks_arr[index] == 0) {
						inv_arr[index] = -1;	
					}
			
					buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
					buffer_write(o_server.server_buffer, buffer_u8, network.PLAYER_DROP_ITEM);
					buffer_write(o_server.server_buffer, buffer_u8, index);
					buffer_write(o_server.server_buffer, buffer_s8, inv_arr[index]);
					buffer_write(o_server.server_buffer, buffer_u8, stacks_arr[index]);
					network_send_packet(socket, o_server.server_buffer, buffer_tell(o_server.server_buffer));
					network_drop_item(item_type, ammount, player.x, player.y, player.constant_face);
				}
			}
		break;
		
		case network.PLAYER_PICKUP_ITEM:
			if (ds_map_exists(o_server.socket_to_player, socket)) { // PUT THIS EVERYWHERE
				var player = o_server.socket_to_player[? socket];
				var nearest_drop = instance_nearest(player.x, player.y, o_item_drop);
				if (nearest_drop != noone) {
					var dist = point_distance(player.x, player.y, nearest_drop.x, nearest_drop.y);
					if (dist <= player.pickup_range) {
						add_drop_to_inv(socket, nearest_drop.drop_id);
					}
				}
			}
			
		break;
		
		case network.INVENTORY_SWAP:
		if (ds_map_exists(o_server.socket_to_player, socket)) {
			var index = buffer_read(buffer, buffer_u8);
			var whos_inventory = o_server.socket_to_inventories[? socket];
			var whos_stack = o_server.socket_to_inventories_stacks[? socket];
			
			var temp = whos_inventory[index];
			whos_inventory[index] = whos_inventory[INVENTORY_SIZE];
			whos_inventory[INVENTORY_SIZE] = temp;
			
			temp = whos_stack[index];
			whos_stack[index] = whos_stack[INVENTORY_SIZE];
			whos_stack[INVENTORY_SIZE] = temp;
			
			buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
			buffer_write(o_server.server_buffer, buffer_u8, network.INVENTORY_SWAP);
			buffer_write(o_server.server_buffer, buffer_u8, 1); // Does edit the mouse
			buffer_write(o_server.server_buffer, buffer_u8, index); // What index?
			buffer_write(o_server.server_buffer, buffer_s8, whos_inventory[index]); // Put this in that index
			buffer_write(o_server.server_buffer, buffer_u8, whos_stack[index]); // Put this stack in that index
			buffer_write(o_server.server_buffer, buffer_s8, whos_inventory[INVENTORY_SIZE]); // Put this in the mouse
			buffer_write(o_server.server_buffer, buffer_u8, whos_stack[INVENTORY_SIZE]); // Put this stack in the mouse 
			network_send_packet(socket, o_server.server_buffer, buffer_tell(o_server.server_buffer));
		}
		break;
		
		case network.INVENTORY_INCREMENT:
			if (ds_map_exists(o_server.socket_to_player, socket)) {
				var index = buffer_read(buffer, buffer_u8);
				var ammount = buffer_read(buffer, buffer_u8);
				var inv = o_server.socket_to_inventories[? socket];
				var inv_stacks = o_server.socket_to_inventories_stacks[? socket];
				if (ammount > inv_stacks[INVENTORY_SIZE]) {
					ammount = inv_stacks[INVENTORY_SIZE];
				}
				if (inv[index] != inv[INVENTORY_SIZE]) {
					inv[index] = inv[INVENTORY_SIZE];	
				}
				var max_stack = get_max_stack(inv[index]);
				var difference_from_full = max_stack - inv_stacks[index];
				
				if (ammount - difference_from_full < 0) {
					inv_stacks[index] += ammount;
					inv_stacks[INVENTORY_SIZE] -= ammount;
				} else {
					inv_stacks[index] = max_stack;
					inv_stacks[INVENTORY_SIZE] -= difference_from_full;
				}
				if (inv_stacks[INVENTORY_SIZE] == 0) {
					inv[INVENTORY_SIZE] = -1;	
				}
				
				buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
				buffer_write(o_server.server_buffer, buffer_u8, network.INVENTORY_INCREMENT);
				buffer_write(o_server.server_buffer, buffer_u8, index);
				buffer_write(o_server.server_buffer, buffer_s8, inv[index]);
				buffer_write(o_server.server_buffer, buffer_u8, inv_stacks[index]);
				buffer_write(o_server.server_buffer, buffer_s8, inv[INVENTORY_SIZE]);
				buffer_write(o_server.server_buffer, buffer_u8, inv_stacks[INVENTORY_SIZE]);
				network_send_packet(socket, o_server.server_buffer, buffer_tell(o_server.server_buffer));
			}
		break;
		
		case network.OPEN_CRAFTING:
		if (ds_map_exists(o_server.socket_to_player, socket)) {
			
			var player = o_server.socket_to_player[? socket];
			if (player.is_crafting) {
				player.is_crafting = false;
				player.state = STATES.DEFAULT;
				buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
				buffer_write(o_server.server_buffer, buffer_u8, network.OPEN_CRAFTING);
				buffer_write(o_server.server_buffer, buffer_bool, player.is_crafting);
				network_send_packet(socket, o_server.server_buffer, buffer_tell(o_server.server_buffer));	
			} else if (player.state == STATES.DEFAULT){
				player.is_crafting = true;
				player.state = STATES.CRAFTING;
				buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
				buffer_write(o_server.server_buffer, buffer_u8, network.OPEN_CRAFTING);
				buffer_write(o_server.server_buffer, buffer_bool, player.is_crafting);
				network_send_packet(socket, o_server.server_buffer, buffer_tell(o_server.server_buffer));	
				
			}
		}
		break;
		
		case network.WRITE_MESSAGE:
		//PARSE THE MESSAGE
			
			var the_message = buffer_read(buffer, buffer_string);
			if (string_char_at(the_message, 0) == "/") {
				var command = "";
				var space_pos = string_pos(" ", the_message);
			
				command = string_copy(the_message, 1, space_pos - 1);
				command = string_lower(command);
				
				switch (command) {
					case "/nick":
					show_debug_message(command);
						var nick = string_copy(the_message, space_pos + 1, string_length(the_message) - space_pos);
						show_debug_message(nick);
						o_server.socket_to_username[? socket] = nick;
						buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
						buffer_write(o_server.server_buffer, buffer_u8, network.CHANGE_USERNAME);
						buffer_write(o_server.server_buffer, buffer_u8, socket);
						buffer_write(o_server.server_buffer, buffer_string, nick);
						for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
							var socket_send_to = o_server.socket_list[| i];
							network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));	
						}
					break;
					
					default:
						;
					break;
				}
			} else {
				the_message = o_server.socket_to_username[? socket] + ": " + the_message;
				var num_messages = floor(string_length(the_message) / o_server.max_characters_per_line);
			
				if (string_length(the_message) % o_server.max_characters_per_line != 0) {
					num_messages++;	
				}
			
				show_debug_message(num_messages);
				var messages_arr = array_create(num_messages, "");
				for (var i = 0; i < num_messages; i++) {
					messages_arr[i] = string_copy(
					the_message, 
					i * o_server.max_characters_per_line, 
					min(o_server.max_characters_per_line, string_length(the_message) -  (i * o_server.max_characters_per_line) + 1));
					if (ds_list_size(o_server.chat) == o_server.chat_max_history_lines) {
						for (var i = 0; i < ds_list_size(o_server.chat) - 1; i++) {
							o_server.chat[| i] = o_server.chat[| i + 1];
						}
						o_server.chat[| chat_max_history_lines - 1] = messages_arr[i];
					} else {
						ds_list_add(o_server.chat, messages_arr[i]);
					}
				}
			
					
				for (var j = 0; j < num_messages; j++) {
					buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
					buffer_write(o_server.server_buffer, buffer_u8, network.WRITE_MESSAGE);
					buffer_write(o_server.server_buffer, buffer_string, messages_arr[j]);
					for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
						var socket_send_to = o_server.socket_list[| i];
						network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
					}
				}
			}
		break;
	} 
}

function network_drop_item(_item_type, _stack, _item_x_pos, _item_y_pos, _dir) {
	//Handle adding the item to the list
	//WAIT WHAT IF DELETE AND DROP GET CALLED AT ONCE
	
	
	buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
	buffer_write(o_server.server_buffer, buffer_u8, network.ITEM_DROP);
	buffer_write(o_server.server_buffer, buffer_u8, _item_type); 
	buffer_write(o_server.server_buffer, buffer_u8, _stack);
	buffer_write(o_server.server_buffer, buffer_u16, _item_x_pos);
	buffer_write(o_server.server_buffer, buffer_u16, _item_y_pos);
	buffer_write(o_server.server_buffer, buffer_u16, o_server.curr_drop_id);
	for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
		var socket_send_to = o_server.socket_list[| i];
		network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
	}	
	var drop_obj = instance_create_layer(_item_x_pos, _item_y_pos, "Instances", o_item_drop);
	drop_obj.dir = _dir;
	o_server.items_dropped_map[? o_server.curr_drop_id] = new item_vector(_item_type,
																		  o_server.curr_drop_id,
																		  _stack,  
																		  drop_obj);
	drop_obj.drop_id = o_server.curr_drop_id;
	drop_obj.item_type = _item_type;
	drop_obj.stack = _stack;
	o_server.curr_drop_id++;
}

//RETURN NUM U ACTUALLY REMOVED
function network_destroy_item(_item_id, _num_to_destroy) {
	var output = 0;
	if (ds_map_exists(o_server.items_dropped_map, _item_id)) {
		//Honestly just delete what you can based on num to destroy
		//CALL THIS CAREFULLY YOU BUM
		buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
		buffer_write(o_server.server_buffer, buffer_u8, network.ITEM_DESTROY);
		buffer_write(o_server.server_buffer, buffer_u16, _item_id);
		var delta = o_server.items_dropped_map[? _item_id].stack - _num_to_destroy;
		if (delta > 0) {
			output = _num_to_destroy;
			o_server.items_dropped_map[? _item_id].stack -= _num_to_destroy;
			buffer_write(o_server.server_buffer, buffer_u8, o_server.items_dropped_map[? _item_id].stack); //SEND NEW STACK NOOB
		} else {
			output = o_server.items_dropped_map[? _item_id].stack;
			instance_destroy(o_server.items_dropped_map[? _item_id].item_obj);
			ds_map_delete(o_server.items_dropped_map, _item_id);
			buffer_write(o_server.server_buffer, buffer_u8, 0);
		}
		for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
			var socket_send_to = o_server.socket_list[| i];
			network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
		}
	}
	return output;
}