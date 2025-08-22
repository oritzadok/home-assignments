package main

import (
    "fmt"
    "k8s.io/client-go/tools/clientcmd"
    "k8s.io/client-go/kubernetes"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "context"
)

func podStatus() {
    fmt.Println("Printing Wordpress pod names and status in default namespace")

    config, err := clientcmd.BuildConfigFromFlags("", "/etc/rancher/k3s/k3s.yaml")
    if err != nil {
        panic(err)
    }
    
    client, err := kubernetes.NewForConfig(config)
    if err != nil {
        panic(err)
    }

    podsClient := client.CoreV1().Pods("default")

    pods, err := podsClient.List(context.TODO(), metav1.ListOptions{LabelSelector: "app=wordpress"})
    if err != nil {
        panic(err.Error())
    }
   
    if len(pods.Items) > 0 {
    	fmt.Printf("%-30s %-15s\n", "POD NAME", "STATUS")
   	for _, pod := range pods.Items {
		fmt.Printf("%-30s %-15s\n", pod.Name, pod.Status.Phase)
    	}
    }
}

