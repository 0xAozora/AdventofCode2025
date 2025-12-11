package main

import "core:fmt"
import "core:math/linalg"
import "core:os"
import "core:sort"
import "core:strconv"
import "core:strings"
import "core:time"

Distance :: struct {
	A: int,
	B: int,
	D: f64,
}

main :: proc() {

	data, ok := os.read_entire_file("input", context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	it := string(data)

	startTime := time.tick_now()

	junctions: [dynamic][3]f64
	connections: [dynamic]Distance

	for line in strings.split_lines_iterator(&it) {
		numbers := strings.split(line, ",")

		l := len(junctions)
		resize(&junctions, l + 1)
		junctions[l][0], _ = strconv.parse_f64(numbers[0])
		junctions[l][1], _ = strconv.parse_f64(numbers[1])
		junctions[l][2], _ = strconv.parse_f64(numbers[2])

		d := len(connections)
		resize(&connections, d + l)
		for point, i in junctions[:l] {
			connections[d + i].A = i
			connections[d + i].B = l
			connections[d + i].D = linalg.distance(point, junctions[l])
		}
	}

	sort.quick_sort_proc(connections[:], proc(a, b: Distance) -> int {
		return sort.compare_f64s(a.D, b.D)
	})

	amount := 10
	if len(junctions) > 20 {
		amount = 1000
	}

	lastConnection: Distance
	circuits: map[int]^map[int]struct{}
	circuits, lastConnection = connectJunctions(circuits, connections[:amount], len(connections))

	// Count Circuit Lengths
	circuitMap: map[^map[int]struct{}]int
	circuitLengths: [dynamic]int
	for _, circuit in circuits {
		if _, ok := circuitMap[circuit]; !ok {
			circuitMap[circuit] = len(circuit)
			l := len(circuitLengths)
			resize(&circuitLengths, l + 1)
			circuitLengths[l] = len(circuit)
		}
	}

	sort.quick_sort(circuitLengths[:])

	circuitProduct: int = 1
	cl := len(circuitLengths)
	for i := cl - 1; i > cl - 4; i -= 1 {
		circuitProduct *= circuitLengths[i]
	}

	_, lastConnection = connectJunctions(circuits, connections[amount:], len(junctions))

	fmt.printfln("Time taken: %vms", time.duration_milliseconds(time.tick_since(startTime)))

	fmt.println(circuitProduct)
	fmt.println(u64(junctions[lastConnection.A].x * junctions[lastConnection.B].x))
}

connectJunctions :: proc(
	circuits: map[int]^map[int]struct{},
	distances: []Distance,
	maxCircuits: int,
) -> (
	map[int]^map[int]struct{},
	Distance,
) {
	circuits := circuits
	last: Distance
	for distance in distances {

		circuitA, aok := circuits[distance.A]
		if aok {
			circuitB, bok := circuits[distance.B]
			if !bok {
				circuitA[distance.B] = {}
				circuits[distance.B] = circuitA
			} else if circuitA == circuitB {
				continue
			} else if len(circuitA) > len(circuitB) {
				moveMaps(&circuits, circuitA, circuitB)
			} else {
				moveMaps(&circuits, circuitB, circuitA)
			}
		} else {
			circuitB, bok := circuits[distance.B]
			if bok {
				circuitB[distance.A] = {}
				circuits[distance.A] = circuitB
			} else {
				newCircuit := new(map[int]struct{})
				newCircuit[distance.A] = {}
				newCircuit[distance.B] = {}
				circuits[distance.A] = newCircuit
				circuits[distance.B] = newCircuit
			}
		}
		last = distance
		if len(circuits) >= maxCircuits {
			break
		}
	}

	return circuits, last
}

moveMaps :: proc(c: ^map[int]^map[int]struct{}, a, b: ^map[int]struct{}) {
	for key, value in b {
		a[key] = value
		c[key] = a
	}
}
