package probe_ports

import "core:fmt"
import "../src/mach"

main :: proc() {
    own_pid := mach.getpid()
    own_task := 123 //mach.mach_task_self()

    fmt.printf("Current process:\n")
    fmt.printf("  PID: %d\n", own_pid)
    fmt.printf("  Task port: %d\n\n", own_task)

    retrieved_task: mach.Mach_Port
    result := mach.task_for_pid(cast(mach.Mach_Port)own_task, own_pid, &retrieved_task)

    if result == mach.KERN_SUCCESS {
        fmt.printf("Successfully got task port: %d\n", retrieved_task)
    } else {
        error_string := mach.mach_error_string(result)
        fmt.printf("Failed to get task port: %d (%s)\n", result, error_string)
    }
}
