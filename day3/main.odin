package main

import "core:fmt"
import "core:math"
import "core:os"
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

	sum1: u64
	sum2: u64
	sum2_alt: u64
	sum2_alt2: u64

	startTime := time.tick_now()

	for line in strings.split_lines_iterator(&it) {
		sum1 += joltage(line, 2)
		sum2 += joltage(line, 12) // Trivial Implementation
		sum2_alt += joltageBuffer(line, 12) // Buffered - Slower
		sum2_alt2 += joltageBuffer2(line, 12) // Even slower
	}
	fmt.printfln("Time taken: %vµs", time.duration_microseconds(time.tick_since(startTime)))

	fmt.println(sum1)
	fmt.println(sum2)
	fmt.println(sum2_alt)
	fmt.println(sum2_alt2)
}

joltage :: proc(line: string, n: int) -> u64 {

	m := u64(math.pow10_f64(f64(n - 1)))

	for i := '9'; i >= '0'; i -= 1 {
		index := strings.index_rune(line[:len(line) - (n - 1)], i)
		if index != -1 {
			if m == 1 {
				return u64(i - '0')
			}
			return u64(i - '0') * m + joltage(line[index + 1:], n - 1)
		}
	}

	return 0
}

joltageBuffer :: proc(line: string, n: int) -> u64 {

	buffer := make([]byte, n)
	buffer[0] = line[0]

	l := 1
	j := 1
	minEnd := len(line) - n
	minBuffer := n - len(line)
	for ; j < minEnd + l; j += 1 {
		r := line[j]
		for i := l - 1; i >= max(0, minBuffer + j); i -= 1 {
			l = i
			if r > buffer[i] { 	// []
				buffer[i] = r
				continue
			}
			if i < n - 1 {
				l += 1
				buffer[l] = r
			}
			break
		}
		l += 1
	}
	copy(buffer[l:], line[j:])

	max_joltage: u64
	e: u64 = 1
	for i := n - 1; i >= 0; i -= 1 {
		max_joltage += u64(buffer[i] - '0') * e
		e *= 10
	}

	return max_joltage
}

joltageBuffer2 :: proc(line: string, n: int) -> u64 {

	buffer := make([]byte, n)
	buffer[0] = line[0]

	i: int = 1
	l: int
	dec: int
	minEnd := len(line) - n
	for ; i <= minEnd + l; i += 1 {
		r := line[i]

		if r > buffer[l] {
			buffer[l] = r
			if l != 0 {
				i -= 1
				l -= 1
			}
			dec = 1
			continue
		} else if l < n - 1 {
			l += 1
			buffer[l] = r
		}
		dec = 0
	}
	copy(buffer[l + dec:], line[i:])

	max_joltage: u64
	e: u64 = 1
	for i := n - 1; i >= 0; i -= 1 {
		max_joltage += u64(buffer[i] - '0') * e
		e *= 10
	}

	return max_joltage
}
