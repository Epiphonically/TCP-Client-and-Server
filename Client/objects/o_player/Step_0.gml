angle_to_mouse = (point_direction(x, y, mouse_x, mouse_y) + 22.5) % 360;
depth = -(y + (sprite_get_height(sprite_index) / 2));
angle_to_mouse_raw = point_direction(x, y, mouse_x, mouse_y)
#region send_continuous updates
	buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
	buffer_write(o_client.client_buffer, buffer_u8, network.PLAYER_FRAME_INFO);
	buffer_write(o_client.client_buffer, buffer_u16, angle_to_mouse);
	buffer_write(o_client.client_buffer, buffer_u16, mouse_x);
	buffer_write(o_client.client_buffer, buffer_u16, mouse_y);
	buffer_write(o_client.client_buffer, buffer_u8, 0); // NO! WE DONT NEED TO SEND TO EVERYONE
	network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
#endregion
if (o_game.left_let_go && !o_game.paused && !o_game.typing && !o_game.working_with_inventory) {
	buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
	buffer_write(o_client.client_buffer, buffer_u8, network.ACTION_ONE);
	buffer_write(o_client.client_buffer, buffer_u16, angle_to_mouse_raw);
	buffer_write(o_client.client_buffer, buffer_u8, 0);
	network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
} else if (o_game.left_click && !o_game.paused && !o_game.typing && !o_game.working_with_inventory 
		   && !point_in_rectangle(
		   device_mouse_x_to_gui(0),
		   device_mouse_y_to_gui(0),
		   o_game.chat_x,
		   o_game.chat_y,
		   o_game.chat_x + o_game.chat_width,
		   o_game.chat_y + o_game.chat_height)) {
    if (state == STATES.DEFAULT) {
		state = STATES.INTERMISSION;
	}	
	buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
	buffer_write(o_client.client_buffer, buffer_u8, network.ACTION_ONE);
	buffer_write(o_client.client_buffer, buffer_u16, angle_to_mouse_raw);
	buffer_write(o_client.client_buffer, buffer_u8, 1);
	network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
} else if (o_game.right_click  && !o_game.paused && !o_game.typing) {
	if (state == STATES.DEFAULT) {
		state = STATES.INTERMISSION;
	}
	buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
	buffer_write(o_client.client_buffer, buffer_u8, network.ACTION_TWO);
	buffer_write(o_client.client_buffer, buffer_u16, angle_to_mouse_raw);
	network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
} 

switch (state) {
	case STATES.DEFAULT:
		
		
		x_axis = o_game.d - o_game.a;
		y_axis = o_game.s - o_game.w;
		buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
		buffer_write(o_client.client_buffer, buffer_u8, network.MOVE);
		buffer_write(o_client.client_buffer, buffer_s8, x_axis);
		buffer_write(o_client.client_buffer, buffer_s8, y_axis);
		network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));

		if (o_game.space && !o_game.paused && !o_game.typing) {
			var nearest_drop = instance_nearest(x, y, o_item_drop);
			if (nearest_drop != noone) {
				var dist = point_distance(x, y, nearest_drop.x, nearest_drop.y);
				if (dist <= pickup_range) {
					buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
					buffer_write(o_client.client_buffer, buffer_u8, network.PLAYER_PICKUP_ITEM);
					network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
				}
			}
		}

		if (o_game.back_space && !o_game.paused && !o_game.typing) {
	
			buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
			buffer_write(o_client.client_buffer, buffer_u8, network.ITEM_DROP);
			buffer_write(o_client.client_buffer, buffer_u8, random(sprite_get_number(s_items) - 1));
			buffer_write(o_client.client_buffer, buffer_u8, 1);
			network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
	
		}
		
		#region send_continuous updates
		buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
		buffer_write(o_client.client_buffer, buffer_u8, network.PLAYER_FRAME_INFO);
		buffer_write(o_client.client_buffer, buffer_u16, angle_to_mouse);
		buffer_write(o_client.client_buffer, buffer_u8, image_speed);
		buffer_write(o_client.client_buffer, buffer_u16, mouse_x);
		buffer_write(o_client.client_buffer, buffer_u16, mouse_y);
		buffer_write(o_client.client_buffer, buffer_u8, 1); // YES WE NEED TO SEND TO EVERYONE
		network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
  		#endregion
		
	break;
	
	case STATES.CHARGING:
		x_axis = o_game.d - o_game.a;
		y_axis = o_game.s - o_game.w;

		buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
		buffer_write(o_client.client_buffer, buffer_u8, network.MOVE);
		buffer_write(o_client.client_buffer, buffer_s8, x_axis);
		buffer_write(o_client.client_buffer, buffer_s8, y_axis);
		network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
		
	break;
	
	case STATES.ATTACK:
		x_axis = o_game.d - o_game.a;
		y_axis = o_game.s - o_game.w;
		
		buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
		buffer_write(o_client.client_buffer, buffer_u8, network.MOVE);
		buffer_write(o_client.client_buffer, buffer_s8, x_axis);
		buffer_write(o_client.client_buffer, buffer_s8, y_axis);
		network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
		
	break;
	
	case STATES.CRAFTING:
		x_axis = o_game.d - o_game.a;
		y_axis = o_game.s - o_game.w;

		buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
		buffer_write(o_client.client_buffer, buffer_u8, network.MOVE);
		buffer_write(o_client.client_buffer, buffer_s8, x_axis);
		buffer_write(o_client.client_buffer, buffer_s8, y_axis);
		network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
		
	break;
}
