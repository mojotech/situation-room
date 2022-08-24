(use joy)
(use ./site-status)

(dyn :all-sites @())

(defn- dispatch-site
  [site]
  (printf "[dispatcher] Dispatching new site: %s" (get site :url))
  (update-site-status site))

(defn start-dispatcher
  "Start a site checker for every tracked site."
  [sites]
  (each site sites (dispatch-site site))
  (->> sites
       (setdyn :all-sites)
       (length)
       (printf "[dispatcher] Started dispatcher for %d sites")))
