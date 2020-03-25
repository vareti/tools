package main

import (
	"fmt"
	"io/ioutil"
	"os"

	"k8s.io/apiserver/pkg/server/dynamiccertificates"
	"k8s.io/client-go/util/cert"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Printf("Usage: %s <cert bundle file path>\n", os.Args[0])
		return
	}

	data, err := ioutil.ReadFile(os.Args[1])
	if err != nil {
		fmt.Printf("Reading file failed with error: %v", err)
		return
	}

	certificates, err := cert.ParseCertsPEM([]byte(data))
	if err != nil {
		fmt.Printf("error parsing certs: %v\n", err)
		return
	}

	fmt.Printf("Found %d certificates in the bundle\n", len(certificates))

	for _, certificate := range certificates {
		fmt.Printf("%s\n", dynamiccertificates.GetHumanCertDetail(certificate))
	}

}
