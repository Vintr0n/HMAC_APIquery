# HMAC_APIquery
Querying an end point to get the HMAC based cookies to be used in SQL for real time reporting

Here the task was to query an API that was primarily set up to feed the browser based front end. 
The software required cookies for each API query the cookie was based on an HMAC (strings + date time + secret in to a 512 hash and then to B64) 
Once the cookie was retrieved using powershell, the cookies could be used in SQL as a header under a sp_OAMethod @Object
to be sent in a GET HTTP query. The response was JSON. OPENJSON function in SQL was used to parse the data in to a table based workable format. 
