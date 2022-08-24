(use joy)


(route :get "/sites" :sites/index)
(route :get "/sites/:id" :sites/show)
(route :post "/sites" :sites/create)
(route :delete "/sites/:id" :sites/delete)


(defn site [req]
  (let [id (get-in req [:params :id])]
    (db/find :sites id)))


(def site/body
  (body :sites
    (validates [ :url :email] :required true)
    (permit [ :url :email])))


(defn sites/index [req]
  (let [sites (db/from :sites)]
    (application/json sites)))


(defn sites/show [req]
  (when-let [site (site req)]

    [:div
     [:strong "id"]
     [:div (site :id)]

     [:strong "url"]
     [:div (site :url)]

     [:strong "email"]
     [:div (site :email)]

     [:strong "status"]
     [:div (site :status)]

     [:strong "duration"]
     [:div (site :duration)]

     [:strong "created-at"]
     [:div (site :created-at)]

     [:strong "updated-at"]
     [:div (site :updated-at)]


     [:a {:href (url-for :sites/index)} "All sites"]]))


(defn sites/create [req]
  (let [site (-> req site/body db/save)]
    (redirect-to :sites/index)))

(defn sites/delete [req]
  (when-let [site (site req)]

    (db/delete site)

    (redirect-to :sites/index)))
