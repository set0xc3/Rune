package main

import "core:container/queue"
import "core:fmt"
import "core:io"
import "core:os"
import "core:strconv"
import "core:strings"

import rl "vendor:raylib"

import mu "saura-vendor:microui"
import "saura:ui"

WINDOW_WIDTH := 1280
WINDOW_HEIGHT := 720

mu_ctx: ^mu.Context

Entity :: struct {
	name:    string,
	variant: union {
		^File,
		^Folder,
	},
}

File :: struct {
	using entity: Entity,
	buffer:       queue.Queue(byte),
}
Folder :: struct {
	using entity: Entity,
	childs:       queue.Queue(Entity),
}

Context :: struct {
	entities: queue.Queue(Entity),
	viewport: string,
}
ctx: Context

new_entity :: proc($T: typeid) -> ^T {
	e := new(T)
	e.variant = e
	return e
}

folder_next_childs :: proc(childs: ^queue.Queue(Entity)) {
	for child in childs.data {
		switch e in child.variant {
		case ^Folder:
			if .ACTIVE in mu.treenode(mu_ctx, e.name) {
				folder_next_childs(&e.childs)
			}
		case ^File:
			if .SUBMIT in mu.button(mu_ctx, e.name, .NONE, {}) {
				handle, _ := os.open(e.name);defer os.close(handle)
				data: [4096]byte
				total_read, err := os.read(handle, data[:])
				ctx.viewport = string(data[:total_read])
			}
		}
	}
}

main :: proc() {
	{
		folder1 := new_entity(Folder)
		folder1.name = "Hentai"
		queue.push_back(&ctx.entities, folder1)
		{
			folder2 := new_entity(Folder)
			folder2.name = "Furry"
			queue.push_back(&folder1.childs, folder2)
			{
				file := new_entity(File)
				file.name = "README.md"
				queue.push_back(&folder2.childs, file)
			}
		}
	}
	{
		file := new_entity(File)
		file.name = "README.md"
		queue.push_back(&ctx.entities, file)
	}


	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_RESIZABLE})
	rl.InitWindow(
		auto_cast WINDOW_WIDTH,
		auto_cast WINDOW_HEIGHT,
		"Example",
	);defer rl.CloseWindow()
	rl.SetWindowMinSize(320, 240)

	mu_ctx = ui.InitUIScope()

	for !rl.WindowShouldClose() {
		free_all(context.temp_allocator)

		if (rl.IsWindowResized() && !rl.IsWindowFullscreen()) {
			WINDOW_WIDTH = auto_cast rl.GetScreenWidth()
			WINDOW_HEIGHT = auto_cast rl.GetScreenHeight()
		}

		rl.BeginDrawing();defer rl.EndDrawing()

		rl.ClearBackground(rl.WHITE)

		ui.BeginUIScope()

		@(static) opts := mu.Options{.NO_CLOSE, .NO_RESIZE, .NO_INTERACT}

		// Left Panel
		mu.set_next_item_size(mu_ctx, {200, auto_cast WINDOW_HEIGHT})
		mu.window(mu_ctx, "Vault", {0, 0, 200, auto_cast WINDOW_HEIGHT}, opts)
		mu.layout_row(mu_ctx, {-1, -1})
		mu.layout_begin_column(mu_ctx)

		for entity in ctx.entities.data {
			switch e in entity.variant {
			case ^Folder:
				if .ACTIVE in mu.treenode(mu_ctx, e.name) {
					folder_next_childs(&e.childs)
				}
			case ^File:
				if .SUBMIT in mu.button(mu_ctx, e.name, .NONE, {}) {
					handle, _ := os.open(e.name);defer os.close(handle)
					data: [4096]byte
					total_read, err := os.read(handle, data[:])
					ctx.viewport = string(data[:total_read])
				}
			}
		}


		// it_folder := list.iterator_head(ctx.entities, Folder, "node")
		// for folder in list.iterate_next(&it_folder) {
		// 	if .ACTIVE in mu.treenode(mu_ctx, folder.name) {
		// 		folder_next_childs(folder.childs)
		// 	}
		// }

		// it_files := list.iterator_head(ctx.files.childs, File, "node")
		// for file in list.iterate_next(&it_files) {
		// 	if .SUBMIT in mu.button(mu_ctx, file.name, .NONE, {}) {
		// 		fmt.println("Click")
		// 	}
		// }

		mu.layout_end_column(mu_ctx)

		// Right Panel
		mu.set_next_item_size(mu_ctx, {auto_cast WINDOW_WIDTH, auto_cast WINDOW_HEIGHT})
		mu.window(
			mu_ctx,
			"View",
			{201, 0, auto_cast WINDOW_WIDTH - 200, auto_cast WINDOW_HEIGHT},
			opts,
		)
		mu.text(mu_ctx, ctx.viewport)
		// handle, _ := os.open("vendor/microui/README.md")
		// data: [4096]byte
		// total_read, err := os.read(handle, data[:])
		// mu.text(mu_ctx, string(data[:]))

		// Add left
		if rl.IsKeyReleased(.F1) {
		}
		// Add Right
		if rl.IsKeyReleased(.F2) {
		}
	}
}
