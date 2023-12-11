package internals

import "context"

type IPDatabase interface {
	Save(ctx context.Context, ip string) error
}
type NoOPDB struct {
}

func (d *NoOPDB) Save(_ context.Context, _ string) error {
	return nil
}
