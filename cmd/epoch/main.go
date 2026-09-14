package main

import (
	"fmt"
	"io"
	"math/big"
	"os"
	"regexp"
	"strings"
	"time"
)

const (
	unitSeconds      = "seconds"
	unitMilliseconds = "milliseconds"
	unitMicroseconds = "microseconds"
	unitNanoseconds  = "nanoseconds"
)

var (
	numericInput          = regexp.MustCompile(`^[+-]?(?:\d+(?:\.\d*)?|\.\d+)$`)
	millisecondsThreshold = big.NewRat(100_000_000_000, 1)
	microsecondsThreshold = big.NewRat(100_000_000_000_000, 1)
	nanosecondsThreshold  = big.NewRat(100_000_000_000_000_000, 1)
	nanosecondsPerSecond  = big.NewInt(1_000_000_000)
)

type config struct {
	input  string
	unit   string
	useUTC bool
}

func main() {
	os.Exit(execute(os.Args[1:], os.Stdout, os.Stderr, time.Local, time.Now))
}

func execute(args []string, stdout, stderr io.Writer, local *time.Location, now func() time.Time) int {
	options, showHelp, err := parseArgs(args)
	if showHelp {
		printUsage(stdout)
		return 0
	}
	if err != nil {
		fmt.Fprintf(stderr, "epoch: %v\nTry 'epoch --help' for more information.\n", err)
		return 2
	}

	output, err := convert(options, local, now)
	if err != nil {
		fmt.Fprintf(stderr, "epoch: %v\n", err)
		return 2
	}

	fmt.Fprint(stdout, output)
	return 0
}

func parseArgs(args []string) (config, bool, error) {
	var options config
	var input []string
	parseOptions := true

	for _, argument := range args {
		if parseOptions && argument == "--" {
			parseOptions = false
			continue
		}

		if parseOptions {
			switch argument {
			case "-h", "--help":
				return config{}, true, nil
			case "-u", "--utc":
				options.useUTC = true
				continue
			case "-s", "--seconds":
				if err := setUnit(&options, unitSeconds); err != nil {
					return config{}, false, err
				}
				continue
			case "-m", "--milliseconds":
				if err := setUnit(&options, unitMilliseconds); err != nil {
					return config{}, false, err
				}
				continue
			case "--microseconds":
				if err := setUnit(&options, unitMicroseconds); err != nil {
					return config{}, false, err
				}
				continue
			case "-n", "--nanoseconds":
				if err := setUnit(&options, unitNanoseconds); err != nil {
					return config{}, false, err
				}
				continue
			}
		}

		if parseOptions && strings.HasPrefix(argument, "-") && !numericInput.MatchString(argument) {
			return config{}, false, fmt.Errorf("unknown option %q", argument)
		}

		input = append(input, argument)
	}

	if len(input) == 0 {
		options.input = "now"
		return options, false, nil
	}

	options.input = strings.TrimSpace(strings.Join(input, " "))
	return options, false, nil
}

func setUnit(options *config, unit string) error {
	if options.unit != "" && options.unit != unit {
		return fmt.Errorf("timestamp unit options cannot be used together")
	}

	options.unit = unit
	return nil
}

func printUsage(output io.Writer) {
	fmt.Fprintln(output, `Usage: epoch [OPTIONS] [INPUT]

Convert a date or Unix timestamp in either direction. With no input, convert
the current time.

Numeric input is treated as a timestamp. Common seconds, milliseconds,
microseconds, and nanoseconds values are detected automatically. Date input
produces seconds by default. The values today, yesterday, and tomorrow resolve
to midnight. Naive and relative dates use the local timezone. Include an
explicit offset for dates during daylight-saving transitions.

Options:
  -s, --seconds       Use seconds instead of detecting the unit
  -m, --milliseconds  Use milliseconds instead of detecting the unit
      --microseconds  Use microseconds instead of detecting the unit
  -n, --nanoseconds   Use nanoseconds instead of detecting the unit
  -u, --utc           Show dates in UTC and interpret naive dates as UTC
  -h, --help          Show this help

Examples:
  epoch
  epoch yesterday
  epoch 1704067200
  epoch 1704067200000
  epoch '2024-01-01 00:00:00'
  epoch --milliseconds 2024-01-01T00:00:00.123Z`)
}

func convert(options config, local *time.Location, now func() time.Time) (string, error) {
	if numericInput.MatchString(options.input) {
		return timestampToDate(options.input, options.unit, options.useUTC, local)
	}

	value, err := parseDate(options.input, options.useUTC, local, now)
	if err != nil {
		return "", err
	}

	unit := options.unit
	if unit == "" {
		unit = unitSeconds
	}
	return formatEpoch(value, unit), nil
}

func timestampToDate(rawValue, requestedUnit string, useUTC bool, local *time.Location) (string, error) {
	value, ok := new(big.Rat).SetString(rawValue)
	if !ok {
		return "", fmt.Errorf("invalid numeric timestamp")
	}

	unit := requestedUnit
	if unit == "" {
		unit = inferTimestampUnit(value)
	}

	seconds := new(big.Rat).Set(value)
	switch unit {
	case unitMilliseconds:
		seconds.Quo(seconds, big.NewRat(1_000, 1))
	case unitMicroseconds:
		seconds.Quo(seconds, big.NewRat(1_000_000, 1))
	case unitNanoseconds:
		seconds.Quo(seconds, big.NewRat(1_000_000_000, 1))
	}

	totalNanoseconds := new(big.Rat).Mul(seconds, new(big.Rat).SetInt(nanosecondsPerSecond))
	truncatedNanoseconds := new(big.Int).Quo(totalNanoseconds.Num(), totalNanoseconds.Denom())
	wholeSeconds, remainder := new(big.Int), new(big.Int)
	wholeSeconds.QuoRem(truncatedNanoseconds, nanosecondsPerSecond, remainder)
	if remainder.Sign() < 0 {
		wholeSeconds.Sub(wholeSeconds, big.NewInt(1))
		remainder.Add(remainder, nanosecondsPerSecond)
	}
	if !wholeSeconds.IsInt64() {
		return "", fmt.Errorf("timestamp is outside the supported date range")
	}

	result := time.Unix(wholeSeconds.Int64(), remainder.Int64())
	if useUTC {
		result = result.UTC()
	} else {
		result = result.In(local)
	}

	return result.Format(time.RFC3339Nano), nil
}

func inferTimestampUnit(value *big.Rat) string {
	absolute := new(big.Rat).Abs(new(big.Rat).Set(value))

	if absolute.Cmp(nanosecondsThreshold) >= 0 {
		return unitNanoseconds
	}
	if absolute.Cmp(microsecondsThreshold) >= 0 {
		return unitMicroseconds
	}
	if absolute.Cmp(millisecondsThreshold) >= 0 {
		return unitMilliseconds
	}
	return unitSeconds
}

func parseDate(rawValue string, useUTC bool, local *time.Location, now func() time.Time) (time.Time, error) {
	if strings.EqualFold(rawValue, "now") {
		return now(), nil
	}

	location := local
	if useUTC {
		location = time.UTC
	}

	relativeDays := map[string]int{
		"yesterday": -1,
		"today":     0,
		"tomorrow":  1,
	}
	if days, ok := relativeDays[strings.ToLower(rawValue)]; ok {
		current := now().In(location)
		midnight := time.Date(current.Year(), current.Month(), current.Day(), 0, 0, 0, 0, location)
		return midnight.AddDate(0, 0, days), nil
	}

	normalized := rawValue
	if strings.HasSuffix(normalized, "z") {
		normalized = normalized[:len(normalized)-1] + "Z"
	}

	zonedLayouts := []string{
		time.RFC3339Nano,
		"2006-01-02T15:04Z07:00",
		"2006-01-02 15:04:05Z07:00",
		"2006-01-02 15:04Z07:00",
		"2006-01-02T15:04:05Z0700",
		"2006-01-02T15:04Z0700",
		"2006-01-02 15:04:05Z0700",
		"2006-01-02 15:04Z0700",
	}
	for _, layout := range zonedLayouts {
		if value, err := time.Parse(layout, normalized); err == nil {
			return value, nil
		}
	}

	naiveLayouts := []string{
		"2006-01-02T15:04:05",
		"2006-01-02T15:04",
		"2006-01-02 15:04:05",
		"2006-01-02 15:04",
		"2006-01-02",
	}
	for _, layout := range naiveLayouts {
		if value, err := time.ParseInLocation(layout, normalized, location); err == nil {
			return value, nil
		}
	}

	return time.Time{}, fmt.Errorf(
		"expected a Unix timestamp or an ISO 8601 date, such as 2025-01-30 14:00 or 2025-01-30T14:00:00Z",
	)
}

func formatEpoch(value time.Time, unit string) string {
	totalNanoseconds := new(big.Int).Mul(big.NewInt(value.Unix()), nanosecondsPerSecond)
	totalNanoseconds.Add(totalNanoseconds, big.NewInt(int64(value.Nanosecond())))

	divisor := nanosecondsPerSecond
	fractionDigits := 9
	switch unit {
	case unitMilliseconds:
		divisor = big.NewInt(1_000_000)
		fractionDigits = 6
	case unitMicroseconds:
		divisor = big.NewInt(1_000)
		fractionDigits = 3
	case unitNanoseconds:
		divisor = big.NewInt(1)
		fractionDigits = 0
	}

	sign := ""
	if totalNanoseconds.Sign() < 0 {
		sign = "-"
	}
	absolute := new(big.Int).Abs(new(big.Int).Set(totalNanoseconds))
	whole, remainder := new(big.Int), new(big.Int)
	whole.QuoRem(absolute, divisor, remainder)
	if remainder.Sign() == 0 {
		return sign + whole.String()
	}

	fraction := fmt.Sprintf("%0*s", fractionDigits, remainder.String())
	fraction = strings.TrimRight(fraction, "0")
	return fmt.Sprintf("%s%s.%s", sign, whole.String(), fraction)
}
