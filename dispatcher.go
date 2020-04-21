package main

import (
	"fmt"
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
	siteCheckers = make(map[string]SiteCheck)
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
	siteCheckers[s.Id] = sc

	log.Println("[DEBUG] Launching site checker for:", s.URL)
	go func() {
		for {
			select {
			case <-sc.channel:
				log.Println("Site checker exiting for site:", s.Id)
				return
			case _ = <-sc.ticker.C:
				CheckSiteStatus(s)
			}
		}
	}()

	return nil
}

// RemoveSiteChecker will remove a Site from the current list of site checks
// and clean up after itself (stop tickers, close channels, end goroutines, etc...)
func RemoveSiteChecker(siteID string) error {
	sc, found := siteCheckers[siteID]
	if !found {
		return fmt.Errorf("site checker not found for site: %s", siteID)
	}

	sc.ticker.Stop()   // Stop the ticker
	sc.channel <- true // Stop the goroutine
	delete(siteCheckers, siteID)

	return nil
}
