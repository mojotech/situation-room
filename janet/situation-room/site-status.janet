(use joy)
(import http)

(defn check-site-status
  [site]
  (let [start-time (os/clock)
        status (http/get (get site :url))
        end-time (os/clock)]
    {:status-code (get status :status)
     :response-time (- end-time start-time)}))

(defn check-site-with-timer
  [site timer]
  (ev/sleep timer)
  (check-site-status site))

(defn- write-site-check
  [site status]
  (db/insert :checks {:url (get site :url)
                      :response (get status :status-code)
                      :response_time (get status :response-time)
                      :site_id (get site :id)}))

(defn- maybe-write-site-status
  [site status]
  (let [site-id (get site :id)
       status-code (get status :status-code)]
    (if-not (= (get site :status) status-code)
        (db/update :sites site-id {:status status-code}))
    status))

(defn update-site-status
  "Check the site status, and insert a new site check record into the DB"
  [site]
  (->> site
      (check-site-status)
      (maybe-write-site-status site)
      (write-site-check site)))
