//
//  Logic+Command_swift
//  AGI
//
//  Created by Phil Inglis on 2022-04-06_
//

import Foundation

enum ProcessingChoice {
    case continueProcessing
    case stopProcessing
}

protocol LogicPrintProtocol {
    func process(_ drawGraphics: (Int?, ScreenObject?, Bool) -> Void) -> ProcessingChoice
    func debugPrint(_ prefix: String) -> String
}

extension Logic {
    
    enum CommandName: String {
        
        // Control Commands
        case control_if = "if"
        case control_else = "else"
        case control_not = "not"
        case control_or = "or"
        
        // Condition Commands
        case condition_unknown = "unknown"
        case condition_equal = "equal"
        case condition_equal_v = "equal_v"
        case condition_less = "less"
        case condition_less_v = "less_v"
        case condition_greater = "greater"
        case condition_greater_v = "greater_v"
        case condition_isset = "isset"
        case condition_isset_v = "isset_v"
        case condition_has = "has"
        case condition_obj_in_room = "obj_in_room"
        case condition_position = "condition_position"
        case condition_controller = "controller"
        case condition_have_key = "have_key"
        case condition_said = "said"
        case condition_compare_strings = "compare_strings"
        case condition_obj_in_box = "obj_in_box"
        case condition_center_position = "center_position"
        case condition_right_position = "right_position"
        case condition_in_motion_using_mouse = "in_motion_using_mouse"
        
        case operation_return = "return"
        case operation_increment = "increment"
        case operation_decrement = "decrement"
        case operation_assign = "assign"
        case operation_assign_v = "assign_v"
        case operation_add = "add"
        case operation_add_v = "add_v"
        case operation_sub = "sub"
        case operation_sub_v = "sub_v"
        case operation_lindirect_v = "lindirect_v"
        case operation_lindirect = "lindirect"
        case operation_lindirect_n = "lindirect_n"
        case operation_set = "set"
        case operation_reset = "reset"
        case operation_toggle = "toggle"
        case operation_set_v = "set_v"
        case operation_reset_v = "reset_v"
        case operation_toggle_v = "toggle_v"
        case operation_new_room = "new_room"
        case operation_new_room_v = "new_room_v"
        case operation_load_logics = "load_logics"
        case operation_load_logics_v = "load_logics_v"
        case operation_call = "call"
        case operation_call_v = "call_v"
        case operation_load_pic = "load_pic"
        case operation_draw_pic = "draw_pic"
        case operation_show_pic = "show_pic"
        case operation_discard_pic = "discard_pic"
        case operation_overlay_pic = "overlay_pic"
        case operation_show_pri_screen = "show_pri_screen"
        case operation_load_view = "load_view"
        case operation_load_view_v = "load_view_v"
        case operation_discard_view = "discard_view"
        case operation_animate_obj = "animate_obj"
        case operation_unanimate_all = "unanimate_all"
        case operation_draw = "draw"
        case operation_erase = "erase"
        case operation_position = "position"
        case operation_position_v = "position_v"
        case operation_get_posn = "get_posn"
        case operation_reposition = "reposition"
        case operation_set_view = "set_view"
        case operation_set_view_v = "set_view_v"
        case operation_set_loop = "set_loop"
        case operation_set_loop_v = "set_loop_v"
        case operation_fix_loop = "fix_loop"
        case operation_release_loop = "release_loop"
        case operation_set_cel = "set_cel"
        case operation_set_cel_v = "set_cel_v"
        case operation_last_cel = "last_cel"
        case operation_current_cel = "current_cel"
        case operation_current_loop = "current_loop"
        case operation_current_view = "current_view"
        case operation_number_of_loops = "number_of_loops"
        case operation_set_priority = "set_priority"
        case operation_set_priority_v = "set_priority_v"
        case operation_release_priority = "release_priority"
        case operation_get_priority_v = "get_priority_v"
        case operation_stop_update = "stop_update"
        case operation_start_update = "start_update"
        case operation_force_update = "force_update"
        case operation_ignore_horizon = "ignore_horizon"
        case operation_observe_horizon = "observe_horizon"
        case operation_set_horizon = "set_horizon"
        case operation_object_on_water = "object_on_water"
        case operation_object_on_land = "object_on_land"
        case operation_object_on_anything = "object_on_anything"
        case operation_ignore_objs = "ignore_objs"
        case operation_observe_objs = "observe_objs"
        case operation_distance = "distance"
        case operation_stop_cycling = "stop_cycling"
        case operation_start_cycling = "start_cycling"
        case operation_normal_cycle = "normal_cycle"
        case operation_end_of_loop = "end_of_loop"
        case operation_reverse_cycle = "reverse_cycle"
        case operation_reverse_loop = "reverse_loop"
        case operation_cycle_time = "cycle_time"
        case operation_stop_motion = "stop_motion"
        case operation_start_motion = "start_motion"
        case operation_step_size = "step_size"
        case operation_step_time = "step_time"
        case operation_move_obj = "move_obj"
        case operation_move_obj_v = "move_obj_v"
        case operation_follow_ego = "follow_ego"
        case operation_wander = "wander"
        case operation_normal_motion = "normal_motion"
        case operation_set_dir = "set_dir"
        case operation_get_dir = "get_dir"
        case operation_ignore_blocks = "ignore_blocks"
        case operation_observe_blocks = "observe_blocks"
        case operation_block = "block"
        case operation_unblock = "unblock"
        case operation_get = "get"
        case operation_get_v = "get_v"
        case operation_drop = "drop"
        case operation_put = "put"
        case operation_put_v = "put_v"
        case operation_get_room_v = "get_room_v"
        case operation_load_sound = "load_sound"
        case operation_sound = "sound"
        case operation_stop_sound = "stop_sound"
        case operation_print = "print"
        case operation_print_v = "print_v"
        case operation_display = "display"
        case operation_display_v = "display_v"
        case operation_clear_lines = "clear_lines"
        case operation_text_screen = "text_screen"
        case operation_graphics = "graphics"
        case operation_set_cursor_char = "set_cursor_char"
        case operation_set_text_attribute = "set_text_attribute"
        case operation_shake_sceen = "shake_sceen"
        case operation_configure_sceen = "configure_sceen"
        case operation_status_line_on = "status_line_on"
        case operation_status_line_off = "status_line_off"
        case operation_set_string = "set_string"
        case operation_get_string = "get_string"
        case operation_word_to_string = "word_to_string"
        case operation_parse = "parse"
        case operation_get_num = "get_num"
        case operation_prevent_input = "prevent_input"
        case operation_accept_input = "accept_input"
        case operation_set_key = "set_key"
        case operation_add_to_pic = "add_to_pic"
        case operation_add_to_pic_v = "add_to_pic_v"
        case operation_status = "status"
        case operation_save_game = "save_game"
        case operation_restore_game = "restore_game"
        case operation_init_disk = "init_disk"
        case operation_restart_game = "restart_game"
        case operation_show_obj = "show_obj"
        case operation_random = "random"
        case operation_program_control = "program_control"
        case operation_player_control = "player_control"
        case operation_obj_status_v = "obj_status_v"
        case operation_quit = "quit"
        case operation_show_mem = "show_mem"
        case operation_pause = "pause"
        case operation_echo_line = "echo_line"
        case operation_cancel_line = "cancel_line"
        case operation_init_joy = "init_joy"
        case operation_toggle_monitor = "toggle_monitor"
        case operation_version = "version"
        case operation_script_size = "script_size"
        case operation_set_game_id = "set_game_id"
        case operation_log = "log"
        case operation_set_scan_start = "set_scan_start"
        case operation_reset_scan_start = "reset_scan_start"
        case operation_reposition_to = "reposition_to"
        case operation_reposition_to_v = "reposition_to_v"
        case operation_trace_on = "trace_on"
        case operation_trace_info = "trace_info"
        case operation_print_at = "print_at"
        case operation_print_at_v = "print_at_v"
        case operation_discard_view_v = "discard_view_v"
        case operation_clear_text_rect = "clear_text_rect"
        case operation_set_upper_left = "set_upper_left"
        case operation_set_menu = "set_menu"
        case operation_set_menu_item = "set_menu_item"
        case operation_submit_menu = "submit_menu"
        case operation_enable_item = "enable_item"
        case operation_disable_item = "disable_item"
        case operation_menu_input = "menu_input"
        case operation_show_obj_v = "show_obj_v"
        case operation_open_dialog = "open_dialog"
        case operation_close_dialog = "close_dialog"
        case operation_mul_n = "mul_n"
        case operation_mul_v = "mul_v"
        case operation_div_n = "div_n"
        case operation_div_v = "div_v"
        case operation_close_window = "close_window"
        case operation_set_simple = "set_simple"
        case operation_push_script = "push_script"
        case operation_pop_script = "pop_script"
        case operation_hold_key = "hold_key"
        case operation_set_pri_base = "set_pri_base"
        case operation_discard_sound = "discard_sound"
        case operation_hide_mouse = "hide_mouse"
        case operation_allow_menu = "allow_menu"
        case operation_show_mouse = "show_mouse"
        case operation_fence_mouse = "fence_mouse"
        case operation_mouse_position = "mouse_position"
        case operation_release_key = "release_key"
        case operation_adj_ego_move_to_xy = "adj_ego_move_to_xy"
        case operation_go_to = "go_to"
    }
    
    class Command: LogicPrintProtocol {
        
        let name: CommandName
        let numberOfArguments: Int
        var data = [UInt8]()
        
        init(name: CommandName, numberOfArguments: Int) {
            self.name = name
            self.numberOfArguments = numberOfArguments
        }
        
        func copy() -> Command {
            return Command(name: name, numberOfArguments: numberOfArguments)
        }
        
        func dataIsValid(bytes: Int) -> Bool {
            
            for index in 0 ..< bytes {
                if !(0 ... 255).contains(data[index]) {
                    return false
                }
            }
            
            return true
        }
        
        func process(_ drawGraphics: (Int?, ScreenObject?, Bool) -> Void) -> ProcessingChoice {
            return .continueProcessing
        }
        
        // Debug print
        func debugPrint(_ prefix: String) -> String {
            return "\(prefix)\(name)->\(data)\n"
        }
    }
}
