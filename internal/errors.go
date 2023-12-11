package internals

type NotImplementedError struct {
	message string
}

func NotImplErr(message string) *NotImplementedError {
	return &NotImplementedError{
		message: message,
	}
}

func (e NotImplementedError) Error() string {
	return e.message
}
