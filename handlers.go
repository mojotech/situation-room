package main

import (
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/labstack/echo"
)

// GET /sites
// response:
//   sites: <array> sites registered with the system
func sitesHandler(c *echo.Context) error {
	return c.JSON(http.StatusOK, AllSites)
}

// POST /sites
//
// params:
//   url: <string, required> website url to check
//   email: <string, options> email address to alert on status changes
//
// response:
//   site: <json> newly created site info
func createSiteHandler(c *echo.Context) error {
	var site Site
	err := c.Bind(&site)
	if err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "Unable to decode JSON body")
	}

	site.HashId()
	site.URL = strings.TrimSpace(site.URL)
	site.Email = strings.ToLower(strings.TrimSpace(site.Email))
	site.CreatedAt = time.Now()
	site.UpdatedAt = time.Now()

	if 0 == len(strings.TrimSpace(site.URL)) {
		return c.JSON(http.StatusBadRequest, "Url parameter required")
	}

	err = db.Insert(&site)
	if err != nil {
		log.Fatalf("Problem saving new site", err)
		return echo.NewHTTPError(http.StatusInternalServerError, "Problem saving your new site")
	}

	go siteCheck(site)
	AllSites = append(AllSites, site)
	return c.JSON(http.StatusCreated, site)
}

// GET /sites/:key
//
// response:
//	 site_key: <string> site hash key
//	 statuses: <array> chronologically ordered status codes from recent checks
func siteHandler(c *echo.Context) error {
	siteKey := c.P(0)
	var site Site

	err := db.SelectOne(&site, "SELECT * FROM sites WHERE id=$1", siteKey)
	if err != nil {
		return echo.NewHTTPError(http.StatusNotFound, "Site not found")
	}

	return c.JSON(http.StatusOK, site)
}

// GET /sites/:key/checks
func checksHandler(c *echo.Context) error {
	siteKey := c.P(0)
	var checks []Check

	_, err := db.Select(&checks, "SELECT * FROM checks WHERE siteId=$1", siteKey)
	if err != nil {
		return echo.NewHTTPError(http.StatusNotFound, "No checks found for site")
	}

	return c.JSON(http.StatusOK, checks)
}
