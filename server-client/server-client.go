package main

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

type handler struct {

}

func (h *handler) ServeHTTP(rw http.ResponseWriter, req *http.Request) {
	rw.Write([]byte(`!! Valid request !!`))
}
// server
func server(ctx context.Context, startCh, stopCh chan bool) {
	log.Print("starting server")
	server := http.Server{Addr: "127.0.0.1:9090", Handler: &handler{}}
	go server.ListenAndServe()

	startCh <- true

	<-ctx.Done()
	if err := server.Shutdown(ctx); err != nil {
		log.Print(err)
	}
	log.Print("stopping server")
	close(stopCh)
}

func httpClient(ctx context.Context) {
	client := &http.Client{}
	resp, err := client.Get("http://127.0.0.1:9090")
	if err != nil {
		log.Print(err)
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Print(err)
	}

	log.Printf("response for http client is %s", body)
}

// https client
func httpsClient(ctx context.Context) {
	caPool, err := x509.SystemCertPool()
	if err != nil {
		log.Print(err)
		return
	}

	transport := &http.Transport{
		TLSClientConfig: &tls.Config {
			RootCAs: caPool,
		},
	}

	client := &http.Client {
		Transport: transport,
	}

	resp, err := client.Get("http://127.0.0.1:9090")
	if err != nil {
		log.Print(err)
		return
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Print(err)
		return
	}

	log.Printf("response for https client is %s", body)
}

func main() {
	stopCh := make(chan bool)
	startCh := make(chan bool)
	ctx, cancel := context.WithCancel(context.TODO())

	go server(ctx, startCh, stopCh)

	<-startCh
	httpClient(ctx)
	httpsClient(ctx)
	cancel()

	<-stopCh

	err := fmt.Errorf("test")
	log.Printf("%q", err)
}
