# censor-evaluation

This repo contains all that you need to evaluate that censor successfully blocks
SQL injection in [OWASP Mutillidae 2 application](https://github.com/webpwnized/mutillidae). This tutorial explains how to deploy Mutillidae + Acra infrastructure (in docker containers) 
and also demonstrates Acra's ability to prevent known SQL injections.

### Resources:

- Using Acra in Docker (https://docs.cossacklabs.com/pages/trying-acra-with-docker/#using-acra-in-docker).
- Mutillidae Github (https://github.com/webpwnized/mutillidae)
- Acra Github (https://github.com/cossacklabs/acra)
 
## How to deploy MUTILLIDAE + ACRA infrastructure:
1. Run Acra (AcraServer + AcraConnector): `docker-compose -f docker-compose.acra.yml up`. See this [image]().
   
2. Build Mutillidae docker image: `docker build mutillidae/. --force-rm -t cesena:mutillidae`.
   
3. Run Mutillidae from built image: `docker run -d -p 80:80 --network=acracensordemo_default --name mutillidae cesena:mutillidae`.

4. Check running containers: `docker ps -a`. See this [image]().
   
5. Check that you can access Mutillidae via HTTP (localhost:80). See this [image]().
   
6. Press "Opt out" to reset database. In Acra console you should see some activity that logs SQL queries to Mutillidae database. If you see exception in the bottom, press "Reset DB" in horizontal menu on tha main page of Mutillidae. If no errors occurred, you should see main page of Mutillidae application in your browser. See image4.
      
## Let's test known SQL injections and see how Acra can help:
1. In left menu of main page Go to "OWASP 2017" -> "A1 - Injection (SQL)" -> "SQLi - Extract data" -> User Info (SQL). See this [image]().
   
2. Enter into "Password" text box: `' or 1='1` and press "View Account Details" button. This will construct SQL query to atabase: SELECT * FROM accounts WHERE username='' AND password='' or 1='1' which is injected with malicious instruction. See sthis [image]().

3. Now let's add such configuration file for Acra's censor (acra-censor.yaml file in repository):
```console
ignore_parse_error: true
   handlers:
   - handler: query_capture
     filepath: censor_log
    
   - handler: blacklist
     queries: 
     tables:
     patterns:
       - SELECT * FROM accounts WHERE username=%%VALUE%% AND password=%%VALUE%% OR %%VALUE%%=%%VALUE%
```
and then restart Acra. Type CTRL + C in console to gracefully stop and then again: `docker-compose -f docker-compose.acra.yml up` and finally again enter into "Password" text box:`' or 1='1`. You should see exception that MySQL server has gone away. In Acra's console you can find that malicious query is forbidden. See sthis [image]().
    
You can also test two other injections:
    
- into Name or Password textbox: `qwerty' OR 6=6 -- `
- into Password textbox: `' union select ccid,ccnumber,ccv,expiration,null,null,null from credit_cards -- `

To block them use such configuration file for Acra's censor:
```console
ignore_parse_error: true
handlers:
   - handler: query_capture
     filepath: censor_log
   - handler: blacklist
     queries: 
     tables: 
     # 3 (username/password)
     - credit_cards
     patterns:
     # 1 (password)
     - SELECT * FROM accounts WHERE username=%%VALUE%% AND password=%%VALUE%% OR %%VALUE%%=%%VALUE%%
     # 2 (username/password)
     - SELECT * FROM accounts WHERE username=%%VALUE%% OR %%VALUE%%=%%VALUE%% -- ' AND password=%%VALUE%%
```
        
