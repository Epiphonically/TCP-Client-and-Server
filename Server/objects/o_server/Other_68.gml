var type_event = ds_map_find_value(async_load, "type");
var socket = ds_map_find_value(async_load, "socket");

switch (type_event)
{
	case network_type_connect: //Player joins
		ds_list_add(socket_list, socket);
		var player = instance_create_depth(0, 0, 1, o_player);
		ds_map_add(socket_to_player, socket, player);
		ds_map_add(socket_to_username, socket, "Player" + string(socket));
		ds_map_add(socket_to_inventories, socket, array_create(INVENTORY_SIZE + 1, -1));
		ds_map_add(socket_to_inventories_stacks, socket, array_create(INVENTORY_SIZE + 1, 0));
		ds_map_add(socket_to_can_craft_list, socket, array_create(sprite_get_number(s_items), 0));
		player.whos_socket = socket;
		//Send to the player "PLAYER_JOIN"
		//Spawn at spawn 
		buffer_seek(server_buffer, buffer_seek_start, 0);
		buffer_write(server_buffer, buffer_u8, network.PLAYER_JOIN);
		buffer_write(server_buffer, buffer_u8, socket);
		buffer_write(server_buffer, buffer_string, socket_to_username[? socket]);
		network_send_packet(socket, server_buffer, buffer_tell(server_buffer));
		// We need to populate the player who joined with all the drops
		var items_key_arr = ds_map_keys_to_array(items_dropped_map);
		for (var i = 0; i < array_length(items_key_arr); i++) {
			var item_vec = items_dropped_map[? items_key_arr[i]];
			var obj = item_vec.item_obj;
			buffer_seek(server_buffer, buffer_seek_start, 0);
			buffer_write(server_buffer, buffer_u8, network.POPULATE_WITH_DROPS);
			buffer_write(server_buffer, buffer_u8, item_vec.item_type);
			buffer_write(server_buffer, buffer_u16, item_vec.item_id);
			buffer_write(server_buffer, buffer_u8, item_vec.stack);
			buffer_write(server_buffer, buffer_u16, obj.x);
			buffer_write(server_buffer, buffer_u16, obj.y);
			
			network_send_packet(socket, server_buffer, buffer_tell(server_buffer));
		}
		
		//Send grass
		for (var i = 0; i < array_length(grass_coords); i += 2) {
			buffer_seek(server_buffer, buffer_seek_start, 0);
			buffer_write(server_buffer, buffer_u8, network.POPULATE_WITH_GRASS);
			buffer_write(server_buffer, buffer_u16, grass_coords[i]);
			buffer_write(server_buffer, buffer_u16, grass_coords[i + 1]);
			if (i + 2 >= array_length(grass_coords)) {
				buffer_write(server_buffer, buffer_u8, 1);	
			} else {
				buffer_write(server_buffer, buffer_u8, 0);	
			}
			network_send_packet(socket, server_buffer, buffer_tell(server_buffer));
		}
		
		//Send trees
		for (var i = 0; i < array_length(tree_coords); i += 2) {
			buffer_seek(server_buffer, buffer_seek_start, 0);
			buffer_write(server_buffer, buffer_u8, network.POPULATE_WITH_TREES);
			buffer_write(server_buffer, buffer_u16, i);
			buffer_write(server_buffer, buffer_u16, tree_coords[i]);
			buffer_write(server_buffer, buffer_u16, tree_coords[i + 1]);

			network_send_packet(socket, server_buffer, buffer_tell(server_buffer));
		}
		
		//Send to the player the other players
		for (var i = 0; i < ds_list_size(socket_list); i++) {
			var socket_to_send = socket_list[| i];
			if (socket_to_send != socket) {
				var corresponding_player = socket_to_player[? socket_to_send];
				buffer_seek(server_buffer, buffer_seek_start, 0);
				buffer_write(server_buffer, buffer_u8, network.OTHER_JOIN);
				buffer_write(server_buffer, buffer_u8, socket_to_send);
				buffer_write(server_buffer, buffer_string, socket_to_username[? socket_to_send]);
				buffer_write(server_buffer, buffer_u16, corresponding_player.x);
				buffer_write(server_buffer, buffer_u16, corresponding_player.y);
				network_send_packet(socket, server_buffer, buffer_tell(server_buffer));	
			}
		}
		
		//Send to the rest ""OTHER_JOIN"
		buffer_seek(server_buffer, buffer_seek_start, 0);
		buffer_write(server_buffer, buffer_u8, network.OTHER_JOIN);
		buffer_write(server_buffer, buffer_u8, socket);
		buffer_write(server_buffer, buffer_string, socket_to_username[? socket]);
		buffer_write(server_buffer, buffer_u16, 0); //Spawn x
		buffer_write(server_buffer, buffer_u16, 0); //Spawn y
		for (var i = 0; i < ds_list_size(socket_list); i++) {
			var socket_send_to = socket_list[| i];
			if (socket_send_to != socket) {
				network_send_packet(socket_send_to, server_buffer, buffer_tell(server_buffer));
			}
		}
	break;
	
	case network_type_disconnect: //Player leaves
		var x_pos = ds_map_find_value(socket_to_player, socket).x;
		var y_pos = ds_map_find_value(socket_to_player, socket).y;
		for (var i = 0; i < INVENTORY_SIZE + 1; i++) {
			randomize();
			if (socket_to_inventories[? socket][i] != -1) {
				network_drop_item(socket_to_inventories[? socket][i], socket_to_inventories_stacks[? socket][i], x_pos, y_pos, random(360));	
			}
		}
		ds_list_delete(socket_list, ds_list_find_index(socket_list, socket));
		instance_destroy(ds_map_find_value(socket_to_player, socket));
		ds_map_delete(socket_to_inventories, socket);
		ds_map_delete(socket_to_inventories_stacks, socket);
		ds_map_delete(socket_to_player, socket);
		ds_map_delete(socket_to_username, socket);
		ds_map_delete(socket_to_can_craft_list, socket);
		//Tell EVERYONE that kid left
		buffer_seek(server_buffer, buffer_seek_start, 0);
		buffer_write(server_buffer, buffer_u8, network.LEAVE);
		buffer_write(server_buffer, buffer_u8, socket);
		for (var i = 0; i < ds_list_size(socket_list); i++) {
			var socket_send_to = socket_list[| i];
			network_send_packet(socket_send_to, server_buffer, buffer_tell(server_buffer));
		}
		
	
	break;
	
	case network_type_data:
		//You only send a buffer here probably
		var buffer = ds_map_find_value(async_load, "buffer");
		var id_socket = ds_map_find_value(async_load, "id");
		buffer_seek(buffer, buffer_seek_start, 0);
		recieved_packet(buffer, id_socket);
		show_debug_message(string(socket) + " : " + string(id_socket));
	break;
}
