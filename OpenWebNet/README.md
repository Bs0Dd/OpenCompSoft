# Creating in-world Website with OpenWebNet protocol
1. Setting up OVNServer
    * Get server from Pastebin by `pastebin run `
    * In `/etc/rc.cfg` set server variable with website directory. Example: `ownserv = "/mnt/c83/srvdir"`
    * Run server by `rc ownserv start`
    * Server stops by `rc ownserv stop`
    
2. Setting up Memphisto browser
    * Get browser from Pastebin by `pastebin run `
    * Go to `/etc/webbrow.cfg`. There you can set:
        * `["homepage"] = "/usr/misc/Memphisto/home.nfp"`
          Variable with path to homepage file 
        * `["download_dir"] = "/home/"`
          Directory where will be downloaded files from sites
        * `["std_backg"] = 0x878787`
          Standart page background color in HEX RGB (0xRRGGBB)
        * `["autobackg"]= true`
          "Autobackground" option, automatically sets text's background color to ["std_backg"] if text's background is 0x000000
        * `["DDBS_serv"] = "5b548fbd-a43e-44d3-af7f-6d37c832b221"`
          Modem's address of Domens DataBase Server (DDBServer), there is an example address
        * `["DDBS_uselocal"] = true`
          If you haven't DDBServer, you can use local domens file by setting this variable to `true`
        * `["DDBS_local"] = "/etc/ddbsloc.cfg"`
          Path to local domens file
    1. If you wants to use global in-world domens list (DDBServer)
        * Set`["DDBS_uselocal"]` variable to `false`
        * Get server from Pastebin by `pastebin run `
        * In `/etc/rc.cfg` set server variable with table of domens and his server's modem addresses.  
          Example: `ddbserv = {["openwebnet.com"] = "a77b72c8-5f98-474f-8d92-d6e832c8e582", ...}`
        * Run server by `rc ddbserv start`
        * Server stops by `rc ddbserv stop`
        * Set Modem's address of Domens DataBase Server to `["DDBS_serv"]` variable
    2. If you wants to use local in-world domens list on HDD
        * Set`["DDBS_uselocal"]` variable to `true`
        * Go to `/etc/ddbssloc.cfg` or set custom in `["DDBS_local"]` variable
          And set table of domens and his server's modem addresses
          Example: `{["openwebnet.com"] = "a77b72c8-5f98-474f-8d92-d6e832c8e582", ...}`
          
Manual about writing pages in Network Formatted Page (NFP) standart will be written later...  
Now you can use standart pages from Memphisto as writing examples
