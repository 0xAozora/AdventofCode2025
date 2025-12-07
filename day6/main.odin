package main

import "core:fmt"
import "core:os"
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
	sum2: int

	y_len: int
	max_x_len: int

	startTime := time.tick_now()

	list: [dynamic][dynamic]int
	row_lengths: [dynamic]int
	for line in strings.split_lines_iterator(&it) {

		y_len += 1
		resize(&row_lengths, y_len)
		max_x_len += max(max_x_len, len(line))
		row_lengths[y_len - 1] = len(line) + 1 // With \n

		separatedNumbers := strings.split(line, " ")

		// Check if number or arithmetic operator
		index: int
		for number in separatedNumbers {
			if number == "" {
				continue
			}
			index += 1
			if index > len(list) {
				resize(&list, index) // Make sure there are enough columns
			}
			numbers := list[index - 1]

			l := len(numbers)
			resize(&numbers, l + 1)

			if number == "+" || number == "*" {
				numbers[l] = int(number[0] - 42)
			} else {
				numbers[l], _ = strconv.parse_int(number)
			}
			list[index - 1] = numbers
		}
	}

	// Calculate sum1
	for column in list {

		result: int

		l := len(column)
		if column[l - 1] == 0 {
			result = 1
			for number in column[:l - 1] {
				result *= number
			}
		} else {
			for number in column[:l - 1] {
				result += number
			}
		}
		sum1 += result
	}

	it = string(data)

	// Calculate sum2
	last_y := y_len - 1
	last_row_length := row_lengths[last_y]
	operator: int
	result: int
	for x := 0; x < max_x_len; x += 1 {

		// Check operator
		if x < last_row_length - 1 {
			index := len(it) - last_row_length + x
			c := it[index]
			if c != ' ' {
				sum2 += result
				operator = int(c - 42)
				result = int(operator != 1)
			}
		}

		ok: bool
		number := 0
		row_start: int
		for y := 0; y < y_len - 1; y += 1 {
			row_length := row_lengths[y]
			if x < row_length - 1 {
				c := it[row_start + x]
				if c != ' ' {
					number *= 10
					number += int(c - '0')
					ok = true
				}
			}
			row_start += row_length
		}

		if !ok {
			continue
		}

		if operator == 0 {
			result *= number
		} else {
			result += number
		}
	}
	sum2 += result

	fmt.printfln("Time taken: %vµs", time.duration_microseconds(time.tick_since(startTime)))

	fmt.println(sum1)
	fmt.println(sum2)
}
