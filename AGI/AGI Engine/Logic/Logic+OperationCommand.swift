//
//  Logic+OperationCommand.swift
//  AGI
//
//  Created by Phil Inglis on 2022-04-21.
//

import Foundation

// Command operations
extension Logic {
    
    static let operationCommands: [UInt8: OperationCommand] = [
        0x00: OperationCommand(name: CommandName.operation_return, numberOfArguments: 0),
        0x01: OperationCommand(name: CommandName.operation_increment, numberOfArguments: 1),
        0x02: OperationCommand(name: CommandName.operation_decrement, numberOfArguments: 1),
        0x03: OperationCommand(name: CommandName.operation_assign, numberOfArguments: 2),
        0x04: OperationCommand(name: CommandName.operation_assign_v, numberOfArguments: 2),
        0x05: OperationCommand(name: CommandName.operation_add, numberOfArguments: 2),
        0x06: OperationCommand(name: CommandName.operation_add_v, numberOfArguments: 2),
        0x07: OperationCommand(name: CommandName.operation_sub, numberOfArguments: 2),
        0x08: OperationCommand(name: CommandName.operation_sub_v, numberOfArguments: 2),
        0x09: OperationCommand(name: CommandName.operation_lindirect_v, numberOfArguments: 2),
        0x0A: OperationCommand(name: CommandName.operation_lindirect, numberOfArguments: 2),
        0x0B: OperationCommand(name: CommandName.operation_lindirect_n, numberOfArguments: 2),
        0x0C: OperationCommand(name: CommandName.operation_set, numberOfArguments: 1),
        0x0D: OperationCommand(name: CommandName.operation_reset, numberOfArguments: 1),
        0x0E: OperationCommand(name: CommandName.operation_toggle, numberOfArguments: 1),
        0x0F: OperationCommand(name: CommandName.operation_set_v, numberOfArguments: 1),
        0x10: OperationCommand(name: CommandName.operation_reset_v, numberOfArguments: 1),
        0x11: OperationCommand(name: CommandName.operation_toggle_v, numberOfArguments: 1),
        0x12: OperationCommand(name: CommandName.operation_new_room, numberOfArguments: 1),
        0x13: OperationCommand(name: CommandName.operation_new_room_v, numberOfArguments: 1),
        0x14: OperationCommand(name: CommandName.operation_load_logics, numberOfArguments: 1),
        0x15: OperationCommand(name: CommandName.operation_load_logics_v, numberOfArguments: 1),
        0x16: OperationCommand(name: CommandName.operation_call, numberOfArguments: 1),
        0x17: OperationCommand(name: CommandName.operation_call_v, numberOfArguments: 1),
        0x18: OperationCommand(name: CommandName.operation_load_pic, numberOfArguments: 1),
        0x19: OperationCommand(name: CommandName.operation_draw_pic, numberOfArguments: 1),
        0x1A: OperationCommand(name: CommandName.operation_show_pic, numberOfArguments: 0),
        0x1B: OperationCommand(name: CommandName.operation_discard_pic, numberOfArguments: 1),
        0x1C: OperationCommand(name: CommandName.operation_overlay_pic, numberOfArguments: 1),
        0x1D: OperationCommand(name: CommandName.operation_show_pri_screen, numberOfArguments: 0),
        0x1E: OperationCommand(name: CommandName.operation_load_view, numberOfArguments: 1),
        0x1F: OperationCommand(name: CommandName.operation_load_logics_v, numberOfArguments: 1),
        0x20: OperationCommand(name: CommandName.operation_discard_view, numberOfArguments: 1),
        0x21: OperationCommand(name: CommandName.operation_animate_obj, numberOfArguments: 1),
        0x22: OperationCommand(name: CommandName.operation_unanimate_all, numberOfArguments: 0),
        0x23: OperationCommand(name: CommandName.operation_draw, numberOfArguments: 1),
        0x24: OperationCommand(name: CommandName.operation_erase, numberOfArguments: 1),
        0x25: OperationCommand(name: CommandName.operation_position, numberOfArguments: 3),
        0x26: OperationCommand(name: CommandName.operation_position_v, numberOfArguments: 3),
        0x27: OperationCommand(name: CommandName.operation_get_posn, numberOfArguments: 3),
        0x28: OperationCommand(name: CommandName.operation_reposition, numberOfArguments: 3),
        0x29: OperationCommand(name: CommandName.operation_set_view, numberOfArguments: 2),
        0x2A: OperationCommand(name: CommandName.operation_set_view_v, numberOfArguments: 2),
        0x2B: OperationCommand(name: CommandName.operation_set_loop, numberOfArguments: 2),
        0x2C: OperationCommand(name: CommandName.operation_set_loop_v, numberOfArguments: 2),
        0x2D: OperationCommand(name: CommandName.operation_fix_loop, numberOfArguments: 1),
        0x2E: OperationCommand(name: CommandName.operation_release_loop, numberOfArguments: 1),
        0x2F: OperationCommand(name: CommandName.operation_set_cel, numberOfArguments: 2),
        0x30: OperationCommand(name: CommandName.operation_set_cel_v, numberOfArguments: 2),
        0x31: OperationCommand(name: CommandName.operation_last_cel, numberOfArguments: 2),
        0x32: OperationCommand(name: CommandName.operation_current_cel, numberOfArguments: 2),
        0x33: OperationCommand(name: CommandName.operation_current_loop, numberOfArguments: 2),
        0x34: OperationCommand(name: CommandName.operation_current_view, numberOfArguments: 2),
        0x35: OperationCommand(name: CommandName.operation_number_of_loops, numberOfArguments: 2),
        0x36: OperationCommand(name: CommandName.operation_set_priority, numberOfArguments: 2),
        0x37: OperationCommand(name: CommandName.operation_set_priority_v, numberOfArguments: 2),
        0x38: OperationCommand(name: CommandName.operation_release_priority, numberOfArguments: 1),
        0x39: OperationCommand(name: CommandName.operation_get_priority_v, numberOfArguments: 2),
        0x3A: OperationCommand(name: CommandName.operation_stop_update, numberOfArguments: 1),
        0x3B: OperationCommand(name: CommandName.operation_start_update, numberOfArguments: 1),
        0x3C: OperationCommand(name: CommandName.operation_force_update, numberOfArguments: 1),
        0x3D: OperationCommand(name: CommandName.operation_ignore_horizon, numberOfArguments: 1),
        0x3E: OperationCommand(name: CommandName.operation_observe_horizon, numberOfArguments: 1),
        0x3F: OperationCommand(name: CommandName.operation_set_horizon, numberOfArguments: 1),
        0x40: OperationCommand(name: CommandName.operation_object_on_water, numberOfArguments: 1),
        0x41: OperationCommand(name: CommandName.operation_object_on_land, numberOfArguments: 1),
        0x42: OperationCommand(name: CommandName.operation_object_on_anything, numberOfArguments: 1),
        0x43: OperationCommand(name: CommandName.operation_ignore_objs, numberOfArguments: 1),
        0x44: OperationCommand(name: CommandName.operation_observe_objs, numberOfArguments: 1),
        0x45: OperationCommand(name: CommandName.operation_distance, numberOfArguments: 3),
        0x46: OperationCommand(name: CommandName.operation_stop_cycling, numberOfArguments: 1),
        0x47: OperationCommand(name: CommandName.operation_start_cycling, numberOfArguments: 1),
        0x48: OperationCommand(name: CommandName.operation_normal_cycle, numberOfArguments: 1),
        0x49: OperationCommand(name: CommandName.operation_end_of_loop, numberOfArguments: 2),
        0x4A: OperationCommand(name: CommandName.operation_reverse_cycle, numberOfArguments: 1),
        0x4B: OperationCommand(name: CommandName.operation_reverse_loop, numberOfArguments: 2),
        0x4C: OperationCommand(name: CommandName.operation_cycle_time, numberOfArguments: 2),
        0x4D: OperationCommand(name: CommandName.operation_stop_motion, numberOfArguments: 1),
        0x4E: OperationCommand(name: CommandName.operation_start_motion, numberOfArguments: 1),
        0x4F: OperationCommand(name: CommandName.operation_step_size, numberOfArguments: 2),
        0x50: OperationCommand(name: CommandName.operation_step_time, numberOfArguments: 2),
        0x51: OperationCommand(name: CommandName.operation_move_obj, numberOfArguments: 5),
        0x52: OperationCommand(name: CommandName.operation_move_obj_v, numberOfArguments: 5),
        0x53: OperationCommand(name: CommandName.operation_follow_ego, numberOfArguments: 3),
        0x54: OperationCommand(name: CommandName.operation_wander, numberOfArguments: 1),
        0x55: OperationCommand(name: CommandName.operation_normal_motion, numberOfArguments: 1),
        0x56: OperationCommand(name: CommandName.operation_set_dir, numberOfArguments: 2),
        0x57: OperationCommand(name: CommandName.operation_get_dir, numberOfArguments: 2),
        0x58: OperationCommand(name: CommandName.operation_ignore_blocks, numberOfArguments: 1),
        0x59: OperationCommand(name: CommandName.operation_observe_blocks, numberOfArguments: 1),
        0x5A: OperationCommand(name: CommandName.operation_block, numberOfArguments: 4),
        0x5B: OperationCommand(name: CommandName.operation_unblock, numberOfArguments: 0),
        0x5C: OperationCommand(name: CommandName.operation_get, numberOfArguments: 1),
        0x5D: OperationCommand(name: CommandName.operation_get_v, numberOfArguments: 1),
        0x5E: OperationCommand(name: CommandName.operation_drop, numberOfArguments: 1),
        0x5F: OperationCommand(name: CommandName.operation_put, numberOfArguments: 2),
        0x60: OperationCommand(name: CommandName.operation_put_v, numberOfArguments: 2),
        0x61: OperationCommand(name: CommandName.operation_get_room_v, numberOfArguments: 2),
        0x62: OperationCommand(name: CommandName.operation_load_sound, numberOfArguments: 1),
        0x63: OperationCommand(name: CommandName.operation_sound, numberOfArguments: 2),
        0x64: OperationCommand(name: CommandName.operation_stop_sound, numberOfArguments: 0),
        0x65: OperationCommand(name: CommandName.operation_print, numberOfArguments: 1),
        0x66: OperationCommand(name: CommandName.operation_print_v, numberOfArguments: 1),
        0x67: OperationCommand(name: CommandName.operation_display, numberOfArguments: 3),
        0x68: OperationCommand(name: CommandName.operation_display_v, numberOfArguments: 3),
        0x69: OperationCommand(name: CommandName.operation_clear_lines, numberOfArguments: 3),
        0x6A: OperationCommand(name: CommandName.operation_text_screen, numberOfArguments: 0),
        0x6B: OperationCommand(name: CommandName.operation_graphics, numberOfArguments: 0),
        0x6C: OperationCommand(name: CommandName.operation_set_cursor_char, numberOfArguments: 1),
        0x6D: OperationCommand(name: CommandName.operation_set_text_attribute, numberOfArguments: 2),
        0x6E: OperationCommand(name: CommandName.operation_shake_sceen, numberOfArguments: 1),
        0x6F: OperationCommand(name: CommandName.operation_configure_sceen, numberOfArguments: 3),
        0x70: OperationCommand(name: CommandName.operation_status_line_on, numberOfArguments: 0),
        0x71: OperationCommand(name: CommandName.operation_status_line_off, numberOfArguments: 0),
        0x72: OperationCommand(name: CommandName.operation_set_string, numberOfArguments: 2),
        0x73: OperationCommand(name: CommandName.operation_get_string, numberOfArguments: 5),
        0x74: OperationCommand(name: CommandName.operation_word_to_string, numberOfArguments: 2),
        0x75: OperationCommand(name: CommandName.operation_parse, numberOfArguments: 1),
        0x76: OperationCommand(name: CommandName.operation_get_num, numberOfArguments: 2),
        0x77: OperationCommand(name: CommandName.operation_prevent_input, numberOfArguments: 0),
        0x78: OperationCommand(name: CommandName.operation_accept_input, numberOfArguments: 0),
        0x79: OperationCommand(name: CommandName.operation_set_key, numberOfArguments: 3),
        0x7A: OperationCommand(name: CommandName.operation_add_to_pic, numberOfArguments: 7),
        0x7B: OperationCommand(name: CommandName.operation_add_to_pic_v, numberOfArguments: 7),
        0x7C: OperationCommand(name: CommandName.operation_status, numberOfArguments: 0),
        0x7D: OperationCommand(name: CommandName.operation_save_game, numberOfArguments: 0),
        0x7E: OperationCommand(name: CommandName.operation_restore_game, numberOfArguments: 0),
        0x7F: OperationCommand(name: CommandName.operation_init_disk, numberOfArguments: 0),
        0x80: OperationCommand(name: CommandName.operation_restart_game, numberOfArguments: 0),
        0x81: OperationCommand(name: CommandName.operation_show_obj, numberOfArguments: 1),
        0x82: OperationCommand(name: CommandName.operation_random, numberOfArguments: 3),
        0x83: OperationCommand(name: CommandName.operation_program_control, numberOfArguments: 0),
        0x84: OperationCommand(name: CommandName.operation_player_control, numberOfArguments: 0),
        0x85: OperationCommand(name: CommandName.operation_obj_status_v, numberOfArguments: 1),
        0x86: OperationCommand(name: CommandName.operation_quit, numberOfArguments: 1),
        0x87: OperationCommand(name: CommandName.operation_show_mem, numberOfArguments: 0),
        0x88: OperationCommand(name: CommandName.operation_pause, numberOfArguments: 0),
        0x89: OperationCommand(name: CommandName.operation_echo_line, numberOfArguments: 0),
        0x8A: OperationCommand(name: CommandName.operation_cancel_line, numberOfArguments: 0),
        0x8B: OperationCommand(name: CommandName.operation_init_joy, numberOfArguments: 0),
        0x8C: OperationCommand(name: CommandName.operation_toggle_monitor, numberOfArguments: 0),
        0x8D: OperationCommand(name: CommandName.operation_version, numberOfArguments: 0),
        0x8E: OperationCommand(name: CommandName.operation_script_size, numberOfArguments: 1),
        0x8F: OperationCommand(name: CommandName.operation_set_game_id, numberOfArguments: 1),
        0x90: OperationCommand(name: CommandName.operation_log, numberOfArguments: 1),
        0x91: OperationCommand(name: CommandName.operation_set_scan_start, numberOfArguments: 0),
        0x92: OperationCommand(name: CommandName.operation_reset_scan_start, numberOfArguments: 0),
        0x93: OperationCommand(name: CommandName.operation_reposition_to, numberOfArguments: 3),
        0x94: OperationCommand(name: CommandName.operation_reposition_to_v, numberOfArguments: 3),
        0x95: OperationCommand(name: CommandName.operation_trace_on, numberOfArguments: 0),
        0x96: OperationCommand(name: CommandName.operation_trace_info, numberOfArguments: 3),
        0x97: OperationCommand(name: CommandName.operation_print_at, numberOfArguments: 4),
        0x98: OperationCommand(name: CommandName.operation_print_at_v, numberOfArguments: 4),
        0x99: OperationCommand(name: CommandName.operation_discard_view_v, numberOfArguments: 1),
        0x9A: OperationCommand(name: CommandName.operation_clear_text_rect, numberOfArguments: 5),
        0x9B: OperationCommand(name: CommandName.operation_set_upper_left, numberOfArguments: 2),
        0x9C: OperationCommand(name: CommandName.operation_set_menu, numberOfArguments: 1),
        0x9D: OperationCommand(name: CommandName.operation_set_menu_item, numberOfArguments: 2),
        0x9E: OperationCommand(name: CommandName.operation_submit_menu, numberOfArguments: 0),
        0x9F: OperationCommand(name: CommandName.operation_enable_item, numberOfArguments: 1),
        0xA0: OperationCommand(name: CommandName.operation_disable_item, numberOfArguments: 1),
        0xA1: OperationCommand(name: CommandName.operation_menu_input, numberOfArguments: 0),
        0xA2: OperationCommand(name: CommandName.operation_show_obj_v, numberOfArguments: 1),
        0xA3: OperationCommand(name: CommandName.operation_close_dialog, numberOfArguments: 0),
        0xA5: OperationCommand(name: CommandName.operation_mul_n, numberOfArguments: 2),
        0xA6: OperationCommand(name: CommandName.operation_mul_v, numberOfArguments: 2),
        0xA7: OperationCommand(name: CommandName.operation_div_n, numberOfArguments: 2),
        0xA8: OperationCommand(name: CommandName.operation_div_v, numberOfArguments: 2),
        0xA9: OperationCommand(name: CommandName.operation_close_window, numberOfArguments: 0),
        0xAA: OperationCommand(name: CommandName.operation_set_simple, numberOfArguments: 1),
        0xAB: OperationCommand(name: CommandName.operation_push_script, numberOfArguments: 0),
        0xAC: OperationCommand(name: CommandName.operation_pop_script, numberOfArguments: 0),
        0xAD: OperationCommand(name: CommandName.operation_hold_key, numberOfArguments: 0),
        0xAE: OperationCommand(name: CommandName.operation_set_pri_base, numberOfArguments: 1),
        0xAF: OperationCommand(name: CommandName.operation_discard_sound, numberOfArguments: 1),
        0xB0: OperationCommand(name: CommandName.operation_hide_mouse, numberOfArguments: 0),
        0xB1: OperationCommand(name: CommandName.operation_allow_menu, numberOfArguments: 1),
        0xB2: OperationCommand(name: CommandName.operation_show_mouse, numberOfArguments: 0),
        0xB3: OperationCommand(name: CommandName.operation_fence_mouse, numberOfArguments: 4),
        0xB4: OperationCommand(name: CommandName.operation_mouse_position, numberOfArguments: 2),
        0xB5: OperationCommand(name: CommandName.operation_release_key, numberOfArguments: 0),
        0xB6: OperationCommand(name: CommandName.operation_adj_ego_move_to_xy, numberOfArguments: 0),
        0xFE: OperationCommand(name: CommandName.operation_go_to, numberOfArguments: 2)
    ]
    
    class OperationCommand: Command {
        
        override func copy() -> OperationCommand {
            return OperationCommand(name: name, numberOfArguments: numberOfArguments)
        }
        
        override func process(_ drawGraphics: (Int?, ScreenObject?, Bool) -> Void) -> ProcessingChoice {
            
            var supportedOperation = true
            
            switch name {
            
            case CommandName.operation_return:
                print(debugPrint(""))
                return .stopProcessing
            
            case CommandName.operation_increment:
                guard dataIsValid(bytes: 1) else { break }
                
                let variableNum = Int(data[0])
                var value = Logic.variables[variableNum]
                
                if value < 0xF0 {
                    value += 1
                    Logic.variables[variableNum] = value
                }
                
            case CommandName.operation_decrement:
                guard dataIsValid(bytes: 1) else { break }
                
                let variableNum = Int(data[0])
                var value = Logic.variables[variableNum]
                
                if value > 0 {
                    value -= 1
                    Logic.variables[variableNum] = value
                }
            
            case CommandName.operation_assign:
                guard dataIsValid(bytes: 2) else { break }
                
                let variableNum = Int(data[0])
                let value = data[1]
                Logic.variables[variableNum] = value
                
            case CommandName.operation_assign_v:
                guard dataIsValid(bytes: 2) else { break }
                
                let variableNum = Int(data[0])
                let valueNum = Int(data[1])
                Logic.variables[variableNum] = Logic.variables[valueNum]
                
            case CommandName.operation_set:
                guard dataIsValid(bytes: 1) else { break }
                
                let flagNum = Int(data[0])
                Logic.flags[flagNum] = true
                
            case CommandName.operation_reset:
                guard dataIsValid(bytes: 1) else { break }
                
                let flagNum = Int(data[0])
                Logic.flags[flagNum] = false
                
            case CommandName.operation_toggle:
                guard dataIsValid(bytes: 1) else { break }
                
                let flagNum = Int(data[0])
                Logic.flags[flagNum] = !Logic.flags[flagNum]
                
            case CommandName.operation_set_v:
                guard dataIsValid(bytes: 1) else { break }
                
                let variableNum = Int(data[0])
                Logic.variables[variableNum] = 1
                
            case CommandName.operation_reset_v:
                guard dataIsValid(bytes: 1) else { break }
                
                let variableNum = Int(data[0])
                Logic.variables[variableNum] = 0
                
            case CommandName.operation_toggle_v:
                guard dataIsValid(bytes: 1) else { break }
                
                let variableNum = Int(data[0])
                
                if Logic.variables[variableNum] == 0 {
                    Logic.variables[variableNum] = 1
                } else {
                    Logic.variables[variableNum] = 0
                }
                
            // MARK: Picture
            case CommandName.operation_draw_pic:
                guard dataIsValid(bytes: 1) else { break }
                
                let variableNum = Int(data[0])
                let pictureId = Int(Logic.variables[variableNum])
                drawGraphics(pictureId, nil, false)
                
            case CommandName.operation_show_pic:
                drawGraphics(nil, nil, true)
                
            // MARK: ScreenObject
            case CommandName.operation_set_view:
                guard dataIsValid(bytes: 2) else { break }
                
                let screenObjectNum = Int(data[0])
                let viewId = data[1]
                
                let screenObject = Logic.screenObjects[screenObjectNum]
                if let view = Logic.views[Int(viewId)] {
                    screenObject.setView(view)
                }
                
            case CommandName.operation_set_loop:
                guard dataIsValid(bytes: 2) else { break }
                
                let screenObjectNum = Int(data[0])
                let loopNum = data[1]
                
                let screenObject = Logic.screenObjects[screenObjectNum]
                screenObject.currentLoopNum = Int(loopNum)
                
            case CommandName.operation_position:
                guard dataIsValid(bytes: 3) else { break }
                
                let screenObjectNum = Int(data[0])
                let posX = Int(data[1])
                let posY = Int(data[2])
                
                let screenObject = Logic.screenObjects[screenObjectNum]
                screenObject.posX = posX
                screenObject.posY = posY
                screenObject.prevPosX = posX
                screenObject.prevPosY = posY
                
            case CommandName.operation_draw:
                guard dataIsValid(bytes: 1) else { break }
                
                let screenObjectNum = Int(data[0])
                let screenObject = Logic.screenObjects[screenObjectNum]
                
                drawGraphics(nil, screenObject, false)
                
            case CommandName.operation_move_obj:
                guard dataIsValid(bytes: 5) else { break }
                
                let screenObjectNum = Int(data[0])
                let screenObject = Logic.screenObjects[screenObjectNum]
                
                screenObject.moveTo(
                    moveX: Int(data[1]),
                    moveY: Int(data[2]),
                    stepSize: Int(data[3]),
                    moveFlags: Int(data[4])
                )
                
            case CommandName.operation_step_size:
                guard dataIsValid(bytes: 2) else { break }
                
                let screenObjectNum = Int(data[0])
                let variableNum = Int(data[1])
                
                //Logic.screenObjects[screenObjectNum].stepSize = Int(Logic.variables[variableNum])
              
            // MARK: Unused
            // These operations are using to save memory / time but not needed on modern systems
            case CommandName.operation_load_pic,
                 CommandName.operation_discard_pic,
                 CommandName.operation_load_view,
                 CommandName.operation_discard_view,
                 CommandName.operation_load_sound,
                 CommandName.operation_discard_sound:
                break
                
            default:
                supportedOperation = false
            }
            
            print("\(supportedOperation ? "Process:" : "Unsupported:") \(name) -> \(data)")
            
            return .continueProcessing
        }
        
        // Debug print
        override func debugPrint(_ prefix: String) -> String {
            return "\(prefix)\(name)->\(data)\n"
        }
    }
}
