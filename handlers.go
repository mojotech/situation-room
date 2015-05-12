package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/labstack/echo"
)

type StatusPostInput struct {
	URL   string `json:"url"`
	Email string `json:"email"`
}

type SitesResponse struct {
	Sites []Site `json:"sites"`
}

type SiteResponse struct {
	SiteKey  string  `json:"site_key"`
	Statuses []int64 `json:"statuses"`
}

// GET /sites
//
// response:
//   sites: <array> sites registered with the system
func sitesHandler(c *echo.Context) error {
	return c.JSON(http.StatusOK, &SitesResponse{Sites: AllSites})
}

// POST /sites
//
// params:
//   url: <string, required> website url to check
//	 email: <string, options> email address to alert on status changes
//
// response:
//   site: <json> newly created site info
func createSiteHandler(c *echo.Context) error {
	var params StatusPostInput
	d := json.NewDecoder(c.Request().Body)
	err := d.Decode(&params)
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "Unable to decode JSON body")
	}

	params.URL = strings.TrimSpace(params.URL)
	params.Email = strings.TrimSpace(params.Email)

	if 0 == len(strings.TrimSpace(params.URL)) {
		return c.JSON(http.StatusBadRequest, "URL parameter required")
	}

	newSite, err := redisClient.Sadd(redisScopedKey(sitesRedisKey), []byte(params.URL))
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Problem saving your new site")
	}

	if len(params.Email) > 0 {
		_, err = redisClient.Hset(redisScopedKey(emailsRedisKey), params.URL, []byte(params.Email))
		if err != nil {
			return echo.NewHTTPError(http.StatusInternalServerError, "Problem saving your site email address to alert")
		}
	}

	site := &Site{URL: params.URL}
	if newSite {
		go siteCheck(*site)
		AllSites = append(AllSites, *site)
	}
	return c.JSON(http.StatusCreated, site)
}

// GET /sites/:key
//
// response:
//	 site_key: <string> site hash key
//	 statuses: <array> chronologically ordered status codes from recent checks
func siteHandler(c *echo.Context) error {
	siteKey := c.P(0)
	redisKey := redisScopedKey(fmt.Sprintf("%s:%s", uptimeRedisKey, siteKey))

	rawStatuses, err := redisClient.Lrange(redisKey, 0, minutesInMonth)
	if err != nil {
		handleError(http.StatusInternalServerError, "Problem retrieving statuses", err)
	}

	statuses := make([]int64, len(rawStatuses))
	for i, s := range rawStatuses {
		statuses[i], err = strconv.ParseInt(string(s), 10, 16)
		if err != nil {
			statuses[i] = 0
		}
	}

	resp := SiteResponse{Statuses: statuses, SiteKey: siteKey}

	return c.JSON(http.StatusOK, resp)
}

func handleError(code int, message string, e error) *echo.HTTPError {
	err := &echo.HTTPError{
		Code:    code,
		Message: message,
		Error:   e,
	}
	return err
}
