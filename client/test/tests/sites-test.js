module.exports = {
  before : function(client) {
    console.log('Starting sites tests.......');
  },

  beforeEach : function(client) {
    client
    .maximizeWindow()
    .timeoutsImplicitWait(10000)
    .timeouts("page load", 10000);
  },

  "Going to the new site page should show the form to enter a new site" : function(client) {
    client
    .url(client.launch_url + "sites/new")
    .verify.elementPresent("form.site-form")
    .end();
  },

  "Trying to enter a blank URL should show form errors" : function(client) {
    client
    .url(client.launch_url + "sites/new")
    .click("form input[type='submit']")
    .verify.cssClassPresent("form input.url", "form-error")
    .verify.cssProperty(".error", "display", "inline")
    .end();

  },

  "Entering a new site should show it in the sites list" : function(client) {
    client
    .createSite("http://www.mojotech.com")
    .waitForElementPresent("#site-table", 5000)
    .verify.attributeEquals("#site-table tr:first-child > td:first-child a", "href", "http://www.mojotech.com/")
    .end();
  },

  "Test that deleting a site works properly" : function(client) {
    client
    .url(client.launch_url + "sites")
    .deleteSite(1)
    .waitForElementPresent("#site-table span", 5000)
    .verify.containsText("#site-table span", "No sites listed")
    .end();
  },

  after : function(client) {
    console.log('Stopping sites tests.......');
  }
};
