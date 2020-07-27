when HTTP_REQUEST {
  if { [HTTP::path] starts_with "/.well-known/acme-challenge/" } { 
      # uncomment for apm
      # ACCESS::disable
      # your pool or virtual
      pool /Common/letsencrypt
      #virtual /Common/letsencrypt
      }
}
