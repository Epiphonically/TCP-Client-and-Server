/* Recall in here coordinates are always relative to the camera */

// THE DOMINANCE SHOULD BE CHAT == PAUSE THEN INV
if (room != r_menu) {
	#region Chat
	if (typing) {
		can_pause = false;
		chat_is_empty = true;
		for (var i = 0; i < string_length(chat_input); i++) {
			if (string_char_at(chat_input, i) != " ") {
				chat_is_empty = false;	
			}
		}
	
		if (back_space_up) {
			can_delete_chat = false;
			alarm[0] = 0;
			chat_input = string_copy(chat_input, 1, string_length(chat_input) - 1);
			keyboard_string = "";
		} else if (back_space) {
			alarm[0] = 20;
			keyboard_string = "";
		}
		
		if (can_delete_chat) {
			can_delete_chat = false;
			alarm[0] = 5;
			chat_input = string_copy(chat_input, 1, string_length(chat_input) - 1);
			keyboard_string = "";
		} else if (string_length(chat_input + keyboard_string) <= max_characters_per_lines) {
			chat_input += keyboard_string;
			keyboard_string = "";
		}
		
		
		if (mouse_wheel_up() && ds_list_size(o_client.chat) - chat_max_lines > 0) {
			chat_portion_shown_index = clamp(chat_portion_shown_index - 1, 0, ds_list_size(o_client.chat) - chat_max_lines);	
		} else if (mouse_wheel_down() && ds_list_size(o_client.chat) - chat_max_lines - 1 > 0) {
			chat_portion_shown_index = clamp(chat_portion_shown_index + 1, 0, ds_list_size(o_client.chat) - chat_max_lines);
		}
		
		
		if (enter) { 
			buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
			buffer_write(o_client.client_buffer, buffer_u8, network.START_TYPING);
			network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
			
			if (!chat_is_empty) {
				buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
				buffer_write(o_client.client_buffer, buffer_u8, network.WRITE_MESSAGE);
				buffer_write(o_client.client_buffer, buffer_string, chat_input);
				network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
			}
				
			keyboard_string = "";
			o_game.chat_input = "";
		}
		
		if (escape || (left_click && !point_in_rectangle(
		device_mouse_x_to_gui(0),
		device_mouse_y_to_gui(0),
		chat_x,
		chat_y,
		chat_x + chat_width,
		chat_y + chat_height))) {
			buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
			buffer_write(o_client.client_buffer, buffer_u8, network.START_TYPING);
			network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
			
		}
	} else {
		can_delete_chat = false;
		if (!paused && !is_crafting && (t || (left_click && point_in_rectangle(
		device_mouse_x_to_gui(0),
		device_mouse_y_to_gui(0),
		chat_x,
		chat_y,
		chat_x + chat_width,
		chat_y + chat_height)))) {
			buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
			buffer_write(o_client.client_buffer, buffer_u8, network.START_TYPING);
			network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
			can_pause = false;
			keyboard_string = "";
		}
	}
	// Draw the chat no matter what 
	draw_set_alpha(0.5);
	draw_rectangle_color(chat_x, chat_y, chat_x + chat_width, chat_y + chat_height, c_black, c_black, c_black, c_black, 0);
	draw_set_alpha(1);
	for (var i = chat_portion_shown_index; i < clamp(chat_portion_shown_index + chat_max_lines, 0, ds_list_size(o_client.chat)); i++) {
		draw_text(chat_x, chat_y + ((i - chat_portion_shown_index) * text_margin), o_client.chat[| i]);	
	}
	draw_text(chat_x, chat_y + (chat_max_lines * text_margin), chat_input);
	
	#endregion
	
	#region Inventory
	var epsilon = 0.1;
	if (is_crafting) {
		
	} else {
		if (inv_open) {
			var goal = (inv_margin * ((INVENTORY_SIZE div INVENTORY_COLUMNS) - 1) + (sprite_get_height(s_inventory_frame)) * ((INVENTORY_SIZE div INVENTORY_COLUMNS) - 1));
			working_with_inventory = false;
			inv_opened_height = lerp(inv_opened_height,
		    goal,
			0.2);
		
		
			for (var i = INVENTORY_COLUMNS; i < INVENTORY_SIZE; i++) {
			
				var x_pos = inventory_x + (inv_margin * ((i % INVENTORY_COLUMNS) + 1)) + (sprite_get_width(s_inventory_frame)) * (i % INVENTORY_COLUMNS);
				var y_pos = inventory_y - (inv_margin * ((i div INVENTORY_COLUMNS))) - (sprite_get_height(s_inventory_frame)) * ((i div INVENTORY_COLUMNS) - 1);
				var frame = 0;
				var ammount_to_put = 0;
				if ((inventory_y - inv_opened_height) > y_pos || inv_opened_height < 1) {
					ammount_to_put = 0;
				} else {
					ammount_to_put = min(1, (inventory_y - inv_opened_height + inv_margin + sprite_get_height(s_inventory_frame))/(y_pos - sprite_get_height(s_inventory_frame)));
				}
				if (ammount_to_put > epsilon &&
				point_in_rectangle(
				device_mouse_x_to_gui(0), 
				device_mouse_y_to_gui(0), 
				x_pos + 4, 
				y_pos + 4, 
				x_pos - 2 + sprite_get_width(s_inventory_frame), 
				y_pos - 2 + sprite_get_height(s_inventory_frame)) && !typing && !paused) { // The + and - 2 are borders
					working_with_inventory = true;
					frame = 1;
					if (left_click) { //Swap whats in mouse with whatever is in inv[i] and stack[i]
						if (inventory[i] == mouse_slot) {
							buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
							buffer_write(o_client.client_buffer, buffer_u8, network.INVENTORY_INCREMENT);
							buffer_write(o_client.client_buffer, buffer_u8, i);
							buffer_write(o_client.client_buffer, buffer_u8, mouse_stack);
							network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
						} else {
							buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
							buffer_write(o_client.client_buffer, buffer_u8, network.INVENTORY_SWAP);
							buffer_write(o_client.client_buffer, buffer_u8, i);
							network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
						}
					} else if (
					(mouse_slot == inventory[i] || inventory[i] == -1) && 
					mouse_slot != -1 &&
					(inventory_stacks[i] < get_max_stack(inventory[i])) && 
					right_click) {
						buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
						buffer_write(o_client.client_buffer, buffer_u8, network.INVENTORY_INCREMENT);
						buffer_write(o_client.client_buffer, buffer_u8, i);
						buffer_write(o_client.client_buffer, buffer_u8, 1);
						network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
					}
				
					if (q) {
						buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
						buffer_write(o_client.client_buffer, buffer_u8, network.PLAYER_DROP_ITEM);
						buffer_write(o_client.client_buffer, buffer_u8, i); // Write the index
						buffer_write(o_client.client_buffer, buffer_u8, 1); // Write the amount to drop
						network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
					}
				}
			
			
			
				draw_sprite_part_ext(s_inventory_frame, 
				frame, 
				0, 
				0, 
				sprite_get_width(s_inventory_frame), 
				sprite_get_height(s_inventory_frame) * ammount_to_put,
				x_pos,
				y_pos,
				1,
				1,
				c_white,
				1);

			
				if (inventory[i] != -1 && ammount_to_put > epsilon) {
					draw_sprite_ext(s_items, inventory[i], x_pos, y_pos, 1, 1, 0, c_white, 1);
					draw_text(x_pos, y_pos, inventory_stacks[i]);
				}
			}
			//hotbar
			for (var i = 0; i < INVENTORY_COLUMNS; i++) {
				var x_pos = inventory_x + (inv_margin * ((i % INVENTORY_COLUMNS) + 1)) + (sprite_get_width(s_inventory_frame)) * (i % INVENTORY_COLUMNS);
				var y_pos = inventory_y - inv_opened_height + (inv_margin * ((i div INVENTORY_COLUMNS) + 1)) + (sprite_get_height(s_inventory_frame)) * (i div INVENTORY_COLUMNS);
				var frame = 0;
				if (abs(inv_opened_height - goal) < epsilon
				&& point_in_rectangle(
				device_mouse_x_to_gui(0), 
				device_mouse_y_to_gui(0), 
				x_pos + 4, 
				y_pos + 4, 
				x_pos - 2 + sprite_get_width(s_inventory_frame), 
				y_pos - 2 + sprite_get_height(s_inventory_frame)) && !typing && !paused) { // The + and - 2 are borders
					working_with_inventory = true;
					frame = 1;
					if (left_click) { //Swap whats in mouse with whatever is in inv[i] and stack[i]
						if (inventory[i] == mouse_slot) {
							buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
							buffer_write(o_client.client_buffer, buffer_u8, network.INVENTORY_INCREMENT);
							buffer_write(o_client.client_buffer, buffer_u8, i);
							buffer_write(o_client.client_buffer, buffer_u8, mouse_stack);
							network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
						} else {
							buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
							buffer_write(o_client.client_buffer, buffer_u8, network.INVENTORY_SWAP);
							buffer_write(o_client.client_buffer, buffer_u8, i);
							network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
						}
					} else if (
					(mouse_slot == inventory[i] || inventory[i] == -1) && 
					mouse_slot != -1 &&
					(inventory_stacks[i] < get_max_stack(inventory[i])) && 
					right_click) {
						buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
						buffer_write(o_client.client_buffer, buffer_u8, network.INVENTORY_INCREMENT);
						buffer_write(o_client.client_buffer, buffer_u8, i);
						buffer_write(o_client.client_buffer, buffer_u8, 1);
						network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
					}
				
					if (q) {
						buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
						buffer_write(o_client.client_buffer, buffer_u8, network.PLAYER_DROP_ITEM);
						buffer_write(o_client.client_buffer, buffer_u8, i); // Write the index
						buffer_write(o_client.client_buffer, buffer_u8, 1); // Write the amount to drop
						network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
					}
				}
			
			
				draw_sprite_ext(s_inventory_frame, frame, x_pos, y_pos, 1, 1, 0, c_white, 1);
			
				if (inventory[i] != -1) {
					draw_sprite_ext(s_items, inventory[i], x_pos, y_pos, 1, 1, 0, c_white, 1);
					draw_text(x_pos, y_pos, inventory_stacks[i]);
				}
			}
			if (mouse_slot != -1) {
				working_with_inventory = true;
				// IF theres something in the mouse u can drop it
				if (!paused && !typing && left_click && !point_in_rectangle(
				device_mouse_x_to_gui(0),
				device_mouse_y_to_gui(0),
				inventory_x + inv_margin,
				inventory_y - inv_opened_height + inv_margin,
				inventory_x + (inv_margin * INVENTORY_COLUMNS) + (sprite_get_width(s_inventory_frame) * INVENTORY_COLUMNS),
				inventory_y + (inv_margin * (INVENTORY_SIZE / INVENTORY_COLUMNS)) + (sprite_get_height(s_inventory_frame) * (INVENTORY_SIZE / INVENTORY_COLUMNS)))) {
					buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
					buffer_write(o_client.client_buffer, buffer_u8, network.PLAYER_DROP_ITEM);
					buffer_write(o_client.client_buffer, buffer_u8, INVENTORY_SIZE); // Write the index
					buffer_write(o_client.client_buffer, buffer_u8, mouse_stack); // Write the amount to drop
					network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
				}
				if (!typing) {
					draw_sprite(s_items, mouse_slot, device_mouse_x_to_gui(0), device_mouse_y_to_gui(0));
					draw_text(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), mouse_stack);
				}
			}
		
			if (e && !paused && !typing) {
		
				inv_open = false;
			}
		} else {
			working_with_inventory = false;
			inv_opened_height = lerp(inv_opened_height,
		    0,
			0.2);
		
			for (var i = INVENTORY_COLUMNS; i < INVENTORY_SIZE; i++) {
				var x_pos = inventory_x + (inv_margin * ((i % INVENTORY_COLUMNS) + 1)) + (sprite_get_width(s_inventory_frame)) * (i % INVENTORY_COLUMNS);
				var y_pos = inventory_y - (inv_margin * ((i div INVENTORY_COLUMNS))) - (sprite_get_height(s_inventory_frame)) * ((i div INVENTORY_COLUMNS) - 1);
				var frame = 0;
				var ammount_to_put = 0;
				if ((inventory_y - inv_opened_height) > y_pos || inv_opened_height < 1) {
					ammount_to_put = 0;
				} else {
					ammount_to_put = min(1, (inventory_y - inv_opened_height + inv_margin + sprite_get_height(s_inventory_frame))/(y_pos - sprite_get_height(s_inventory_frame)));
				}
				if (ammount_to_put > epsilon && 
				point_in_rectangle(
				device_mouse_x_to_gui(0), 
				device_mouse_y_to_gui(0), 
				x_pos + 4, 
				y_pos + 4, 
				x_pos - 2 + sprite_get_width(s_inventory_frame), 
				y_pos - 2 + sprite_get_height(s_inventory_frame)) && !typing && !paused) { // The + and - 2 are borders
					working_with_inventory = true;
					frame = 1;
					if (left_click) { //Swap whats in mouse with whatever is in inv[i] and stack[i]
						if (inventory[i] == mouse_slot) {
							buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
							buffer_write(o_client.client_buffer, buffer_u8, network.INVENTORY_INCREMENT);
							buffer_write(o_client.client_buffer, buffer_u8, i);
							buffer_write(o_client.client_buffer, buffer_u8, mouse_stack);
							network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
						} else {
							buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
							buffer_write(o_client.client_buffer, buffer_u8, network.INVENTORY_SWAP);
							buffer_write(o_client.client_buffer, buffer_u8, i);
							network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
						}
					} else if (
					(mouse_slot == inventory[i] || inventory[i] == -1) && 
					mouse_slot != -1 &&
					(inventory_stacks[i] < get_max_stack(inventory[i])) && 
					right_click) {
						buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
						buffer_write(o_client.client_buffer, buffer_u8, network.INVENTORY_INCREMENT);
						buffer_write(o_client.client_buffer, buffer_u8, i);
						buffer_write(o_client.client_buffer, buffer_u8, 1);
						network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
					}
				
					if (q) {
						buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
						buffer_write(o_client.client_buffer, buffer_u8, network.PLAYER_DROP_ITEM);
						buffer_write(o_client.client_buffer, buffer_u8, i); // Write the index
						buffer_write(o_client.client_buffer, buffer_u8, 1); // Write the amount to drop
						network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
					}
				}
			
			
				draw_sprite_part_ext(s_inventory_frame, 
				frame, 
				0, 
				0, 
				sprite_get_width(s_inventory_frame), 
				sprite_get_height(s_inventory_frame) * ammount_to_put,
				x_pos,
				y_pos,
				1,
				1,
				c_white,
				1);

			
				if (inventory[i] != -1 && ammount_to_put > epsilon) {
					draw_sprite_ext(s_items, inventory[i], x_pos, y_pos, 1, 1, 0, c_white, 1);
					draw_text(x_pos, y_pos, inventory_stacks[i]);
				}
			}
			//hotbar
			for (var i = 0; i < INVENTORY_COLUMNS; i++) {
				var x_pos = inventory_x + (inv_margin * ((i % INVENTORY_COLUMNS) + 1)) + (sprite_get_width(s_inventory_frame)) * (i % INVENTORY_COLUMNS);
				var y_pos = inventory_y - inv_opened_height + (inv_margin * ((i div INVENTORY_COLUMNS) + 1)) + (sprite_get_height(s_inventory_frame)) * (i div INVENTORY_COLUMNS);
				var frame = 0;
				if (abs(inv_opened_height) < epsilon
				&& point_in_rectangle(
				device_mouse_x_to_gui(0), 
				device_mouse_y_to_gui(0), 
				x_pos + 4, 
				y_pos + 4, 
				x_pos - 2 + sprite_get_width(s_inventory_frame), 
				y_pos - 2 + sprite_get_height(s_inventory_frame)) && !typing && !paused) { // The + and - 2 are borders
					working_with_inventory = true;
					frame = 1;
					if (left_click) { //Swap whats in mouse with whatever is in inv[i] and stack[i]
						if (inventory[i] == mouse_slot) {
							buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
							buffer_write(o_client.client_buffer, buffer_u8, network.INVENTORY_INCREMENT);
							buffer_write(o_client.client_buffer, buffer_u8, i);
							buffer_write(o_client.client_buffer, buffer_u8, mouse_stack);
							network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
						} else {
							buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
							buffer_write(o_client.client_buffer, buffer_u8, network.INVENTORY_SWAP);
							buffer_write(o_client.client_buffer, buffer_u8, i);
							network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
						}
					} else if (
					(mouse_slot == inventory[i] || inventory[i] == -1) && 
					mouse_slot != -1 &&
					(inventory_stacks[i] < get_max_stack(inventory[i])) && 
					right_click) {
						buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
						buffer_write(o_client.client_buffer, buffer_u8, network.INVENTORY_INCREMENT);
						buffer_write(o_client.client_buffer, buffer_u8, i);
						buffer_write(o_client.client_buffer, buffer_u8, 1);
						network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
					}
				
					if (q) {
						buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
						buffer_write(o_client.client_buffer, buffer_u8, network.PLAYER_DROP_ITEM);
						buffer_write(o_client.client_buffer, buffer_u8, i); // Write the index
						buffer_write(o_client.client_buffer, buffer_u8, 1); // Write the amount to drop
						network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
					}
				}
			
			
				draw_sprite_ext(s_inventory_frame, frame, x_pos, y_pos, 1, 1, 0, c_white, 1);
			
				if (inventory[i] != -1) {
					draw_sprite_ext(s_items, inventory[i], x_pos, y_pos, 1, 1, 0, c_white, 1);
					draw_text(x_pos, y_pos, inventory_stacks[i]);
				}
			}
			if (mouse_slot != -1) {
				working_with_inventory = true;
				// IF theres something in the mouse u can drop it
				if (!paused && !typing && left_click && !point_in_rectangle(
				device_mouse_x_to_gui(0),
				device_mouse_y_to_gui(0),
				inventory_x + inv_margin,
				inventory_y - inv_opened_height + inv_margin,
				inventory_x + (inv_margin * INVENTORY_COLUMNS) + (sprite_get_width(s_inventory_frame) * INVENTORY_COLUMNS),
				inventory_y + (inv_margin * (INVENTORY_SIZE / INVENTORY_COLUMNS)) + (sprite_get_height(s_inventory_frame) * (INVENTORY_SIZE / INVENTORY_COLUMNS)))) {
					buffer_seek(o_client.client_buffer, buffer_seek_start, 0);
					buffer_write(o_client.client_buffer, buffer_u8, network.PLAYER_DROP_ITEM);
					buffer_write(o_client.client_buffer, buffer_u8, INVENTORY_SIZE); // Write the index
					buffer_write(o_client.client_buffer, buffer_u8, mouse_stack); // Write the amount to drop
					network_send_packet(o_client.client, o_client.client_buffer, buffer_tell(o_client.client_buffer));
				}
				if (!typing) {
					draw_sprite(s_items, mouse_slot, device_mouse_x_to_gui(0), device_mouse_y_to_gui(0));
					draw_text(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), mouse_stack);
				}
			}
		
			if (e && !paused && !typing) {
				inv_open = true;	
			}
		}
	}
	#endregion
	
	#region Pausing
	if (escape && !paused && can_pause && !is_crafting) {
		options_shown[| 0] = "Resume";
		options_shown[| 1] = "Settings";
		options_shown[| 2] = "Quit";
		paused = true;
	} else if (paused) {
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	
		#region Compute Options
		var options_has_changed = false;
	
		if (left_click) {
			extra_space = 0;
			for (var i = 0; i < ds_list_size(options_shown); i++) {
				var draw_x = display_get_gui_width() / 2;
				var draw_y = (display_get_gui_height() / 4 + (i * text_margin)) + extra_space;
				//If our mouse is hovering an option
				if (point_in_rectangle(device_mouse_x_to_gui(0), 
				device_mouse_y_to_gui(0), 
				draw_x, 
				draw_y, 
				draw_x + string_width(options_shown[| i]),
				draw_y + string_height(options_shown[| i]))) {
					switch (options_shown[| i]) {
						case "Resume":
							paused = false;
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
		} else if (escape) {
			paused = false;
		}
	
		if (options_has_changed) {
			var curr_list = option_tree_game;
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
			var draw_x = display_get_gui_width() / 2;
			var draw_y = (display_get_gui_height() / 4 + (i * text_margin)) + extra_space;
			var color = c_white;
			if (point_in_rectangle(device_mouse_x_to_gui(0), 
				device_mouse_y_to_gui(0), 
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
	
	}
	#endregion
}
can_pause = true;
