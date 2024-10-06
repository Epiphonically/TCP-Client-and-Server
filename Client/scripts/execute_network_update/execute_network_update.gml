function execute_network_update(_type_event, _data_list) {
	
	switch (_type_event) {
		case network.SET_IMAGE:
			var player_to_set = _data_list[0];
			player_to_set.image_index = _data_list[1];
			player_to_set.sprite_index = _data_list[2];
			player_to_set.image_xscale = _data_list[3];
		break;
		
		case network.MOVE: 
			var player_to_move = _data_list[0];
			if (instance_exists(player_to_move)) {
				
				player_to_move.x = _data_list[1];
				player_to_move.y = _data_list[2];
				
				//show_debug_message(string(player_to_move.x) + ", " + string(player_to_move.y));
			}
		break;
		
		case network.ITEM_MOVE:
			var item_to_move = _data_list[0];
			if (instance_exists(item_to_move)) {
				
				item_to_move.x = _data_list[1];
				item_to_move.y = _data_list[2];
				
				
				//show_debug_message(string(player_to_move.x) + ", " + string(player_to_move.y));
			}
		break;
	}	
}