if (room == r_menu) {
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	
	#region Compute Options
	var options_has_changed = false;
	
	if (left_click) {
		extra_space = 0;
		for (var i = 0; i < ds_list_size(options_shown); i++) {
			var draw_x = room_width / 2;
			var draw_y = (room_height / 4 + (i * text_margin)) + extra_space;
			//If our mouse is hovering an option
			if (point_in_rectangle(mouse_x, 
			mouse_y, 
			draw_x, 
			draw_y, 
			draw_x + string_width(options_shown[| i]),
			draw_y + string_height(options_shown[| i]))) {
				switch (options_shown[| i]) {
					case "Play":
						room = r_lobby;
					break;
					
					case "Settings":
						ds_list_add(options_stack, i);
					break;
					
					case "Quit":
						game_end();
					break;
					
					case "Back":
						ds_list_delete(options_stack, ds_list_size(options_stack) - 1);
					break;
				}
			}
			if (options_shown[| i] == "Sound") {
				extra_space = text_margin;	
			}
		}
		options_has_changed = true;
	}
	
	if (escape && !ds_list_empty(options_stack)) {
		ds_list_delete(options_stack, ds_list_size(options_stack) - 1);
		options_has_changed = true;
	}
	
	if (options_has_changed) {
		var curr_list = option_tree_menu;
		for (var i = 0; i < ds_list_size(options_stack); i++) {
			curr_list = curr_list[| options_stack[| i]].next;
			//Need The Option
			//Need The List of options and lists
		}
	
		ds_list_clear(options_shown);
		for (var i = 0; i < ds_list_size(curr_list); i++) {
			options_shown[| i] = curr_list[| i].option;
		}
		
		options_has_changed = false;
	}
	#endregion 
	
	#region Draw Options
	extra_space = 0;
	for (var i = 0; i < ds_list_size(options_shown); i++) {
		var draw_x = room_width / 2;
		var draw_y = (room_height / 4 + (i * text_margin)) + extra_space;
		var color = c_white;
		if (point_in_rectangle(mouse_x, 
			mouse_y, 
			draw_x, 
			draw_y, 
			draw_x + string_width(options_shown[| i]),
			draw_y + string_height(options_shown[| i]))) {
				color = c_yellow;
			}
		draw_text_color(draw_x, draw_y, options_shown[| i], 
		color, 
		color,  
		color, 
		color, 
		1);	
		if (options_shown[| i] == "Sound") {
			extra_space = text_margin;	
		}
	}
	#endregion
	
} else {
	#region Crafting
	
	if (c) {
		buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
		buffer_write(o_client.client_buffer, buffer_u8, network.OPEN_CRAFTING);
		network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
	}
	var thick = 3;
	for (var i = 0; i < drawing_index; i++) {
		draw_circle(curr_drawing[i].xx, curr_drawing[i].yy, thick / 2, 0);
		draw_line_width(curr_drawing[i].xx, curr_drawing[i].yy, curr_drawing[i + 1].xx, curr_drawing[i + 1].yy, thick);
	}
	#endregion
	if (can_gen_grass) {
		
		vertex_submit(vbuff, pr_trianglelist, sprite_get_texture(s_grass, 0));
		
	}
} 