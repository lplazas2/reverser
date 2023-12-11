package internals

import (
	"net"
	"testing"
)

func TestReverse(t *testing.T) {
	tests := []struct {
		name  string
		input string
		want  string
	}{
		{
			name:  "Basic reverse",
			input: "1.2.3.4",
			want:  "4.3.2.1",
		},
		{
			name:  "Reverse with 2 and 3 digits, ending in 0",
			input: "10.100.90.200",
			want:  "200.90.100.10",
		},
		{
			name:  "Reverse of numbers that would be invalid if fully reversed",
			input: "128.219.158.255",
			want:  "255.158.219.128",
		},
		{
			name:  "Palindrome reverse",
			input: "1.2.2.1",
			want:  "1.2.2.1",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := ReverseIP(net.ParseIP(tt.input).To4()); got != tt.want {
				t.Errorf("ReverseIP() = %v, want %v", got, tt.want)
			}
		})
	}
}
