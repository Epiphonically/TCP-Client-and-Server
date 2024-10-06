depth = -(y + (sprite_get_height(sprite_index) / 2));
draw_self();
draw_text_ext_transformed(
x - (sprite_get_width(sprite_index) / 2), 
y - (sprite_get_height(sprite_index) / 2), 
o_client.socket_to_username[? my_socket], 
1, 
100, 
0.25,
0.25,
0);