package main

import (
	"testing"
)

func Test_runProxyServer(t *testing.T) {
	// tests := []struct {
	// 	name    string
	// 	count int
	// 	ans int
	// }{
	// 	// TODO: Add test cases.
	// 	{
	// 		name: "a",
	// 		count: 10,
	// 		ans: 10,
	// 	},
	// 	{
	// 		name: "b",
	// 		count: 20,
	// 		ans: 20,
	// 	},
	// }
	idx := 10
	for i := 0; i < 10; i++ {

		t.Run("test", func(t *testing.T) {
			defer func() {
				idx++
			}()

			t.Logf("%d", idx)
		})
	}

	if idx != 20 {
		t.Fatal("failed")
	}
}
