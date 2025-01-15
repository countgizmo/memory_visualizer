package main

import "core:c"
import "base:runtime"
import fmt "core:fmt"
import rl "vendor:raylib"
import "mach"
import "core:math"

RectDimension :: struct {
  width: f32,
  height: f32,
}

get_rect_dimension :: proc(size: u64, min_dim: f32, max_dim: f32) -> RectDimension {
  MIN_BYTES : f32 = 1024                // 1 KB
  MAX_BYTES : f32 = 1024 * 1024 * 1024  // 1 GB

  size_f := f32(size)
  log_size := math.log_f32(2, max(MIN_BYTES, size_f))
  log_min := math.log_f32(2, MIN_BYTES)
  log_max := math.log_f32(2, MAX_BYTES)

  // Normalize to 0-1
  normalized := (log_size - log_min) / (log_max - log_min)

  WIDTH_SCALE :: 1.3

  return RectDimension {
    width = min_dim + (normalized * WIDTH_SCALE) * (max_dim - min_dim),
    height = min_dim + normalized * (max_dim - min_dim)
  }
}

main::proc() {

  port := mach.mach_task_self()
  pid := mach.getpid()

  // Memory info
  address: u64 = 0
  size: u64 = 0
  nesting_depth: u32 = 0
  info: mach.VM_Region_Basic_Info_64
  info_count: u32 = size_of(mach.VM_Region_Basic_Info_64) / size_of(c.int)

  memory_top_region := mach.vm_region_recurse_64(
      port,
      &address,
      &size,
      &nesting_depth,
      &info,
      &info_count)

  if memory_top_region == mach.KERN_SUCCESS {
    fmt.printf("Top memory region:\n")
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

  dim := get_rect_dimension(size, 50, 500)
  sample_rec := rl.Rectangle{
      x = 10,
      y = 20,
      width = dim.width,
      height = dim.height,
  }

  size_kb := size / 1024
  size_text := fmt.ctprintf("%dkb", size_kb)

  for !rl.WindowShouldClose() {
    rl.BeginDrawing()

    rl.ClearBackground(rl.WHITE)
    rl.DrawRectangleRec(sample_rec, rl.BLUE)
    rl.DrawText(size_text, i32(sample_rec.x + 5), i32(sample_rec.y + 5), 20, rl.YELLOW)
    rl.EndDrawing()
  }
}
