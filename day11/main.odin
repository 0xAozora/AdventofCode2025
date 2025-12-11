package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:time"

countPaths :: proc(node: ^Node, target: [3]byte) -> int {

	count: int
	for nextNode in node.next {
		if nextNode.name == target {
			count += 1
		} else if nextNode.toDest != -1 {
			count += nextNode.toDest
		} else {
			count += countPaths(nextNode, target)
		}
	}

	node.toDest = count
	return count
}

resetNodeMap :: proc(nodeMap: map[[3]byte]^Node) {
	for _, node in nodeMap {
		node.toDest = -1
	}
}

Node :: struct {
	toDest: int,
	name:   [3]byte,
	next:   []^Node,
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

	nodeMap: map[[3]byte]^Node
	nodeName: [3]byte
	for line in strings.split_lines_iterator(&it) {

		colonIndex := strings.index_rune(line, ':')
		copy(nodeName[:], line[:colonIndex])
		node: ^Node = nodeMap[nodeName]
		if node == nil {
			node = new(Node)
			node.toDest = -1
			node.name = nodeName
			nodeMap[nodeName] = node
		}

		nodeNames := strings.split(line[colonIndex + 2:], " ")
		node.next = make([]^Node, len(nodeNames))

		for nM, i in nodeNames {
			copy(nodeName[:], nM)
			nextNode := nodeMap[nodeName]
			if nextNode == nil {
				nextNode = new(Node)
				nextNode.toDest = -1
				nextNode.name = nodeName
				nodeMap[nodeName] = nextNode
			}
			node.next[i] = nextNode
		}
	}

	outPaths: int
	you := nodeMap[[3]byte{'y', 'o', 'u'}]
	if you != nil {
		outPaths = countPaths(you, [3]byte{'o', 'u', 't'}); resetNodeMap(nodeMap)
	}

	svrPaths: int
	svr := nodeMap[[3]byte{'s', 'v', 'r'}]
	if svr != nil {
		svrToDAC := countPaths(svr, [3]byte{'d', 'a', 'c'}); resetNodeMap(nodeMap)
		svrToFFT := countPaths(svr, [3]byte{'f', 'f', 't'}); resetNodeMap(nodeMap)

		dac := nodeMap[[3]byte{'d', 'a', 'c'}]
		dacToFFT := countPaths(dac, [3]byte{'f', 't', 't'}); resetNodeMap(nodeMap)
		dacToOut := countPaths(dac, [3]byte{'o', 'u', 't'}); resetNodeMap(nodeMap)

		fft := nodeMap[[3]byte{'f', 'f', 't'}]
		fftToDAC := countPaths(fft, [3]byte{'d', 'a', 'c'}); resetNodeMap(nodeMap)
		fftToOut := countPaths(fft, [3]byte{'o', 'u', 't'}); resetNodeMap(nodeMap) // Not necessary

		svrPaths = svrToDAC * dacToFFT * fftToOut + svrToFFT * fftToDAC * dacToOut
	}

	fmt.printfln("Time taken: %vµs", time.duration_microseconds(time.tick_since(startTime)))

	fmt.println(outPaths)
	fmt.println(svrPaths)
}
