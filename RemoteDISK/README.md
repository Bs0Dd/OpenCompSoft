# Creating RemoteDISK network
1. Configuring NetServer
    * Get server from Pastebin by `pastebin get 8yTQdACn /etc/rc.d/rmdsrv.lua` 
    * In `/etc/rc.cfg` set server variable with website directory. Example: 
    [rc.cfg](https://github.com/Bs0Dd/OpenCompSoft/blob/master/RemoteDISK/Examples/rc.cfg)
    * Run server by `rc rmdsrv start`  
    If everything is correct, you must see this:  
    ![NetServer](https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/RemoteDISK/Examples/server.png)
    
    * Server stops by `rc rmdsrv stop`
    
    About "mode" variable:
      * 1 - Configuration 14/1  
            The server can have up to 14 clients and each can open no more than 1 file
      * 2 - Configuration 7/2  
            The server can have up to 7 clients and each can open no more than 2 files
            
      This limitation is due to the inability to open more than 16 files by the system (2 of them are reserved for the needs of the system and the server)
2. Configuring NetClient
      * Get utilities from Pastebin by `pastebin run CnJP04yJ`
      * Сonnection to the server is carried out by the command: `rmdmt <port> <hostname> <login> <password>`  
      If you needs to connect to multiple servers, you can write a simple script file for the utility. Example: 
      [connect.cfg](https://github.com/Bs0Dd/OpenCompSoft/blob/master/RemoteDISK/Examples/connect.cfg)  
      ![NetConn](https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/RemoteDISK/Examples/connector.png)
      * Disconnection and unmounting is performed by the command : `rmdumt <path>`  
      If you needs to disconnect from multiple servers, you can write a simple script file for the utility. Example: 
      [disconnect.cfg](https://github.com/Bs0Dd/OpenCompSoft/blob/master/RemoteDISK/Examples/disconnect.cfg)  
      ![NetDisConn](https://raw.githubusercontent.com/Bs0Dd/OpenCompSoft/master/RemoteDISK/Examples/disconnector.png)
      
If you found a bug or a flaw, please contact me in any convenient way
