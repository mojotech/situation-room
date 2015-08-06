package main

import (
	"crypto/md5"
	"fmt"
	"time"
)

type Site struct {
	Id        string    `json:"id"`
	URL       string    `json:"url"`
	Email     string    `json:"email"`
	Status    string    `json:"status"`
	Duration  float64   `json:"duration"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}

func (s *Site) HashId() string {
	if 0 == len(s.Id) {
		s.Id = fmt.Sprintf("%x", md5.Sum([]byte(s.URL)))
	}
	return s.Id
}

type Check struct {
	Id        int64     `json:"id"`
	URL       string    `json:"url"`
	Response  int       `json:"response"`
	SiteId    string    `json:"siteId"`
	CreatedAt time.Time `json:"createdAt"`
}
