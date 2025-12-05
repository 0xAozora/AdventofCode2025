package main

import "core:fmt"
import "core:io"
import "core:math"
import "core:mem"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:time"

main :: proc() {

	data, ok := os.read_entire_file("input", context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	it := string(data)

	sum1: int
	sum2: int

	startTime := time.tick_now()

	x_len: int
	y_len: int

	grid: [dynamic]u8
	for line in strings.split_lines_iterator(&it) {
		l := len(grid)
		resize(&grid, len(grid) + len(line))
		for i := 0; i < len(line); i += 1 {
			if line[i] == '@' {
				grid[l + i] = 1
			}
		}

		x_len = len(line)
		y_len += 1
	}

	mask := make([]u8, len(grid))
	sum1 += count_rolls(grid, mask, x_len, y_len)
	sum2 = sum1

	sum: int = 1
	for sum != 0 {
		clear_rolls(grid, mask)
		sum = count_rolls(grid, mask, x_len, y_len)
		sum2 += sum
	}

	fmt.printfln("Time taken: %vµs", time.duration_microseconds(time.tick_since(startTime)))

	fmt.println(sum1)
	fmt.println(sum2)
}

count_rolls :: proc(grid: [dynamic]u8, mask: []u8, x_len, y_len: int) -> int {
	sum: int
	for y := 0; y < y_len; y += 1 {

		y_min := max(y - 1, 0)
		y_max := min(y + 1, y_len - 1)

		for x := 0; x < x_len; x += 1 {

			if grid[y * x_len + x] == 0 {
				continue
			}

			x_min := max(x - 1, 0)
			x_max := min(x + 1, x_len - 1)

			count: u8
			for y := y_min; y <= y_max; y += 1 {
				for x := x_min; x <= x_max; x += 1 {
					count += grid[y * x_len + x]
				}
			}

			if count < 5 {
				sum += 1
				mask[y * x_len + x] = 1
			}
		}
	}
	return sum
}

clear_rolls :: proc(grid: [dynamic]u8, mask: []u8) {
	for i := 0; i < len(grid); i += 1 {
		grid[i] -= mask[i]
	}
	mem.zero_slice(mask)
}
