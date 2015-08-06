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

	oneminTimer  = time.NewTimer(onemin)
	fiveminTimer = time.NewTimer(fivemin)
	tenminTimer  = time.NewTimer(tenmin)
	onehourTimer = time.NewTimer(onehour)
)

func StartDispatcher() {
	go func() {
		for {
			select {
			case <-oneminTimer.C:
				err := ProcessCheck(onemin)
				if err != nil {
					log.Println("Failed to process checks: ", err.Error())
				}
			case <-fiveminTimer.C:
				err := ProcessCheck(fivemin)
				if err != nil {
					log.Println("Failed to process checks: ", err.Error())
				}
			case <-tenminTimer.C:
				err := ProcessCheck(tenmin)
				if err != nil {
					log.Println("Failed to process checks: ", err.Error())
				}
			case <-onehourTimer.C:
				err := ProcessCheck(onehour)
				if err != nil {
					log.Println("Failed to process checks: ", err.Error())
				}
			}
		}
	}()
}
