package utils

import (
  "log"
  "os"
)

func ExitErrorf(msg string, args ...interface{}) {
  log.Printf(msg)
  os.Exit(1)
}
