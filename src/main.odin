package main

import "core:c"
import "base:runtime"
import fmt "core:fmt"
import rl "vendor:raylib"
import "mach"

main::proc() {

  port := mach.mach_task_self()
  pid := mach.getpid()

  // Memory info
  address: u64 = 0
  size: u64 = 0
  nesting_depth: u32 = 0
  info: mach.VM_Region_Basic_Info_64
  info_count: u32 = size_of(mach.VM_Region_Basic_Info_64) / size_of(c.int)



  // Convert our struct to a byte slice to inspect its memory
    info_bytes := transmute([]byte)runtime.Raw_Slice{
        data = &info,
        len = size_of(mach.VM_Region_Basic_Info_64),
    }

    fmt.println("\nBefore call, struct contents (in bytes):")
    for b, i in info_bytes {
        if i % 4 == 0 do fmt.printf("\nOffset %2d: ", i)
        fmt.printf("%02x ", b)
    }

  memory_top_region := mach.vm_region_recurse_64(
      port,
      &address,
      &size,
      &nesting_depth,
      &info,
      &info_count)

  fmt.println("\n\nAfter call, struct contents (in bytes):")
    for b, i in info_bytes {
        if i % 4 == 0 do fmt.printf("\nOffset %2d: ", i)
        fmt.printf("%02x ", b)
    }


  if memory_top_region == mach.KERN_SUCCESS {
    fmt.printf("Toop memory region:\n")
    fmt.printf("  Address: 0x%x\n", address)
    fmt.printf("  Size: %d bytes\n", size)
    fmt.printf("  Protection: 0x%x\n", info.protection)
  } else {
    fmt.printf("Error getting region info: %d\n", memory_top_region)
  }

  fmt.println("Current process(task):")
  fmt.printf(" PID: %d\n", pid)
  fmt.printf(" Port: %d\n\n", port)

  rl.InitWindow(800, 600, "Memory Visualizer v0.1")
  defer rl.CloseWindow()

  rl.SetTargetFPS(60)

  sample_rec := rl.Rectangle{
      x = 10,
      y = 20,
      width = 400,
      height = 100,
  }

  for !rl.WindowShouldClose() {
    rl.BeginDrawing()

    rl.ClearBackground(rl.WHITE)
    rl.DrawRectangleRec(sample_rec, rl.BLUE)
    rl.DrawText("Memory Region", i32(sample_rec.x + 5), i32(sample_rec.y + 5), 20, rl.YELLOW)
    rl.EndDrawing()
  }
}
