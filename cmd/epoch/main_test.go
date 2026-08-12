package main

import (
	"bytes"
	"strings"
	"testing"
	"time"
)

func TestConversions(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name     string
		args     []string
		expected string
	}{
		{
			name:     "seconds timestamp",
			args:     []string{"1704067200"},
			expected: "2024-01-01T00:00:00Z",
		},
		{
			name:     "milliseconds timestamp",
			args:     []string{"1704067200000"},
			expected: "2024-01-01T00:00:00Z",
		},
		{
			name:     "fractional milliseconds timestamp",
			args:     []string{"1704067200123.5"},
			expected: "2024-01-01T00:00:00.1235Z",
		},
		{
			name:     "microseconds timestamp",
			args:     []string{"1786368920155451"},
			expected: "2026-08-10T13:35:20.155451Z",
		},
		{
			name:     "nanoseconds timestamp",
			args:     []string{"1786368920155451000"},
			expected: "2026-08-10T13:35:20.155451Z",
		},
		{
			name:     "large precise seconds timestamp",
			args:     []string{"--seconds", "9999999999.999999"},
			expected: "2286-11-20T17:46:39.999999Z",
		},
		{
			name:     "negative numeric timestamp",
			args:     []string{"-0.5"},
			expected: "1969-12-31T23:59:59.5Z",
		},
		{
			name:     "naive date to seconds",
			args:     []string{"2024-01-01 00:00:00"},
			expected: "1704067200",
		},
		{
			name:     "date to milliseconds",
			args:     []string{"--milliseconds", "2024-01-01T00:00:00.123Z"},
			expected: "1704067200123",
		},
		{
			name:     "date to microseconds",
			args:     []string{"--microseconds", "2024-01-01T00:00:00.123456Z"},
			expected: "1704067200123456",
		},
		{
			name:     "date to nanoseconds",
			args:     []string{"--nanoseconds", "2024-01-01T00:00:00.123456789Z"},
			expected: "1704067200123456789",
		},
		{
			name:     "explicit offset",
			args:     []string{"2024-01-01T01:00:00+01:00"},
			expected: "1704067200",
		},
		{
			name:     "explicit offset without colon",
			args:     []string{"2024-01-01T01:00:00+0100"},
			expected: "1704067200",
		},
		{
			name:     "unquoted date",
			args:     []string{"2024-01-01", "00:00:00Z"},
			expected: "1704067200",
		},
		{
			name:     "explicit ambiguous unit",
			args:     []string{"--milliseconds", "100000000"},
			expected: "1970-01-02T03:46:40Z",
		},
		{
			name:     "fractional date before epoch",
			args:     []string{"1969-12-31T23:59:59.5Z"},
			expected: "-0.5",
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			stdout, stderr, status := runCLI(test.args, time.UTC)
			if status != 0 {
				t.Fatalf("execute() status = %d, stderr = %q", status, stderr)
			}
			if strings.TrimSpace(stdout) != test.expected {
				t.Errorf("execute() output = %q, want %q", strings.TrimSpace(stdout), test.expected)
			}
		})
	}
}

func TestNaiveDateUsesLocalTimezone(t *testing.T) {
	location, err := time.LoadLocation("America/New_York")
	if err != nil {
		t.Fatal(err)
	}

	stdout, stderr, status := runCLI([]string{"2024-01-01 00:00:00"}, location)
	if status != 0 {
		t.Fatalf("execute() status = %d, stderr = %q", status, stderr)
	}
	if strings.TrimSpace(stdout) != "1704085200" {
		t.Errorf("execute() output = %q, want %q", strings.TrimSpace(stdout), "1704085200")
	}
}

func TestMicrosecondsTimestampUsesLocalTimezone(t *testing.T) {
	location, err := time.LoadLocation("America/New_York")
	if err != nil {
		t.Fatal(err)
	}

	stdout, stderr, status := runCLI([]string{"1786368920155451"}, location)
	if status != 0 {
		t.Fatalf("execute() status = %d, stderr = %q", status, stderr)
	}
	if strings.TrimSpace(stdout) != "2026-08-10T09:35:20.155451-04:00" {
		t.Errorf("execute() output = %q, want local microseconds conversion", strings.TrimSpace(stdout))
	}
}

func TestUTCControlsTimestampOutput(t *testing.T) {
	local := time.FixedZone("test", -5*60*60)
	stdout, stderr, status := runCLI([]string{"--utc", "1704067200"}, local)
	if status != 0 {
		t.Fatalf("execute() status = %d, stderr = %q", status, stderr)
	}
	if strings.TrimSpace(stdout) != "2024-01-01T00:00:00Z" {
		t.Errorf("execute() output = %q, want UTC output", strings.TrimSpace(stdout))
	}
}

func TestErrors(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name       string
		args       []string
		errorMatch string
	}{
		{name: "missing input", errorMatch: "missing date or timestamp"},
		{name: "unknown option", args: []string{"--nope", "1"}, errorMatch: "unknown option"},
		{
			name:       "conflicting units",
			args:       []string{"--seconds", "--milliseconds", "1"},
			errorMatch: "cannot be used together",
		},
		{name: "invalid date", args: []string{"not a date"}, errorMatch: "expected a Unix timestamp"},
		{
			name:       "timestamp below supported range",
			args:       []string{"--seconds", "-9223372036854775808.5"},
			errorMatch: "outside the supported date range",
		},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			_, stderr, status := runCLI(test.args, time.UTC)
			if status != 2 {
				t.Errorf("execute() status = %d, want 2", status)
			}
			if !strings.Contains(stderr, test.errorMatch) {
				t.Errorf("execute() stderr = %q, want it to contain %q", stderr, test.errorMatch)
			}
		})
	}
}

func TestHelp(t *testing.T) {
	t.Parallel()

	stdout, stderr, status := runCLI([]string{"--help"}, time.UTC)
	if status != 0 {
		t.Errorf("execute() status = %d, want 0", status)
	}
	if stderr != "" {
		t.Errorf("execute() stderr = %q, want empty", stderr)
	}
	if !strings.Contains(stdout, "Usage: epoch") {
		t.Errorf("execute() output = %q, want usage", stdout)
	}
}

func runCLI(args []string, local *time.Location) (string, string, int) {
	var stdout bytes.Buffer
	var stderr bytes.Buffer
	status := execute(
		args,
		&stdout,
		&stderr,
		local,
		func() time.Time { return time.Date(2024, 1, 1, 0, 0, 0, 0, time.UTC) },
	)
	return stdout.String(), stderr.String(), status
}
