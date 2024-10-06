#region Controls
w = keyboard_check(ord("W"));
a = keyboard_check(ord("A"));
s = keyboard_check(ord("S"));
d = keyboard_check(ord("D"));
e = keyboard_check_pressed(ord("E"));
q = keyboard_check_pressed(ord("Q"));
t = keyboard_check_pressed(ord("T"));
c = keyboard_check_pressed(ord("C"));
left_click = mouse_check_button_pressed(mb_left);
left_hold = mouse_check_button(mb_left);
left_let_go = mouse_check_button_released(mb_left);
right_click = mouse_check_button_pressed(mb_right);
left_hold = mouse_check_button(mb_left);
right_hold = mouse_check_button(mb_right);
escape = keyboard_check_pressed(vk_escape);
enter = keyboard_check_pressed(vk_enter);
space = keyboard_check_pressed(vk_space);
back_space = keyboard_check_pressed(vk_backspace);
back_space_hold = keyboard_check(vk_backspace);
back_space_up = keyboard_check_released(vk_backspace);
#endregion

