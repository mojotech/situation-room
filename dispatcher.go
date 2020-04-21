package main

import (
	"log"
	"time"
)

// SiteCheck is a container for tracking, starting, and stopping
// running site checks
type SiteCheck struct {
	siteID  string
	channel chan bool
	ticker  *time.Ticker
}

var (
	siteCheckers = []SiteCheck{}
)

// StartDispatcher will spin off one goroutine per site being checked
func StartDispatcher() error {
	var sites []Site

	_, err := db.Select(&sites, "SELECT * FROM sites")
	if err != nil {
		return err
	}

	for _, s := range sites {
		DispatchNewSite(s)
	}

	return nil
}

// DispatchNewSite will add the Site provided to the current
// list of sites in process
func DispatchNewSite(s Site) error {
	c := make(chan bool)
	t := time.NewTicker(time.Minute * time.Duration(int64(s.Duration/time.Minute.Seconds())))
	sc := SiteCheck{s.Id, c, t}
	siteCheckers = append(siteCheckers, sc)

	log.Println("[DEBUG] Launching site checker for:", s.URL)
	go func() {
		for {
			select {
			case <-sc.channel:
				log.Printf("Site checker exiting for site:", s.Id)
				return
			case _ = <-sc.ticker.C:
				CheckSiteStatus(s)
			}
		}
	}()

	return nil
}
