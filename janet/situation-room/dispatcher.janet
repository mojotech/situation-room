(use joy)
(use ./site-status)

(dyn :all-sites @())

(defn- dispatch-site
  [site]
  (let [site-url (get site :url)
        site-duration (get site :duration)]
    (printf "[dispatcher] Dispatching new site: %s with interval: %d" site-url site-duration)
    (ev/spawn
      (forever
        (check-site-with-timer site site-duration)))))

(defn start-dispatcher
  "Start a site checker for every tracked site."
  [sites]
  (each site sites (dispatch-site site))
  (->> sites
       (setdyn :all-sites)
       (length)
       (printf "[dispatcher] Started dispatcher for %d sites")))
