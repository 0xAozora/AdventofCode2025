package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {

	data, ok := os.read_entire_file("input", context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	pos: int = 50
	end: int = 100
	passCount: int
	zeroCount: int

	it := string(data)
	for line in strings.split_lines_iterator(&it) {

		// process line
		r := line[0]
		step, _ := strconv.parse_int(line[1:])

		if r == 'L' {
			step = -step
		}

		newPos := pos + step
		passCount += int(f64(math.abs(newPos)) / f64(end))
		if pos != 0 && newPos <= 0 {
			passCount += 1
		}

		pos = newPos %% end
		if pos == 0 {
			zeroCount += 1
		}
	}

	fmt.println("Answer1:", zeroCount)
	fmt.println("Answer2:", passCount)
}
