package main

import "core:container/intrusive/list"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

import rl "vendor:raylib"

import mu "saura-vendor:microui"
import "saura:ui"

WINDOW_WIDTH := 1280
WINDOW_HEIGHT := 720

mu_ctx: ^mu.Context

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_RESIZABLE})
	rl.InitWindow(auto_cast WINDOW_WIDTH, auto_cast WINDOW_HEIGHT, "Example");defer rl.CloseWindow()
	rl.SetWindowMinSize(320, 240)

	mu_ctx = ui.InitUIScope()

	for !rl.WindowShouldClose() {
		free_all(context.temp_allocator)

		if (rl.IsWindowResized() && !rl.IsWindowFullscreen())
        {
            WINDOW_WIDTH = auto_cast rl.GetScreenWidth();
            WINDOW_HEIGHT = auto_cast rl.GetScreenHeight();
        }

		fmt.println(WINDOW_WIDTH, WINDOW_HEIGHT)

		rl.BeginDrawing();defer rl.EndDrawing()

		rl.ClearBackground(rl.WHITE)

		ui.BeginUIScope()

		@(static) opts := mu.Options{}

		mu.set_next_item_size(mu_ctx, {auto_cast WINDOW_WIDTH, auto_cast WINDOW_HEIGHT})
		mu.window(mu_ctx, "Main", {0, 0, auto_cast WINDOW_WIDTH, auto_cast WINDOW_HEIGHT}, opts)

		mu.set_next_item_pos(mu_ctx, {100, 100})
		mu.window(mu_ctx, "Test", {0, 0, 100, 100}, opts)

		mu.layout_row(mu_ctx, {-1, -1})
		mu.layout_begin_column(mu_ctx)
		if .ACTIVE in mu.treenode(mu_ctx, "Test 1") {
			if .SUBMIT in mu.button(mu_ctx, "Base Note Template", .NONE, {}) {
				fmt.println("Click")
			}
		}
		mu.layout_end_column(mu_ctx)

		// Add left
		if rl.IsKeyReleased(.F1) {
		}
		// Add Right
		if rl.IsKeyReleased(.F2) {
		}
	}
}
