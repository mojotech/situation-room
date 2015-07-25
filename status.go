package main

import (
	"fmt"
	"log"
	"net/http"
	"strconv"
	"time"
)

const ERROR_STATUS = "ERROR"

var (
	minutesInDay   = 60 * 24
	minutesInWeek  = 7 * minutesInDay
	minutesInMonth = 30 * minutesInDay
)

func startStatusCheckers(sites []Site) error {
	for _, s := range sites {
		fmt.Println("**", s.URL)
		go siteCheck(s)
	}

	return nil
}

func siteCheck(s Site) {
	fmt.Println("!!", s.URL)
	ticker := time.NewTicker(60 * time.Second)
	checkSiteStatus(s)
	for {
		if ERROR_STATUS == s.Status {
			break
		}
		select {
		case <-ticker.C:
			go checkSiteStatus(s)
		default:
			if !contains(AllSites, s) {
				ticker.Stop()
				break
			}
		}
	}
}

// Hit the site URL with a HEAD request and update appropriate fields
func checkSiteStatus(s Site) {
	// If this is an invalid Site config, don't even bother checking
	if ERROR_STATUS == s.Status {
		return
	}

	s.PreviousStatus = s.Status

	resp, err := http.Head(s.URL)
	if err != nil {
		s.Status = ERROR_STATUS
		log.Println("[ERROR] Problem creating new HTTP request:", err.Error())
		return
	}

	s.Status = resp.Status
	s.StatusCode = resp.StatusCode
	s.LastCheck = time.Now()

	err = s.LogStat(uptimeRedisKey, []byte(strconv.Itoa(s.StatusCode)))
	if err != nil {
		log.Println("[WARN] Error logging stat:", err.Error())
	}

	log.Println("[DEBUG]", s.URL, s.Status)
}

func (s Site) LogStat(statKey string, val []byte) error {
	k := redisScopedKey(fmt.Sprintf("%s:%s", statKey, s.HashKey()))

	// When using LPUSH + LTRIM immediately this is really an O(1) operation because in the average
	// case just one element is removed from the tail of the list
	err := redisClient.Lpush(k, val)
	if err != nil {
		return err
	}
	err = redisClient.Ltrim(k, 0, minutesInMonth)
	return err
}

// Helper function
func contains(sites []Site, s Site) bool {
	for i := range sites {
		if sites[i] == s {
			return true
		}
	}
	return false
}
