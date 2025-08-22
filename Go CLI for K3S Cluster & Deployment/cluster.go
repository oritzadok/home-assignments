package main

import (
    "fmt"
    "log"
    "os"
    "os/exec"
)

func createK3sCluster() {
    fmt.Println("Creating a k3s Kubernetes cluster")

    cmd := exec.Command("bash", "-c", "curl -sfL https://get.k3s.io | sh -")
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr
   
    fmt.Println("Executing command:", cmd)

    err := cmd.Run()
    if err != nil {
        log.Fatal("Failed to create k3s cluster: ", err)
    }
}
