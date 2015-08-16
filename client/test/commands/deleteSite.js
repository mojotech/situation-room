exports.command = function(entryNum, callback) {
  this
  .click("#site-table tr:nth-child(" + entryNum + ") > td:nth-child(4) a")
  .pause(1000) // Wait for the alert
  .acceptAlert();

  if (typeof callback === 'function') {
    callback.call(this);
  }

  return this;
};
