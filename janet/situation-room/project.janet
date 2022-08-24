(declare-project
  :name "situation-room"
  :description "Self-hosted domain uptime checker"
  :dependencies ["https://github.com/joy-framework/joy"
                 "https://github.com/janet-lang/sqlite3"
                 "https://github.com/joy-framework/http"]
  :author "Craig P Jolicoeur <craig@mojotech.com>"
  :license "MIT"
  :url "https://www.github.com/mojotech/situation-room"
  :repo "https://www.github.com/mojotech/situation-room")

(phony "server" []
  (if (and
        (= "development" (os/getenv "JOY_ENV"))
        (zero? (os/shell "which entr &> /dev/null")))
    (os/shell "find . -name '*.janet' | entr -r janet main.janet")
    (os/shell "janet main.janet")))

(declare-executable
  :name "situation-room"
  :entry "main.janet")
