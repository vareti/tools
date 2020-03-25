package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"time"

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
		fmt.Printf("Issuer CommonName %s\n", certificate.Issuer.CommonName)
		fmt.Printf("Subject CommonName %s\n", certificate.Subject.CommonName)
		fmt.Printf("NotBefore %s\n", certificate.NotBefore.String())
		fmt.Printf("NotAfter %s\n\n", certificate.NotAfter.String())
	}

	fmt.Printf("Current time : %s\n\n", time.Now().UTC())
}
