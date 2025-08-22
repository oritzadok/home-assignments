package main

import (
    "fmt"
    "k8s.io/client-go/tools/clientcmd"
    "k8s.io/client-go/kubernetes"
    corev1 "k8s.io/api/core/v1"
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "context"
)

func deployWordpress() {
    fmt.Println("Deploying WordPress and MySQL pods")

    config, err := clientcmd.BuildConfigFromFlags("", "/etc/rancher/k3s/k3s.yaml")
    if err != nil {
        panic(err)
    }
    
    client, err := kubernetes.NewForConfig(config)
    if err != nil {
        panic(err)
    }

    podClient := client.CoreV1().Pods("default")

    const (
        MYSQL_USR = "wordpress"
	MYSQL_PASS = "rootpassword"
    )

    mysqlPod := &corev1.Pod{
        ObjectMeta: metav1.ObjectMeta{
            Name: "mysql",
            Labels: map[string]string{
               "app": "wordpress",
	       "tier": "mysql",
            },
        },
        Spec: corev1.PodSpec{
            Containers: []corev1.Container{
                {
                    Name:  "mysql",
                    Image: "mysql:8.0",
                    Env: []corev1.EnvVar{
                        {
                            Name:  "MYSQL_ROOT_PASSWORD",
                            Value: MYSQL_PASS,
                        },
			{
                            Name:  "MYSQL_DATABASE",
                            Value: "wordpress",
                        },
			{
                            Name:  "MYSQL_USER",
                            Value: MYSQL_USR,
                        },
			{
                            Name:  "MYSQL_PASSWORD",
                            Value: MYSQL_PASS,
                        },
                    },
                    Ports: []corev1.ContainerPort{
                        {
                            ContainerPort: 3306,
                        },
                    },
                },
            },
        },
    }

    serviceClient := client.CoreV1().Services("default")

    mysqlService := &corev1.Service{
        ObjectMeta: metav1.ObjectMeta{
            Name: "mysql",
        },
        Spec: corev1.ServiceSpec{
            Ports: []corev1.ServicePort{
                {
                    Port: 3306,
                },
            },
            Selector: map[string]string{
                "app": "wordpress",
		"tier": "mysql",
            },
        },
    }

    mysqlService_result, err := serviceClient.Create(context.TODO(), mysqlService, metav1.CreateOptions{})
    if err != nil {
        panic(err.Error())
    }

    fmt.Printf("Created service %q\n", mysqlService_result.GetObjectMeta().GetName())

    mysqlPod_result, err := podClient.Create(context.TODO(), mysqlPod, metav1.CreateOptions{})
    if err != nil {
        panic(err.Error())
    }

    fmt.Printf("Created pod %q\n", mysqlPod_result.GetObjectMeta().GetName())

    wordpressPod := &corev1.Pod{
        ObjectMeta: metav1.ObjectMeta{
            Name: "wordpress",
	    Labels: map[string]string{
               "app": "wordpress",
            },
        },
        Spec: corev1.PodSpec{
            Containers: []corev1.Container{
                {
                    Name:  "wordpress",
                    Image: "wordpress:6.2.1-apache",
                    Env: []corev1.EnvVar{
                        {
                            Name:  "WORDPRESS_DB_HOST",
                            Value: "mysql",
                        },
                        {
                            Name:  "WORDPRESS_DB_PASSWORD",
                            Value: MYSQL_PASS,
                        },
			{
                            Name:  "WORDPRESS_DB_USER",
                            Value: MYSQL_USR,
                        },
                    },
                    Ports: []corev1.ContainerPort{
                        {
                            ContainerPort: 80,
                        },
                    },
                },
            },
        },
    }

    wordpressPod_result, err := podClient.Create(context.TODO(), wordpressPod, metav1.CreateOptions{})
    if err != nil {
        panic(err.Error())
    }

    fmt.Printf("Created pod %q\n", wordpressPod_result.GetObjectMeta().GetName())

}

