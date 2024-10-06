function get_max_stack(_item_type) {
	return 20;
}

//Just adds to INV return num added 
//Should not have a side effect on any drop vectors 
function add_drop_to_inv(_socket, _drop_id) {
	var output = 0;
	var inv = o_server.socket_to_inventories[? _socket]; //Players inventory array
	var stack = o_server.socket_to_inventories_stacks[? _socket]; //Players stack array
	var item_vec = o_server.items_dropped_map[? _drop_id];
	var stack_in_item_vec = item_vec.stack;
	var max_stack = get_max_stack(item_vec.item_type);
	//Fill the slots with the item in there already
	for (var i = 0; i < INVENTORY_SIZE && stack_in_item_vec > 0; i++) {
		if (inv[i] == item_vec.item_type && stack[i] < max_stack) { // We will def edit this slot tho
			var slot_can_fit = max_stack - stack[i];
			if (stack_in_item_vec - slot_can_fit <= 0) { // This is either we have exactly enough room or a TON of room
				stack[i] += stack_in_item_vec;
				output += stack_in_item_vec;
				stack_in_item_vec = 0;
			} else { // This is when we overflow the thingy lol
				output += slot_can_fit;
				stack_in_item_vec -= slot_can_fit;
				stack[i] = max_stack;
			}
			buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
			buffer_write(o_server.server_buffer, buffer_u8, network.PLAYER_PICKUP_ITEM);
			buffer_write(o_server.server_buffer, buffer_u8, i); // Write the index
			buffer_write(o_server.server_buffer, buffer_s8, inv[i]); // Write whats in the inv
			buffer_write(o_server.server_buffer, buffer_u8, stack[i]); // Write the stack in the inv
			network_send_packet(_socket, o_server.server_buffer, buffer_tell(o_server.server_buffer));
		}
	}
	
	//Look for empty slots
	for (var i = 0; i < INVENTORY_SIZE && stack_in_item_vec > 0; i++) {
		if (inv[i] == -1) { // We will def edit this slot tho
			if (stack_in_item_vec - max_stack <= 0) { // The max stack can fit the rest of the drop
				inv[i] = item_vec.item_type;
				stack[i] += stack_in_item_vec;
				output += stack_in_item_vec;
				stack_in_item_vec = 0;
			} else { // We overflowed the empty space wow...
				inv[i] = item_vec.item_type;
				stack_in_item_vec -= max_stack;
				output += max_stack;
				stack[i] = max_stack;
			}
			buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
			buffer_write(o_server.server_buffer, buffer_u8, network.PLAYER_PICKUP_ITEM);
			buffer_write(o_server.server_buffer, buffer_u8, i); // Write the index
			buffer_write(o_server.server_buffer, buffer_s8, inv[i]); // Write whats in the inv
			buffer_write(o_server.server_buffer, buffer_u8, stack[i]); // Write the stack in the inv
			network_send_packet(_socket, o_server.server_buffer, buffer_tell(o_server.server_buffer));
		}
	}
	network_destroy_item(item_vec.item_id, item_vec.stack - stack_in_item_vec);
	return output;
}

