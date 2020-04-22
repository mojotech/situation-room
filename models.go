package main

import (
	"crypto/md5"
	"encoding/json"
	"fmt"
	"time"
)

// Site represents a website to check the uptime status of
type Site struct {
	Id        string    `json:"id"`
	URL       string    `json:"url"`
	Email     string    `json:"email"`
	Status    string    `json:"status"`
	Duration  float64   `json:"duration"`
	CreatedAt time.Time `json:"-"`
	UpdatedAt time.Time `json:"-"`
}

// HashId converts the URL of a Site into a unique identifier
func (s *Site) HashId() string {
	if 0 == len(s.Id) {
		s.Id = fmt.Sprintf("%x", md5.Sum([]byte(s.URL)))
	}
	return s.Id
}

// Check represents an individual uptime check of a Site
type Check struct {
	Id           int64     `json:"-"`
	URL          string    `json:"-"`
	Response     int       `json:"response"`
	ResponseTime int64     `json:"responseTime"`
	SiteId       string    `json:"-"`
	CreatedAt    time.Time `json:"createdAt"`
}

// MarshalJSON customizes the JSON marshaling of our time.Time fields
func (c *Check) MarshalJSON() ([]byte, error) {
	type Alias Check
	return json.Marshal(&struct {
		CreatedAt int64 `json:"createdAt"`
		*Alias
	}{
		CreatedAt: c.CreatedAt.Unix(),
		Alias:     (*Alias)(c),
	})
}
