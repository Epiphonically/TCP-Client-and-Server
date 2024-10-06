//Have a loop for each type of continuous packet 
for (var i = 0; i < ds_list_size(socket_list); i++) {
	var socket = socket_list[| i];
	if (ds_map_exists(socket_to_network_queues, socket)) {
		var network_queue = socket_to_network_queues[? socket];
		if (!is_undefined(network_queue) && !ds_list_empty(network_queue)) {
			var curr_tick = network_queue[| 0].tick;
			var curr_task = network_queue[| 0].type_event;
			for (var j = 0; j < ds_list_size(network_queue); j++) {
				if (network_queue[| j].tick == curr_tick) {
					execute_network_update(network_queue[| j].type_event, network_queue[| j].data_list);
					ds_list_delete(network_queue, j);
				} else if (network_queue[| j].type_event == curr_task) {
					break;
				}
			}
		}
	}
}

for (var i = 0; i < ds_list_size(socket_list); i++) {
	var socket = socket_list[| i];
	if (ds_map_exists(socket_to_network_queues_frame, socket)) {
		var network_queue = socket_to_network_queues_frame[? socket];
		if (!is_undefined(network_queue) && !ds_list_empty(network_queue)) {
			var curr_tick = network_queue[| 0].tick;
			var curr_task = network_queue[| 0].type_event;
			for (var j = 0; j < ds_list_size(network_queue); j++) {
				if (network_queue[| j].tick == curr_tick) {
					execute_network_update(network_queue[| j].type_event, network_queue[| j].data_list);
					ds_list_delete(network_queue, j);
				} else if (network_queue[| j].type_event == curr_task) {
					break;
				}
			}
		}
	}
}

var enviornment_queue = socket_to_network_queues[? -1];
if (!ds_list_empty(enviornment_queue)) {
	var curr_tick = enviornment_queue[| 0].tick;
	for (var j = 0; j < ds_list_size(enviornment_queue); j++) {
		if (enviornment_queue[| j].tick == curr_tick) {
			execute_network_update(enviornment_queue[| j].type_event, enviornment_queue[| j].data_list);
			ds_list_delete(enviornment_queue, j);
		} else {
			break;
		}
	}
}