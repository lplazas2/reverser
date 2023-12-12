package internals

import (
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"strings"
)

type ReverseService struct {
	db IPDatabase
}

func NewReverseService(db IPDatabase) *ReverseService {
	return &ReverseService{db: db}
}

func (s *ReverseService) ReverseIP(r *http.Request) (string, error) {
	// request goes through many reverse proxies, the original IP is usually preserved in X-Forwarded-For
	ip := r.Header.Get("X-Forwarded-For")
	if ip == "" {
		ip = r.Header.Get("X-Real-Ip")
	}
	if ip == "" {
		ip = r.RemoteAddr
	}

	// if there is more than one originating IP, select the leftmost: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For#proxy1_proxy2
	if strings.Contains(ip, ",") {
		slog.Warn("received many IPs", "ips", ip)
		ip = strings.TrimSpace(strings.Split(ip, ",")[0])
	}

	// remove port if included
	if strings.Contains(ip, ":") {
		ip = strings.Split(ip, ":")[0]
	}

	ipAdd := net.ParseIP(ip)
	if ipAdd == nil {
		slog.Error("failed ip is", "ip", ip)
		return "", fmt.Errorf("failed parsing ip address")
	}

	if ip4 := ipAdd.To4(); ip4 != nil {
		reversed := ReverseIP(ip4)

		if err := s.db.Save(r.Context(), reversed); err != nil {
			return "", fmt.Errorf("failed db save, err: %w", err)
		}
		return reversed, nil
	} else {
		// TODO It is an ipv6 address
		return "", fmt.Errorf("ipv6 addressesa are not supported, err: %w", NotImplementedError{})
	}
}

func ReverseIP(ip net.IP) string {
	return fmt.Sprintf("%d.%d.%d.%d", uint(ip[3]), uint(ip[2]), uint64(ip[1]), uint64(ip[0]))
}
