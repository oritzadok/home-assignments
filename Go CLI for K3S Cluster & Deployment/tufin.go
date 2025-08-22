package main

import (
    "fmt"
    "os"
)

func main() {
    if len(os.Args) != 2 {
        fmt.Println("Usage: tufin <command>")
        os.Exit(1)
    }

    command := os.Args[1]

    switch(command) {
        case "cluster":
            createK3sCluster()

        case "deploy":
            deployWordpress()

        case "status":
            podStatus()

        default:
            fmt.Println("Unknown command:", command)
            os.Exit(1)
    }
}

