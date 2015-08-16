exports.command = function(siteUrl, callback) {
  this
  .url(this.launch_url + "sites/new")
  .setValue("form input.url", siteUrl)
  .click("form input[type='submit']");

  if (typeof callback === 'function') {
    callback.call(this);
  }

  return this;
};
