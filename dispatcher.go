package main

import (
	"log"
	"time"
)

var (
	onemin  = time.Minute * 1
	fivemin = time.Minute * 5
	tenmin  = time.Minute * 10
	onehour = time.Hour * 1

	oneminTicker  = time.NewTicker(onemin)
	fiveminTicker = time.NewTicker(fivemin)
	tenminTicker  = time.NewTicker(tenmin)
	onehourTicker = time.NewTicker(onehour)
)

func StartDispatcher() {
	go func() {
		for {
			select {
			case <-oneminTicker.C:
				err := ProcessCheck(onemin)
				if err != nil {
					log.Println("Failed to process checks: ", err.Error())
				}
			case <-fiveminTicker.C:
				err := ProcessCheck(fivemin)
				if err != nil {
					log.Println("Failed to process checks: ", err.Error())
				}
			case <-tenminTicker.C:
				err := ProcessCheck(tenmin)
				if err != nil {
					log.Println("Failed to process checks: ", err.Error())
				}
			case <-onehourTicker.C:
				err := ProcessCheck(onehour)
				if err != nil {
					log.Println("Failed to process checks: ", err.Error())
				}
			}
		}
	}()
}
