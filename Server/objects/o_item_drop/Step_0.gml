force = lerp(force, 0, 0.5);
if (force >= epsilon) {
	var x_spd = lengthdir_x(force, dir);
	var y_spd = lengthdir_y(force, dir);
	x += x_spd;
	y += y_spd;


	buffer_seek(o_server.server_buffer, buffer_seek_start, 0);
	buffer_write(o_server.server_buffer, buffer_u8, network.ITEM_MOVE);
	buffer_write(o_server.server_buffer, buffer_u16, drop_id);
	buffer_write(o_server.server_buffer, buffer_f16, x);
	buffer_write(o_server.server_buffer, buffer_f16, y);
	buffer_write(o_server.server_buffer, buffer_u8, o_server.tick);
		
	for (var i = 0; i < ds_list_size(o_server.socket_list); i++) {
		var socket_send_to = o_server.socket_list[| i];
		network_send_packet(socket_send_to, o_server.server_buffer, buffer_tell(o_server.server_buffer));
	}
}