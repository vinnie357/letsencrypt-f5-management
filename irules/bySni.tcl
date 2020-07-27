when CLIENTSSL_CLIENTHELLO {

    if { [SSL::extensions exists -type 0] } {

        ## if the servername exists - send to the appropriate pool
        ## you could also use a data group for this     

        set tls_servername [string range [SSL::extensions -type 0] 9 [string length [SSL::extensions -type 0]]]

        switch $tls_servername {
            "example-virtual.domain.com" { virtual /Common/letsencrypt }
            "example-pool.domain.com" { pool /Common/letsencrypt }
            "192.168.1.200" -
            "" { pool /Common/other_pool }
            default { pool /Common/default_pool }
        }

    }

}