//
//  Logic+OperationCommand.swift
//  AGI
//
//  Created by Phil Inglis on 2022-04-21.
//

import Foundation

// Operation Codes
extension Logic {
    
    static let operationCommands: [UInt8: OperationCommand] = [
        0x00: OperationCommand(id: 0x00, name: "return", numberOfArguments: 0),
        0x01: OperationCommand(id: 0x01, name: "increment", numberOfArguments: 1),
        0x02: OperationCommand(id: 0x02, name: "decrement", numberOfArguments: 1),
        0x03: OperationCommand(id: 0x03, name: "assign", numberOfArguments: 2),
        0x04: OperationCommand(id: 0x04, name: "assign.v", numberOfArguments: 2),
        0x05: OperationCommand(id: 0x05, name: "add", numberOfArguments: 2),
        0x06: OperationCommand(id: 0x06, name: "add.v", numberOfArguments: 2),
        0x07: OperationCommand(id: 0x07, name: "sub", numberOfArguments: 2),
        0x08: OperationCommand(id: 0x08, name: "sub.v", numberOfArguments: 2),
        0x09: OperationCommand(id: 0x09, name: "lindirect.v", numberOfArguments: 2),
        0x0A: OperationCommand(id: 0x0A, name: "lindirect", numberOfArguments: 2),
        0x0B: OperationCommand(id: 0x0B, name: "lindirect.n", numberOfArguments: 2),
        0x0C: OperationCommand(id: 0x0C, name: "set", numberOfArguments: 1),
        0x0D: OperationCommand(id: 0x0D, name: "reset", numberOfArguments: 1),
        0x0E: OperationCommand(id: 0x0E, name: "toggle", numberOfArguments: 1),
        0x0F: OperationCommand(id: 0x0F, name: "set.v", numberOfArguments: 1),
        0x10: OperationCommand(id: 0x10, name: "reset.v", numberOfArguments: 1),
        0x11: OperationCommand(id: 0x11, name: "toggle.v", numberOfArguments: 1),
        0x12: OperationCommand(id: 0x12, name: "new.room", numberOfArguments: 1),
        0x13: OperationCommand(id: 0x13, name: "new.room.v", numberOfArguments: 1),
        0x14: OperationCommand(id: 0x14, name: "load.logics", numberOfArguments: 1),
        0x15: OperationCommand(id: 0x15, name: "load.logics.v", numberOfArguments: 1),
        0x16: OperationCommand(id: 0x16, name: "call", numberOfArguments: 1),
        0x17: OperationCommand(id: 0x17, name: "call.v", numberOfArguments: 1),
        0x18: OperationCommand(id: 0x18, name: "load.pic", numberOfArguments: 1),
        0x19: OperationCommand(id: 0x19, name: "draw.pic", numberOfArguments: 1),
        0x1A: OperationCommand(id: 0x1A, name: "show.pic", numberOfArguments: 0),
        0x1B: OperationCommand(id: 0x1B, name: "discard.pic", numberOfArguments: 1),
        0x1C: OperationCommand(id: 0x1C, name: "overlay.pic", numberOfArguments: 1),
        0x1D: OperationCommand(id: 0x1D, name: "show.pri.screen", numberOfArguments: 0),
        0x1E: OperationCommand(id: 0x1E, name: "load.view", numberOfArguments: 1),
        0x1F: OperationCommand(id: 0x1F, name: "load.view.v", numberOfArguments: 1),
        0x20: OperationCommand(id: 0x20, name: "discard.view", numberOfArguments: 1),
        0x21: OperationCommand(id: 0x21, name: "animate.obj", numberOfArguments: 1),
        0x22: OperationCommand(id: 0x22, name: "unanimate.all", numberOfArguments: 0),
        0x23: OperationCommand(id: 0x23, name: "draw", numberOfArguments: 1),
        0x24: OperationCommand(id: 0x24, name: "erase", numberOfArguments: 1),
        0x25: OperationCommand(id: 0x25, name: "position", numberOfArguments: 3),
        0x26: OperationCommand(id: 0x26, name: "position.v", numberOfArguments: 3),
        0x27: OperationCommand(id: 0x27, name: "get.posn", numberOfArguments: 3),
        0x28: OperationCommand(id: 0x28, name: "reposition", numberOfArguments: 3),
        0x29: OperationCommand(id: 0x29, name: "set.view", numberOfArguments: 2),
        0x2A: OperationCommand(id: 0x2A, name: "set.view.v", numberOfArguments: 2),
        0x2B: OperationCommand(id: 0x2B, name: "set.loop", numberOfArguments: 2),
        0x2C: OperationCommand(id: 0x2C, name: "set.loop.v", numberOfArguments: 2),
        0x2D: OperationCommand(id: 0x2D, name: "fix.loop", numberOfArguments: 1),
        0x2E: OperationCommand(id: 0x2E, name: "release.loop", numberOfArguments: 1),
        0x2F: OperationCommand(id: 0x2F, name: "set.cel", numberOfArguments: 2),
        0x30: OperationCommand(id: 0x30, name: "set.cel.v", numberOfArguments: 2),
        0x31: OperationCommand(id: 0x31, name: "last.cel", numberOfArguments: 2),
        0x32: OperationCommand(id: 0x32, name: "current.cel", numberOfArguments: 2),
        0x33: OperationCommand(id: 0x33, name: "current.loop", numberOfArguments: 2),
        0x34: OperationCommand(id: 0x34, name: "current.view", numberOfArguments: 2),
        0x35: OperationCommand(id: 0x35, name: "number.of.loops", numberOfArguments: 2),
        0x36: OperationCommand(id: 0x36, name: "set.priority", numberOfArguments: 2),
        0x37: OperationCommand(id: 0x37, name: "set.priority.v", numberOfArguments: 2),
        0x38: OperationCommand(id: 0x38, name: "release.priority", numberOfArguments: 1),
        0x39: OperationCommand(id: 0x39, name: "get.priority.v", numberOfArguments: 2),
        0x3A: OperationCommand(id: 0x3A, name: "stop.update", numberOfArguments: 1),
        0x3B: OperationCommand(id: 0x3B, name: "start.update", numberOfArguments: 1),
        0x3C: OperationCommand(id: 0x3C, name: "force.update", numberOfArguments: 1),
        0x3D: OperationCommand(id: 0x3D, name: "ignore.horizon", numberOfArguments: 1),
        0x3E: OperationCommand(id: 0x3E, name: "observe.horizon", numberOfArguments: 1),
        0x3F: OperationCommand(id: 0x3F, name: "set.horizon", numberOfArguments: 1),
        0x40: OperationCommand(id: 0x40, name: "object.on.water", numberOfArguments: 1),
        0x41: OperationCommand(id: 0x41, name: "object.on.land", numberOfArguments: 1),
        0x42: OperationCommand(id: 0x42, name: "object.on.anything", numberOfArguments: 1),
        0x43: OperationCommand(id: 0x43, name: "ignore.objs", numberOfArguments: 1),
        0x44: OperationCommand(id: 0x44, name: "observe.objs", numberOfArguments: 1),
        0x45: OperationCommand(id: 0x45, name: "distance", numberOfArguments: 3),
        0x46: OperationCommand(id: 0x46, name: "stop.cycling", numberOfArguments: 1),
        0x47: OperationCommand(id: 0x47, name: "start.cycling", numberOfArguments: 1),
        0x48: OperationCommand(id: 0x48, name: "normal.cycle", numberOfArguments: 1),
        0x49: OperationCommand(id: 0x49, name: "end.of.loop", numberOfArguments: 2),
        0x4A: OperationCommand(id: 0x4A, name: "reverse.cycle", numberOfArguments: 1),
        0x4B: OperationCommand(id: 0x4B, name: "reverse.loop", numberOfArguments: 2),
        0x4C: OperationCommand(id: 0x4C, name: "cycle.time", numberOfArguments: 2),
        0x4D: OperationCommand(id: 0x4D, name: "stop.motion", numberOfArguments: 1),
        0x4E: OperationCommand(id: 0x4E, name: "start.motion", numberOfArguments: 1),
        0x4F: OperationCommand(id: 0x4F, name: "step.size", numberOfArguments: 2),
        0x50: OperationCommand(id: 0x50, name: "step.time", numberOfArguments: 2),
        0x51: OperationCommand(id: 0x51, name: "move.obj", numberOfArguments: 5),
        0x52: OperationCommand(id: 0x52, name: "move.obj.v", numberOfArguments: 5),
        0x53: OperationCommand(id: 0x53, name: "follow.ego", numberOfArguments: 3),
        0x54: OperationCommand(id: 0x54, name: "wander", numberOfArguments: 1),
        0x55: OperationCommand(id: 0x55, name: "normal.motion", numberOfArguments: 1),
        0x56: OperationCommand(id: 0x56, name: "set.dir", numberOfArguments: 2),
        0x57: OperationCommand(id: 0x57, name: "get.dir", numberOfArguments: 2),
        0x58: OperationCommand(id: 0x58, name: "ignore.blocks", numberOfArguments: 1),
        0x59: OperationCommand(id: 0x59, name: "observe.blocks", numberOfArguments: 1),
        0x5A: OperationCommand(id: 0x5A, name: "block", numberOfArguments: 4),
        0x5B: OperationCommand(id: 0x5B, name: "unblock", numberOfArguments: 0),
        0x5C: OperationCommand(id: 0x5C, name: "get", numberOfArguments: 1),
        0x5D: OperationCommand(id: 0x5D, name: "get.v", numberOfArguments: 1),
        0x5E: OperationCommand(id: 0x5E, name: "drop", numberOfArguments: 1),
        0x5F: OperationCommand(id: 0x5F, name: "put", numberOfArguments: 2),
        0x60: OperationCommand(id: 0x60, name: "put.v", numberOfArguments: 2),
        0x61: OperationCommand(id: 0x61, name: "get.room.v", numberOfArguments: 2),
        0x62: OperationCommand(id: 0x62, name: "load.sound", numberOfArguments: 1),
        0x63: OperationCommand(id: 0x63, name: "sound", numberOfArguments: 2),
        0x64: OperationCommand(id: 0x64, name: "stop.sound", numberOfArguments: 0),
        0x65: OperationCommand(id: 0x65, name: "print", numberOfArguments: 1),
        0x66: OperationCommand(id: 0x66, name: "print.v", numberOfArguments: 1),
        0x67: OperationCommand(id: 0x67, name: "display", numberOfArguments: 3),
        0x68: OperationCommand(id: 0x68, name: "display.v", numberOfArguments: 3),
        0x69: OperationCommand(id: 0x69, name: "clear.lines", numberOfArguments: 3),
        0x6A: OperationCommand(id: 0x6A, name: "text.screen", numberOfArguments: 0),
        0x6B: OperationCommand(id: 0x6B, name: "graphics", numberOfArguments: 0),
        0x6C: OperationCommand(id: 0x6C, name: "set.cursor.char", numberOfArguments: 1),
        0x6D: OperationCommand(id: 0x6D, name: "set.text.attribute", numberOfArguments: 2),
        0x6E: OperationCommand(id: 0x6E, name: "shake.sceen", numberOfArguments: 1),
        0x6F: OperationCommand(id: 0x6F, name: "configure.sceen", numberOfArguments: 3),
        0x70: OperationCommand(id: 0x70, name: "status.line.on", numberOfArguments: 0),
        0x71: OperationCommand(id: 0x71, name: "status.line.off", numberOfArguments: 0),
        0x72: OperationCommand(id: 0x72, name: "set.string", numberOfArguments: 2),
        0x73: OperationCommand(id: 0x73, name: "get.string", numberOfArguments: 5),
        0x74: OperationCommand(id: 0x74, name: "word.to.string", numberOfArguments: 2),
        0x75: OperationCommand(id: 0x75, name: "parse", numberOfArguments: 1),
        0x76: OperationCommand(id: 0x76, name: "get.num", numberOfArguments: 2),
        0x77: OperationCommand(id: 0x77, name: "prevent.input", numberOfArguments: 0),
        0x78: OperationCommand(id: 0x78, name: "accept.input", numberOfArguments: 0),
        0x79: OperationCommand(id: 0x79, name: "set.key", numberOfArguments: 3),
        0x7A: OperationCommand(id: 0x7A, name: "add.to.pic", numberOfArguments: 7),
        0x7B: OperationCommand(id: 0x7B, name: "add.to.pic.v", numberOfArguments: 7),
        0x7C: OperationCommand(id: 0x7C, name: "status", numberOfArguments: 0),
        0x7D: OperationCommand(id: 0x7D, name: "save.game", numberOfArguments: 0),
        0x7E: OperationCommand(id: 0x7E, name: "restore.game", numberOfArguments: 0),
        0x7F: OperationCommand(id: 0x7F, name: "init.disk", numberOfArguments: 0),
        0x80: OperationCommand(id: 0x80, name: "restart.game", numberOfArguments: 0),
        0x81: OperationCommand(id: 0x81, name: "show.obj", numberOfArguments: 1),
        0x82: OperationCommand(id: 0x82, name: "random", numberOfArguments: 3),
        0x83: OperationCommand(id: 0x83, name: "program.control", numberOfArguments: 0),
        0x84: OperationCommand(id: 0x84, name: "player.control", numberOfArguments: 0),
        0x85: OperationCommand(id: 0x85, name: "obj.status.v", numberOfArguments: 1),
        0x86: OperationCommand(id: 0x86, name: "quit", numberOfArguments: 1),
        0x87: OperationCommand(id: 0x87, name: "show.mem", numberOfArguments: 0),
        0x88: OperationCommand(id: 0x88, name: "pause", numberOfArguments: 0),
        0x89: OperationCommand(id: 0x89, name: "echo.line", numberOfArguments: 0),
        0x8A: OperationCommand(id: 0x8A, name: "cancel.line", numberOfArguments: 0),
        0x8B: OperationCommand(id: 0x8B, name: "init.joy", numberOfArguments: 0),
        0x8C: OperationCommand(id: 0x8C, name: "toggle.monitor", numberOfArguments: 0),
        0x8D: OperationCommand(id: 0x8D, name: "version", numberOfArguments: 0),
        0x8E: OperationCommand(id: 0x8E, name: "script.size", numberOfArguments: 1),
        0x8F: OperationCommand(id: 0x8F, name: "set.game.id", numberOfArguments: 1),
        0x90: OperationCommand(id: 0x90, name: "log", numberOfArguments: 1),
        0x91: OperationCommand(id: 0x91, name: "set.scan.start", numberOfArguments: 0),
        0x92: OperationCommand(id: 0x92, name: "reset.scan.start", numberOfArguments: 0),
        0x93: OperationCommand(id: 0x93, name: "reposition.to", numberOfArguments: 3),
        0x94: OperationCommand(id: 0x94, name: "reposition.to.v", numberOfArguments: 3),
        0x95: OperationCommand(id: 0x95, name: "trace.on", numberOfArguments: 0),
        0x96: OperationCommand(id: 0x96, name: "trace.info", numberOfArguments: 3),
        0x97: OperationCommand(id: 0x97, name: "print.at", numberOfArguments: 4),
        0x98: OperationCommand(id: 0x98, name: "print.at.v", numberOfArguments: 4),
        0x99: OperationCommand(id: 0x99, name: "discard.view.v", numberOfArguments: 1),
        0x9A: OperationCommand(id: 0x9A, name: "clear.text.rect", numberOfArguments: 5),
        0x9B: OperationCommand(id: 0x9B, name: "set.upper.left", numberOfArguments: 2),
        0x9C: OperationCommand(id: 0x9C, name: "set.menu", numberOfArguments: 1),
        0x9D: OperationCommand(id: 0x9D, name: "set.menu.item", numberOfArguments: 2),
        0x9E: OperationCommand(id: 0x9E, name: "submit.menu", numberOfArguments: 0),
        0x9F: OperationCommand(id: 0x9F, name: "enable.item", numberOfArguments: 1),
        0xA0: OperationCommand(id: 0xA0, name: "disable.item", numberOfArguments: 1),
        0xA1: OperationCommand(id: 0xA1, name: "menu.input", numberOfArguments: 0),
        0xA2: OperationCommand(id: 0xA2, name: "show.obj.v", numberOfArguments: 1),
        0xA3: OperationCommand(id: 0xA3, name: "open.dialog", numberOfArguments: 0),
        0xA4: OperationCommand(id: 0xA4, name: "close.dialog", numberOfArguments: 0),
        0xA5: OperationCommand(id: 0xA5, name: "mul.n", numberOfArguments: 2),
        0xA6: OperationCommand(id: 0xA6, name: "mul.v", numberOfArguments: 2),
        0xA7: OperationCommand(id: 0xA7, name: "div.n", numberOfArguments: 2),
        0xA8: OperationCommand(id: 0xA8, name: "div.v", numberOfArguments: 2),
        0xA9: OperationCommand(id: 0xA9, name: "close.window", numberOfArguments: 0),
        0xAA: OperationCommand(id: 0xAA, name: "set.simple", numberOfArguments: 1),
        0xAB: OperationCommand(id: 0xAB, name: "push.script", numberOfArguments: 0),
        0xAC: OperationCommand(id: 0xAC, name: "pop.script", numberOfArguments: 0),
        0xAD: OperationCommand(id: 0xAD, name: "hold.key", numberOfArguments: 0),
        0xAE: OperationCommand(id: 0xAE, name: "set.pri.base", numberOfArguments: 1),
        0xAF: OperationCommand(id: 0xAF, name: "discard.sound", numberOfArguments: 1),
        0xB0: OperationCommand(id: 0xB0, name: "hide.mouse", numberOfArguments: 0),
        0xB1: OperationCommand(id: 0xB1, name: "allow.menu", numberOfArguments: 1),
        0xB2: OperationCommand(id: 0xB2, name: "show.mouse", numberOfArguments: 0),
        0xB3: OperationCommand(id: 0xB3, name: "fence.mouse", numberOfArguments: 4),
        0xB4: OperationCommand(id: 0xB4, name: "mouse.position", numberOfArguments: 2),
        0xB5: OperationCommand(id: 0xB5, name: "release.key", numberOfArguments: 0),
        0xB6: OperationCommand(id: 0xB6, name: "adj.ego.move.to.xy", numberOfArguments: 0),
        0xFE: OperationCommand(id: 0xFE, name: "go.to", numberOfArguments: 2)
    ]
    
    class OperationCommand: Command {
        
        override func copy() -> OperationCommand {
            return OperationCommand(id: id, name: name, numberOfArguments: numberOfArguments)
        }
        
        override func execute(_ drawGraphics: (Int, Int, Int, Int) -> Void) {
            print(debugPrint("   "))
        }
        
        // Debug print
        override func debugPrint(_ prefix: String) -> String {
            return "\(prefix)\(name)->\(data)\n"
        }
    }
}