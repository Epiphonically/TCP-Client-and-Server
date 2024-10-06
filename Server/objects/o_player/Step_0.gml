
//show_debug_message(string(state) + " Buffered: " + string(buffered_state));
var item_hovering = instance_place(mouse_x_pos, mouse_y_pos, o_item_drop);
if (item_hovering != noone) {
	buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
	buffer_write(o_server.server_buffer, buffer_u8, network.CONTINUOUS_SENDBACK);
	buffer_write(o_server.server_buffer, buffer_u16, item_hovering.drop_id);
	network_send_packet(whos_socket, o_server.server_buffer, buffer_tell(o_server.server_buffer));
} else {
	buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
	buffer_write(o_server.server_buffer, buffer_u8, network.CONTINUOUS_SENDBACK);
	buffer_write(o_server.server_buffer, buffer_u16, -1);
	network_send_packet(whos_socket, o_server.server_buffer, buffer_tell(o_server.server_buffer));
}

show_debug_message(string(face) + " Buffered: " + string(buffered_face));

switch (state) {
	case STATES.DEFAULT:
	
		if ((constant_face >= 0 && constant_face < 22.5) || (constant_face >= 337.5)) {
			sprite_index = s_player_right;	
			image_xscale = 1;
		} else if (constant_face >= 22.5 && constant_face < 67.5) {
			sprite_index = s_player_top_right;
			image_xscale = 1;
		} else if (constant_face >= 67.5 && constant_face < 112.5) {
			sprite_index = s_player_up;
			image_xscale = 1;
		} else if (constant_face >= 112.5 && constant_face < 157.5) {
			sprite_index = s_player_top_right;
			image_xscale = -1;
		} else if (constant_face >= 157.5 && constant_face < 202.5) {
			sprite_index = s_player_right;
			image_xscale = -1;
		} else if (constant_face >= 202.5 && constant_face < 247.5) {
			sprite_index = s_player_bottom_right;
			image_xscale = -1;
		} else if (constant_face >= 247.5 && constant_face < 292.5) {
			sprite_index = s_player_down;
			image_xscale = 1;
		} else if (constant_face >= 292.5 && constant_face < 337.5) {
			sprite_index = s_player_bottom_right;
			image_xscale = 1;
		}
		
		if ((x_axis != 0 || y_axis != 0) && !typing) {
			image_speed = 1;
			var dir = point_direction(0, 0, x_axis, y_axis);
			var _spd = spd;
			switch (state) {
				case STATES.CHARGING:
					_spd = 0.5 * _spd;
				break;
					
				case STATES.ATTACK:
					_spd = 0.75 * _spd;
				break;
					
					
			}
				
			var x_spd = lengthdir_x(_spd, dir);
			var y_spd = lengthdir_y(_spd, dir);
				
			if (x + x_spd <= room_width && x + x_spd >= 0) {
				x += x_spd;
			}
			if (y + y_spd <= room_height && y + y_spd >= 0) {
				y += y_spd;
			}

				
			buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
			buffer_write(o_server.server_buffer, buffer_u8, network.MOVE); //MOVE
			buffer_write(o_server.server_buffer, buffer_u8, whos_socket); //Who move
			buffer_write(o_server.server_buffer, buffer_f16, x); //x pos
			buffer_write(o_server.server_buffer, buffer_f16, y); //y pos
			buffer_write(o_server.server_buffer, buffer_u8, o_server.tick); //tick
			for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
				var socket_send_to = o_server.socket_list[| i];
				network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
			}
		} else {
			image_speed = 0;
			image_index = 0;
		}
	break;
	
	case STATES.CHARGING:
		charge_score++;
		image_index = 0;
		image_speed = 0;
		sprite_index = s_player_attack_down;
		if ((x_axis != 0 || y_axis != 0) && !typing) {
		
			var dir = point_direction(0, 0, x_axis, y_axis);
			var _spd = spd;
			_spd = 0.5 * _spd;
		
			var x_spd = lengthdir_x(_spd, dir);
			var y_spd = lengthdir_y(_spd, dir);
				
			if (x + x_spd <= room_width && x + x_spd >= 0) {
				x += x_spd;
			}
			if (y + y_spd <= room_height && y + y_spd >= 0) {
				y += y_spd;
			}

				
			buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
			buffer_write(o_server.server_buffer, buffer_u8, network.MOVE); //MOVE
			buffer_write(o_server.server_buffer, buffer_u8, whos_socket); //Who move
			buffer_write(o_server.server_buffer, buffer_f16, x); //x pos
			buffer_write(o_server.server_buffer, buffer_f16, y); //y pos
			buffer_write(o_server.server_buffer, buffer_u8, o_server.tick); //tick
			for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
				var socket_send_to = o_server.socket_list[| i];
				network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
			}
		} else {
			image_speed = 0;
			image_index = 0;
		}
		if (charge_score == 100) {
			charge_score = 0;
			state = STATES.ATTACK;
			can_buffer_attack = false;
			needs_downpress = true;
			image_index = 0;
			image_speed = 1;
			buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
			buffer_write(o_server.server_buffer, buffer_u8, network.ACTION_ONE);
			buffer_write(o_server.server_buffer, buffer_u8, whos_socket);
			buffer_write(o_server.server_buffer, buffer_u16, face);
			buffer_write(o_server.server_buffer, buffer_u8, 1); // ATTACK
			for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
				var socket_send_to = o_server.socket_list[| i];	
				network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
			}	
		}
		
	break;
	
	case STATES.DASH:
	show_debug_message(face);
		sprite_index = s_player_attack_up;
		image_speed = 1;
		var x_spd = (spd * 2) * cos(face * pi / 180);
		var y_spd = -1 * (spd * 2) * sin(face * pi / 180);
		show_debug_message(x_spd);
		show_debug_message(y_spd);
		x += x_spd;
		y += y_spd;
		buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
		buffer_write(o_server.server_buffer, buffer_u8, network.MOVE); //MOVE
		buffer_write(o_server.server_buffer, buffer_u8, whos_socket); //Who move
		buffer_write(o_server.server_buffer, buffer_f16, x); //x pos
		buffer_write(o_server.server_buffer, buffer_f16, y); //y pos
		buffer_write(o_server.server_buffer, buffer_u8, o_server.tick); //tick
		for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
			var socket_send_to = o_server.socket_list[| i];
			network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
		}
	break;
	
	case STATES.CRAFTING: 
		var epsilon = 0.1;
		if (drawing) {
			var put_me = true;
			show_debug_message(array_length(curr_drawing));
			if (drawing_index > MAX_DRAWING) {
				put_me = false;	
			}
			for (var i = 0; i < drawing_index; i++) {
				if (point_distance(mouse_x_pos, mouse_y_pos, curr_drawing[i].xx, curr_drawing[i].yy) < epsilon) {
					put_me = false;
					break;	
				}
			}
			if (put_me) {
				curr_drawing[drawing_index] = new coordinate_vector(mouse_x_pos, mouse_y_pos); 
				buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
				buffer_write(o_server.server_buffer, buffer_u8, network.RECEIVE_DRAWING);
				buffer_write(o_server.server_buffer, buffer_u16, mouse_x_pos);
				buffer_write(o_server.server_buffer, buffer_u16, mouse_y_pos);
				buffer_write(o_server.server_buffer, buffer_u16, drawing_index);
				network_send_packet(whos_socket, o_server.server_buffer, buffer_tell(o_server.server_buffer));
				drawing_index++;
			}
		} else {
 			drawing_index = 0;
			buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
			buffer_write(o_server.server_buffer, buffer_u8, network.RECEIVE_DRAWING);
			buffer_write(o_server.server_buffer, buffer_u16, 0);
			buffer_write(o_server.server_buffer, buffer_u16, 0);
			buffer_write(o_server.server_buffer, buffer_u16, 0);
			network_send_packet(whos_socket, o_server.server_buffer, buffer_tell(o_server.server_buffer));
		}
		if ((x_axis != 0 || y_axis != 0) && !typing) {
			image_speed = 1;
			var dir = point_direction(0, 0, x_axis, y_axis);
			var _spd = spd;
			switch (state) {
				case STATES.CHARGING:
					_spd = 0.5 * _spd;
				break;
					
				case STATES.ATTACK:
					_spd = 0.75 * _spd;
				break;
					
					
			}
				
			var x_spd = lengthdir_x(_spd, dir);
			var y_spd = lengthdir_y(_spd, dir);
				
			if (x + x_spd <= room_width && x + x_spd >= 0) {
				x += x_spd;
			}
			if (y + y_spd <= room_height && y + y_spd >= 0) {
				y += y_spd;
			}

				
			buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
			buffer_write(o_server.server_buffer, buffer_u8, network.MOVE); //MOVE
			buffer_write(o_server.server_buffer, buffer_u8, whos_socket); //Who move
			buffer_write(o_server.server_buffer, buffer_f16, x); //x pos
			buffer_write(o_server.server_buffer, buffer_f16, y); //y pos
			buffer_write(o_server.server_buffer, buffer_u8, o_server.tick); //tick
			for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
				var socket_send_to = o_server.socket_list[| i];
				network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
			}
		} else {
			image_speed = 0;
			image_index = 0;
		}
	break;
}

if (image_speed != 0) {
	buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
	buffer_write(o_server.server_buffer, buffer_u8, network.SET_IMAGE);
	buffer_write(o_server.server_buffer, buffer_u8, whos_socket);
	buffer_write(o_server.server_buffer, buffer_u8, image_index);
	buffer_write(o_server.server_buffer, buffer_u16, sprite_index);
	buffer_write(o_server.server_buffer, buffer_s8, image_xscale);
	buffer_write(o_server.server_buffer, buffer_bool, false);
	buffer_write(o_server.server_buffer, buffer_u8, o_server.tick);
	for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
		var socket_send_to = o_server.socket_list[| i];
		network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
	}
	
} else {
	buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
	buffer_write(o_server.server_buffer, buffer_u8, network.SET_IMAGE);
	buffer_write(o_server.server_buffer, buffer_u8, whos_socket);
	buffer_write(o_server.server_buffer, buffer_u8, 0);
	buffer_write(o_server.server_buffer, buffer_u16, sprite_index);
	buffer_write(o_server.server_buffer, buffer_s8, image_xscale);
	buffer_write(o_server.server_buffer, buffer_bool, true);
	buffer_write(o_server.server_buffer, buffer_u8, o_server.tick);
	for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
		var socket_send_to = o_server.socket_list[| i];
		network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
	}
	
}
