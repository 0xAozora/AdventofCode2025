package main

import "core:bytes"
import "core:fmt"
import "core:os"
import "core:time"

countSplitsAndPaths :: proc(data: []byte, pathMap: []u64, pos: int, x_len: int) -> (int, u64) {

	below := pos + x_len
	for below < len(data) && data[below] == '.' {
		below += x_len
	}
	if below >= len(data) {
		return 0, 1
	}
	if data[below] == '^' {
		data[below] = 'X' // Mark Path
		splits_left, paths_left := countSplitsAndPaths(data, pathMap, below - 1, x_len)
		splits_right, paths_right := countSplitsAndPaths(data, pathMap, below + 1, x_len)

		splits := splits_left + splits_right + 1

		paths := paths_left + paths_right
		pathMap[below] = paths

		return splits, paths
	}

	return 0, pathMap[below]
}

main :: proc() {

	data, ok := os.read_entire_file("input", context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	splits: int
	paths: u64

	start_pos := bytes.index_rune(data, 'S')
	x_len: int = bytes.index_rune(data[start_pos:], '\n') + start_pos + 1

	startTime := time.tick_now()

	pathMap := make([]u64, len(data))
	splits, paths = countSplitsAndPaths(data, pathMap, start_pos + x_len, x_len)

	fmt.printfln("Time taken: %vµs", time.duration_microseconds(time.tick_since(startTime)))

	fmt.println(splits)
	fmt.println(paths)
}
