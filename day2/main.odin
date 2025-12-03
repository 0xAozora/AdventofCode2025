package main

import "core:fmt"
import "core:io"
import "core:math"
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

	ranges := strings.split(it, ",")

	invalidSum1: u64
	invalidSum2: u64

	startTime := time.tick_now()
	for rangeStr in ranges {
		range := strings.split(rangeStr, "-")
		start, _ := strconv.parse_u64(range[0])
		end, _ := strconv.parse_u64(range[1])

		lowerBound: f64
		startDigits := int(math.log10(f64(start))) + 1
		if startDigits == 1 {
			lowerBound = math.pow10(f64(startDigits))
			if u64(lowerBound) > u64(end) {
				continue
			}
			start = u64(lowerBound)
			startDigits += 1
		} else {
			lowerBound = math.pow10(f64(startDigits - 1))
		}

		endDigits := int(math.log10(f64(end))) + 1
		for i := startDigits; i <= endDigits && start <= end; i += 1 {

			higherBound := u64(lowerBound * 10)
			end := min(higherBound - 1, end)

			even: bool = i % 2 == 0
			combinations: int
			if even {
				sum1 := sumRepeatingNumbers(start, end, i, 2)
				if sum1 != 0 {
					invalidSum1 += sum1
					invalidSum2 += sum1

					combinations += 1
				}
			}

			for n := 3; n <= i / 2; n += 2 {
				if !is_prime(i64(n)) {
					continue
				}
				if i % n == 0 {
					sum2 := sumRepeatingNumbers(start, end, i, n)
					if sum2 != 0 {
						invalidSum2 += sum2
						combinations += 1
					}
				}
			}

			if !even && combinations != 1 {
				sum2 := sumRepeatingNumbers(start, end, i, i)
				invalidSum2 -= sum2 * u64(combinations - 1)
			}

			start = higherBound
			lowerBound = f64(start)
		}
	}
	fmt.printfln("Time taken: %vms", time.duration_milliseconds(time.tick_since(startTime)))

	fmt.println(invalidSum1)
	fmt.println(invalidSum2)
}

sumRepeatingNumbers :: proc(start, end: u64, e, r: int) -> u64 {

	n := int(e / r)
	nBound := u64(math.pow10(f64(e - n)))

	multiplier: u64 = 1 + nBound
	for i := 2; i < r; i += 1 {
		iBound := math.pow10(f64(e - i * n))
		multiplier += u64(iBound)
	}

	startTop := start / nBound
	startBound := startTop * multiplier
	if startBound < start {
		startTop += 1
	}

	endTop := end / nBound
	endBound := endTop * multiplier
	if endBound > end {
		endTop -= 1
	}

	count := i64(endTop - startTop) + 1
	if count <= 0 {
		return 0
	}
	avg := f64(endTop + startTop) / 2
	sum := u64(avg * f64(count))

	return multiplier * sum
}

is_prime :: proc(n: i64) -> bool {
	if n <= 1 {
		return false
	}
	if n == 2 {
		return true
	}
	for i in 2 ..= i64(math.sqrt(f32(n)) + 1) {
		if n % i == 0 {
			return false
		}
	}
	return true
}
