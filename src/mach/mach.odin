package mach

import "core:c"

foreign import sys "system:System.B"

Mach_Port :: distinct u32
Task :: Mach_Port
Kern_Return :: distinct c.int
Pid :: c.int

KERN_SUCCESS :: 0
KERN_NOT_IN_SET :: 138

@(default_calling_convention="c")
foreign sys {
    mach_task_self:: proc() -> Mach_Port ---
    getpid :: proc() -> Pid ---
    task_for_pid :: proc(target_tport: Mach_Port, pid: c.int, t: ^Mach_Port) -> Kern_Return ---
    mach_error_string :: proc(error_value: Kern_Return) -> cstring ---
}
