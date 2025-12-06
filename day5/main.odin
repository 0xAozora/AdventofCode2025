package main

import "core:fmt"
import "core:io"
import "core:math"
import "core:mem"
import "core:os"
import "core:sort"
import "core:strconv"
import "core:strings"
import "core:time"

Range :: [2]int

main :: proc() {


	data, ok := os.read_entire_file("input", context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	it := string(data)

	sum1: int
	sum1_alt: int
	sum2: int

	x_len: int
	y_len: int

	startTime := time.tick_now()

	ranges: [dynamic]Range
	for line in strings.split_lines_iterator(&it) {
		if line == "" {
			break
		}

		l := len(ranges)
		resize(&ranges, len(ranges) + 1)

		index := strings.index_rune(line, '-')
		ranges[l][0], _ = strconv.parse_int(line[:index])
		ranges[l][1], _ = strconv.parse_int(line[index + 1:])
	}

	sort.merge_sort_proc(ranges[:], proc(a, b: Range) -> int {
		return a[0] - b[0]
	})

	for line in strings.split_lines_iterator(&it) {

		number, _ := strconv.parse_int(line)

		// Linear search in reverse:
		for i := len(ranges) - 1; i >= 0; i -= 1 {
			range := ranges[i]
			if number <= range[1] {
				sum1 += 1
				break
			} else if number < range[0] {
				break
			}
		}

		// Binary search - takes longer in total:
		index := binary_search(ranges[:], number, proc(range: Range, target: int) -> bool {
				return range[0] > target
			}) - 1

		for index != -1 && number >= ranges[index][0] {
			if number <= ranges[index][1] {
				sum1_alt += 1
				break
			}
			index -= 1
		}
	}

	start: int = ranges[0][0]
	end: int = ranges[0][1]
	for range in ranges[1:] {
		if range[0] <= end + 1 {
			end = max(end, range[1])
		} else {
			sum2 += end - start + 1
			start = range[0]
			end = range[1]
		}
	}
	sum2 += end - start + 1

	fmt.printfln("Time taken: %vµs", time.duration_microseconds(time.tick_since(startTime)))

	fmt.println(sum1)
	fmt.println(sum1_alt)
	fmt.println(sum2)
}

// Similar to Go's sort.Search()
binary_search :: proc(array: []$T, x: $X, f: proc(_: T, _: X) -> bool) -> int {
	i, j := 0, len(array)
	for i < j {
		h := int(uint(i + j) >> 1)
		if !f(array[h], x) {
			i = h + 1
		} else {
			j = h
		}
	}
	return i
}
