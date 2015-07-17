package main

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/labstack/echo"
)

type StatusPostInput struct {
	URL   string `json:"url"`
	Email string `json:"email"`
}

type Site struct {
	URL        string `json:"url"`
	Status     string `json:"status"`
	LastStatus string `json:"-"`
	LastCheck  string `json:"last_checked_at"`
}

type SitesResponse struct {
	Sites []Site `json:"sites"`
}

// GET /status
//
// response:
//   sites: <array> sites registered with the system
func statusHandler(c *echo.Context) *echo.HTTPError {
	redisSites, err := redisClient.Smembers(redisScopedKey(sitesRedisKey))
	if err != nil {
		return handleError(http.StatusInternalServerError, "Problem retrieving list of sites", err)
	}

	sites := make([]Site, len(redisSites))
	for i, s := range redisSites {
		sites[i] = Site{URL: string(s)}
	}

	return c.JSON(http.StatusOK, &SitesResponse{Sites: sites})
}

// POST /status
//
// params:
//   url: <string, required> website url to check
//	 email: <string, options> email address to alert on status changes
//
// response:
//   site: <json> newly created site info
func createStatusHandler(c *echo.Context) *echo.HTTPError {
	var params StatusPostInput
	d := json.NewDecoder(c.Request().Body)
	err := d.Decode(&params)
	if err != nil {
		return handleError(http.StatusBadRequest, "Unable to decode JSON body", err)
	}

	params.URL = strings.TrimSpace(params.URL)
	params.Email = strings.TrimSpace(params.Email)

	if 0 == len(strings.TrimSpace(params.URL)) {
		return c.JSON(http.StatusBadRequest, "URL parameter required")
	}

	// NOTE: We dont care if this URL already existed, so we don't check the first `bool` return value.
	// The redis lib returns a bool if the return code from SADD was 1.  It will be 0 if the url was already
	// in the set.
	_, err = redisClient.Sadd(redisScopedKey(sitesRedisKey), []byte(params.URL))
	if err != nil {
		return handleError(http.StatusInternalServerError, "Problem saving your new site", err)
	}

	// See NOTE above about ignoring the bool return value here as well
	if len(params.Email) > 0 {
		_, err = redisClient.Hset(redisScopedKey(emailsRedisKey), params.URL, []byte(params.Email))
		if err != nil {
			return handleError(http.StatusInternalServerError, "Problem saving your site email address to alert", err)
		}
	}

	return c.JSON(http.StatusCreated, &Site{URL: params.URL})
}

func handleError(code int, message string, e error) *echo.HTTPError {
	err := &echo.HTTPError{
		Code:    code,
		Message: message,
		Error:   e,
	}
	return err
}
