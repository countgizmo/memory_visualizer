package mach

import "core:c"

foreign import sys "system:System.B"

Mach_Port :: distinct u32
Task :: Mach_Port
Kern_Return :: distinct c.int
Pid :: c.int
VM_Region_Basic_Info_64 :: struct {
    protection: u32,
    max_protection: u32,
    inheritance: u32,
    shared: b32,
    reserved: b32,
    offset: u64,
    behavior: u32,
    user_wired_count: u16,
    external_pager: u16,
    pages_swapped_out: u16,
    shadow_depth: u16,
    pages_reusable: u16,
}

KERN_SUCCESS :: 0
KERN_INVALID_ARGUMENT :: 4
KERN_NOT_IN_SET :: 138

@(default_calling_convention="c")
foreign sys {
    mach_task_self:: proc() -> Mach_Port ---
    getpid :: proc() -> Pid ---
    task_for_pid :: proc(target_tport: Mach_Port, pid: c.int, t: ^Mach_Port) -> Kern_Return ---
    mach_error_string :: proc(error_value: Kern_Return) -> cstring ---
    vm_region_recurse_64 :: proc(
        target_task: Mach_Port,
        address: ^u64,
        size: ^u64,
        nesting_depth: ^u32,
        info: ^VM_Region_Basic_Info_64,
        info_count: ^u32,
    ) -> Kern_Return ---
}
