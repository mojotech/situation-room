package main

import (
	"log"
	"net/http"
	"time"
)

const ERROR_STATUS = "ERROR"

// Hit the site URL with a HEAD request and update appropriate fields
func checkSiteStatus(s Site) {
	// If this is an invalid Site config, don't even bother checking
	if ERROR_STATUS == s.Status {
		return
	}

	resp, err := http.Head(s.URL)
	if err != nil {
		s.Status = ERROR_STATUS
		log.Println("[ERROR] Problem creating new HTTP request:", err.Error())
		return
	}

	s.Status = resp.Status

	err = s.LogStat(resp.StatusCode)
	if err != nil {
		log.Println("[WARN] Error logging stat:", err.Error())
	}

	log.Println("[DEBUG]", s.URL, s.Status)
}

func (s Site) LogStat(status int) error {
	var check Check
	check.SiteId = s.Id
	check.Response = status
	check.URL = s.URL
	check.CreatedAt = time.Now()
	err := db.Insert(&check)
	return err
}
