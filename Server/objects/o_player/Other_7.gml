
can_buffer_attack = true;
charge_score = 0;
if (state != STATES.CRAFTING) {
	if (buffered_state != STATES.DEFAULT) {
		state = buffered_state;
		buffered_state = STATES.DEFAULT;
		face = buffered_face;
		switch (state) {
			case STATES.ATTACK:
				needs_downpress = true;
				sprite_index = s_player_attack_top_right;
				image_index = 0;
				image_speed = 1;
				buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
				buffer_write(o_server.server_buffer, buffer_u8, network.ACTION_ONE);
				buffer_write(o_server.server_buffer, buffer_u8, whos_socket);

				for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
					var socket_send_to = o_server.socket_list[| i];	
					network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
				}
			break;
		
			case STATES.CHARGING:
				image_index = 0;
				image_speed = 0;
				buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
				buffer_write(o_server.server_buffer, buffer_u8, network.ACTION_ONE);
				buffer_write(o_server.server_buffer, buffer_u8, whos_socket);
			
				for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
					var socket_send_to = o_server.socket_list[| i];	
					network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
				}
			break;
		
			case STATES.DASH:
				image_index = 0;
				image_speed = 1;
				buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
				buffer_write(o_server.server_buffer, buffer_u8, network.ACTION_TWO);
				buffer_write(o_server.server_buffer, buffer_u8, whos_socket);
				for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
					var socket_send_to = o_server.socket_list[| i];	
					network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
				}
			break;
		}
	} else if (state != STATES.DEFAULT) { 
		buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
		buffer_write(o_server.server_buffer, buffer_u8, network.SET_DEFAULT_STATE);
		buffer_write(o_server.server_buffer, buffer_u8, whos_socket);
		buffer_write(o_server.server_buffer, buffer_u16, constant_face);
		for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
			var socket_send_to = o_server.socket_list[| i];	
			network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
		}
		state = STATES.DEFAULT;	
		
		image_index = 0;
		image_speed = 0;
	}
}