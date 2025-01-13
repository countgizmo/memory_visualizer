package main

import rl "vendor:raylib"

main::proc() {
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
