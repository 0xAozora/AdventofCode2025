package main

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:os"
import "core:sort"
import "core:strconv"
import "core:strings"
import "core:time"

Area :: struct {
	A:    int,
	B:    int,
	Area: f64,
}

findIntersection :: proc(a, b, c, d: [2]f64) -> ([2]f64, bool) {

	denominator := linalg.cross(a - b, c - d)
	if denominator == 0 {
		return [2]f64{}, false
	}

	crossAB := linalg.cross(a, b)
	crossCD := linalg.cross(c, d)
	ix := (crossAB * (c.x - d.x) - (a.x - b.x) * crossCD) / denominator
	iy := (crossAB * (c.y - d.y) - (a.y - b.y) * crossCD) / denominator

	return [2]f64{ix, iy}, true
}

isInsideRect :: proc(x1, y1, x2, y2: f64, point: [2]f64) -> bool {
	return point.x > x1 && point.x < x2 && point.y > y1 && point.y < y2
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

	vertices: [dynamic][2]f64
	areas: [dynamic]Area

	for line in strings.split_lines_iterator(&it) {
		numbers := strings.split(line, ",")

		l := len(vertices)
		resize(&vertices, l + 1)
		vertices[l][0], _ = strconv.parse_f64(numbers[0])
		vertices[l][1], _ = strconv.parse_f64(numbers[1])

		d := len(areas)
		resize(&areas, d + l)
		for point, i in vertices[:l] {
			areas[d + i].A = i
			areas[d + i].B = l

			a := vertices[i]
			b := vertices[l]
			p := a - b

			areas[d + i].Area = (math.abs(p.x) + 1) * (math.abs(p.y) + 1)
		}
	}

	sort.quick_sort_proc(areas[:], proc(a, b: Area) -> int {
		return -sort.compare_f64s(a.Area, b.Area)
	})

	largestArea := int(areas[0].Area)

	largestAreaWithin: int
	intersections: [dynamic][2]f64
	areaLoop: for area in areas {

		resize(&intersections, 0)

		a := vertices[area.A]
		b := vertices[area.B]

		x1 := min(a.x, b.x)
		x2 := max(a.x, b.x)
		y1 := min(a.y, b.y)
		y2 := max(a.y, b.y)
		for vertex, i in vertices {

			if isInsideRect(x1, y1, x2, y2, vertex) {
				continue areaLoop
			}

			// Check intersection
			next := vertices[(i + 1) % len(vertices)]
			intersection, ok := findIntersection(a, b, vertex, next)
			if !ok {
				continue
			}

			if intersection == vertex {


				// Check angle to see if it goes through polygon
				prev := vertices[(i - 1) % len(vertices)]
				intersection, ok = findIntersection(a, b, prev, next)
				if !ok {
					continue
				}

				if linalg.vector_dot(intersection - prev, intersection - next) >= 0 {
					continue
				}
				intersection = vertex
			} else if linalg.vector_dot(intersection - vertex, intersection - next) >= 0 {
				continue
			} else if isInsideRect(x1, y1, x2, y2, intersection) {
				continue areaLoop
			}

			l := len(intersections)
			resize(&intersections, l + 1)
			intersections[l] = intersection
		}

		// Is valid?
		if len(intersections) == 0 {
			continue
		}

		sort.quick_sort_proc(intersections[:], proc(a, b: [2]f64) -> int {
			return sort.compare_f64s(a.x, b.x)
		})

		// Rearrange
		if b.x < a.x {
			c := b
			b = a
			a = b
		}

		// Inside the polygon?
		inside: bool
		for intersection in intersections {
			inside = !inside
			if intersection == a {
				if !inside {
					continue areaLoop
				}
				break
			} else if intersection == b {
				continue areaLoop
			}
		}

		largestAreaWithin = int(area.Area)
		break
	}

	fmt.printfln("Time taken: %vms", time.duration_milliseconds(time.tick_since(startTime)))

	fmt.println(largestArea)
	fmt.println(largestAreaWithin)
}
