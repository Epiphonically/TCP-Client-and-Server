if (instance_exists(o_player)) {

	x_pos = o_player.x - (width / 2);
	y_pos = o_player.y - (height / 2);
	
	camera_set_view_pos(VIEW, x_pos, y_pos);
}
