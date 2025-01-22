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
  protection: u32,
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

SIZE_TEXT_COLOR :rl.Color: {226, 232, 240, 255}
ADDRESS_TEXT_COLOR :rl.Color: {45, 55, 72, 255}

render_mem_region :: proc(region: MemoryRegion, region_idx: int) {
  height :: 15
  sample_rec := rl.Rectangle{
    x = 150,
    y = f32(20 * region_idx + 3),
    width = get_rect_width(region.size, 50, 500),
    height = height,
  }

  rl.DrawRectangleRec(sample_rec, protection_color(region.protection))

  size_kb := region.size / 1024
  size_text := fmt.ctprintf("%dkb", size_kb)
  address_text := fmt.ctprintf("0x%x", region.address)

  rl.DrawText(size_text, i32(sample_rec.x + 5), i32(sample_rec.y), 12, SIZE_TEXT_COLOR)
  rl.DrawText(address_text, 0, i32(sample_rec.y), 12, ADDRESS_TEXT_COLOR)
}

BASE_BRIGHTNESS :: 127

protection_color :: proc(protection: u32) -> rl.Color {
  result: rl.Color = {0, 0, 0, 255}

  is_readable := (protection & mach.VM_PROT_READ) != 0
  is_writable := (protection & mach.VM_PROT_WRITE) != 0
  is_executable := (protection & mach.VM_PROT_EXECUTE) != 0


  if is_readable do result[0] = BASE_BRIGHTNESS
  if is_writable do result[1] = BASE_BRIGHTNESS
  if is_executable do result[2] = BASE_BRIGHTNESS

  return result;
}

main::proc() {
  // OBSERVATION: this port seems to be a constant.
  // Somehow the system know  that the port is for the self process.
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
      protection = info.protection,
    })

    address = address + size
  }

  rl.InitWindow(1600, 1024, "Memory Visualizer v0.1")
  defer rl.CloseWindow()

  rl.SetTargetFPS(60)

  for !rl.WindowShouldClose() {
    rl.BeginDrawing()

    rl.ClearBackground({235, 235, 235, 255})

    for region, idx in results {
      render_mem_region(region, idx);
    }

    rl.EndDrawing()
  }
}
