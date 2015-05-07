package main

import (
	"fmt"
	"log"
	"net/http"
	"time"
)

func startStatusCheckers() error {
	redisSites, err := redisClient.Smembers(redisScopedKey(sitesRedisKey))
	if err != nil {
		return err
	}

	log.Println(fmt.Sprintf("[INFO] %d sites found.", len(redisSites)))
	for _, s := range redisSites {
		go siteCheck(&Site{URL: string(s)})
	}

	return nil
}

func siteCheck(s *Site) {
	ticker := time.NewTicker(60 * time.Second)
	checkSiteStatus(s)
	for {
		select {
		case <-ticker.C:
			go checkSiteStatus(s)
		}
	}
}

// Hit the site URL with a HEAD request and update appropriate fields
func checkSiteStatus(s *Site) {
	s.PreviousStatus = s.Status

	resp, err := http.Head(s.URL)
	if err != nil {
		log.Println("[ERROR] Problem creating new HTTP request:", err.Error())
		return
	}

	s.Status = resp.Status
	s.StatusCode = resp.StatusCode
	s.LastCheck = time.Now()
	log.Println("[DEBUG]", s.URL, s.Status)
}
