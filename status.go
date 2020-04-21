package main

import (
	"log"
	"net/http"
	"net/http/httptrace"
	"time"
)

// ErrorStatus represents the default Site status when http errors occur
const ErrorStatus = "ERROR"

// ConfigErrorStatus represents a site that is unreachable due to back data
const ConfigErrorStatus = "CONFIG ERROR"

// CheckSiteStatus will hit the site URL with a HEAD request and update appropriate fields
func CheckSiteStatus(s Site) {
	// If this is an invalid Site config, don't even bother checking
	if ConfigErrorStatus == s.Status {
		return
	}

	req, _ := http.NewRequest("GET", s.URL, nil)
	var start time.Time
	trace := &httptrace.ClientTrace{
		GotFirstResponseByte: func() {
			log.Printf("Time to first byte: %v\n", time.Since(start))
		},
	}
	req = req.WithContext(httptrace.WithClientTrace(req.Context(), trace))
	start = time.Now()
	resp, err := http.DefaultTransport.RoundTrip(req)
	if err != nil {
		if s.Status != ErrorStatus {
			s.Status = ErrorStatus
			_, _ = db.Update(&s)
		}
		// 2019/09/19 11:17:33 [ERROR] Problem creating new HTTP request: dial tcp: lookup api2.mojotech.com: no such host
		log.Println("[ERROR] Problem creating new HTTP request:", err.Error())
		return
	}
	log.Printf("Total time: %v\n", time.Since(start))

	err = s.logStat(resp.StatusCode, time.Since(start))
	if err != nil {
		log.Println("[WARN] Error logging stat:", err.Error())
	}

	// If we have a new status code, update the Site record
	if s.Status != resp.Status {
		s.Status = resp.Status
		_, _ = db.Update(&s)
	}

	log.Println("[DEBUG]", s.URL, s.Status)
}

func (s Site) logStat(status int, responseTime time.Duration) error {
	var check Check
	check.SiteId = s.Id
	check.Response = status
	check.ResponseTime = toMilliseconds(responseTime)
	check.URL = s.URL
	check.CreatedAt = time.Now()
	err := db.Insert(&check)
	return err
}

// NOTE: This method was added to `time` in Go 1.13 - so I'm just
// backporting it here for my use-case
//
// Milliseconds returns the duration as an integer millisecond count.
// func (d Duration) Milliseconds() int64 { return int64(d) / 1e6 }
func toMilliseconds(d time.Duration) int64 { return int64(d) / 1e6 }
