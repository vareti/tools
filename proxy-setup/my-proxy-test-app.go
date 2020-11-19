package main

import (
	"crypto/tls"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/elazarl/goproxy"
)

func runProxyServer() (*http.Server, error) {
	proxyHandler := goproxy.NewProxyHttpServer()
	proxyHandler.Verbose = true
	proxyServer := &http.Server{
		Addr: "localhost:8080",
		Handler: proxyHandler,
	}
	log.Print("starting the proxy server")
	var err error
	go func() {
		err = proxyServer.ListenAndServe()
	}()
	return proxyServer, err
}

func checkProxySetup() {
	proxyServer, err := runProxyServer()
	if err != nil {
		log.Fatal(err)
	}

	if err = os.Setenv("HTTP_PROXY", proxyServer.Addr); err != nil {
		log.Fatal(err)
	}

	client := http.Client {
		Timeout: 5*time.Second,
		Transport: &http.Transport{
			Proxy: http.ProxyFromEnvironment,
			TLSClientConfig: &tls.Config{
				InsecureSkipVerify: true,
			},
		},
	}

	req, err := http.NewRequest(http.MethodGet, "https://google.com", nil)
	if err != nil {
		log.Fatal(err)
	}

	resp, err := client.Do(req)
	if err != nil {
		log.Fatal(err)
	}

	if resp.StatusCode < 200 || resp.StatusCode > 299 {
		log.Fatal(resp)
	}

	log.Printf("connection check complete")
	log.Print("closing the proxy server")
	defer proxyServer.Close()
}

func main() {
	checkProxySetup()
}