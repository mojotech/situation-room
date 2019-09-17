package main

import (
	"log"
	"net/http"
	"time"
)

// ErrorStatus represents the default Site status when http errors occur
const ErrorStatus = "ERROR"

// Hit the site URL with a HEAD request and update appropriate fields
func checkSiteStatus(s Site) {
	// If this is an invalid Site config, don't even bother checking
	if ErrorStatus == s.Status {
		return
	}

	resp, err := http.Head(s.URL)
	if err != nil {
		s.Status = ErrorStatus
		log.Println("[ERROR] Problem creating new HTTP request:", err.Error())
		return
	}

	s.Status = resp.Status

	err = s.logStat(resp.StatusCode)
	if err != nil {
		log.Println("[WARN] Error logging stat:", err.Error())
	}

	log.Println("[DEBUG]", s.URL, s.Status)
}

func (s Site) logStat(status int) error {
	var check Check
	check.SiteId = s.Id
	check.Response = status
	check.URL = s.URL
	check.CreatedAt = time.Now()
	err := db.Insert(&check)
	return err
}
