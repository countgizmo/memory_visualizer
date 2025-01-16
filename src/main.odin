package main

import "core:c"
import "base:runtime"
import "core:fmt"
import rl "vendor:raylib"
import "mach"
import "core:math"

MemoryRegion :: struct {
  size: u64,
  address: u64,
}

get_rect_width :: proc(size: u64, min_dim: f32, max_dim: f32) -> f32 {
  MIN_BYTES : f32 = 1024                // 1 KB
  MAX_BYTES : f32 = 1024 * 1024 * 1024  // 1 GB

  // Logarithm stuff
  size_f := f32(size)
  log_size := math.log_f32(2, max(MIN_BYTES, size_f))
  log_min := math.log_f32(2, MIN_BYTES)
  log_max := math.log_f32(2, MAX_BYTES)

  // Normalize to 0-1
  normalized := (log_size - log_min) / (log_max - log_min)

  return min_dim + normalized * (max_dim - min_dim)
}

render_mem_region :: proc(region: MemoryRegion, region_idx: int) {
  height :: 15
  sample_rec := rl.Rectangle{
    x = f32(5 * region_idx),
    y = f32(20 * region_idx + 3),
    width = get_rect_width(region.size, 50, 500),
    height = height,
  }

  rl.DrawRectangleRec(sample_rec, rl.BLUE)

  size_kb := region.size / 1024
  size_text := fmt.ctprintf("%dkb", size_kb)
  address_text := fmt.ctprintf("0x%x", region.address)

  rl.DrawText(size_text, i32(sample_rec.x + 5), i32(sample_rec.y), 12, rl.YELLOW)
  //rl.DrawText(address_text, i32(sample_rec.x + 10), i32(sample_rec.y + sample_rec.height - 13), 13, rl.PINK)
}

main::proc() {

  port := mach.mach_task_self()
  pid := mach.getpid()

  fmt.println("Current process(task):")
  fmt.printf(" PID: %d\n", pid)
  fmt.printf(" Port: %d\n\n", port)


  // Memory info
  address: u64 = 0
  size: u64 = 0
  nesting_depth: u32 = 0
  info: mach.VM_Region_Basic_Info_64
  info_count: u32 = size_of(mach.VM_Region_Basic_Info_64) / size_of(c.int)


  results: [dynamic]MemoryRegion

  for {
    mem_region := mach.vm_region_recurse_64(
      port,
      &address,
      &size,
      &nesting_depth,
      &info,
      &info_count)

    if mem_region == mach.KERN_INVALID_ADDRESS {
      break;
    }

    if mem_region != mach.KERN_SUCCESS {
      fmt.printf("ERROR: Failed getting region info: %d\n", mem_region)
      break;
    }

    append(&results, MemoryRegion {
      size = size,
      address = address,
    })

    address = address + size
  }

  rl.InitWindow(1600, 1024, "Memory Visualizer v0.1")
  defer rl.CloseWindow()

  rl.SetTargetFPS(60)

  for !rl.WindowShouldClose() {
    rl.BeginDrawing()

    rl.ClearBackground(rl.WHITE)

    for region, idx in results {
      render_mem_region(region, idx);
    }

    rl.EndDrawing()
  }
}
