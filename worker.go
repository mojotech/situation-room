package main

import (
	"errors"
	"time"
)

func ProcessCheck(interval time.Duration) error {

	sites, err := getSitesAtInterval(interval)
	if err != nil {
		return err
	}

	for _, s := range sites {
		go checkSiteStatus(s)
	}

	return nil
}

func getSitesAtInterval(interval time.Duration) ([]Site, error) {
	var sites []Site

	_, err := db.Select(&sites, "SELECT * FROM sites WHERE duration=$1", interval.Seconds())
	if err != nil {
		return nil, errors.New("Failed to get sites for processing")
	}

	return sites, nil
}
