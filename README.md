# censor-evaluation

This repo contains all that you need to evaluate that censor successfully blocks
SQL injection in [OWASP Mutillidae 2 application](https://github.com/webpwnized/mutillidae). This tutorial explains how to deploy Mutillidae + Acra infrastructure (in docker containers)
and also demonstrates Acra's ability to prevent known SQL injections.

### Resources:

- Using Acra in Docker (https://docs.cossacklabs.com/pages/trying-acra-with-docker/#using-acra-in-docker).
- Mutillidae Github (https://github.com/webpwnized/mutillidae)
- Mutillidae docker image by @edoz90 (https://github.com/edoz90/docker-mutillidae)
- Acra Github (https://github.com/cossacklabs/acra)

### Pre-installations: 
Currently, acra-censor is in active development phase and in order to get most fresh version of it we recommend to build acra-server docker container from sources rather than use it from dockerhub. To do it, clone original ACRA repository from https://github.com/cossacklabs/acra and build docker containers `make docker`

## How to deploy MUTILLIDAE + ACRA infrastructure:
1. Run demo using docker-compose: `docker-compose -f docker-compose.acra-censor-demo.yml up`: ![image](https://github.com/cossacklabs/acra-censor-demo/blob/master/images/image_1.png)

2. Check running containers: `docker ps -a`: ![image](https://github.com/cossacklabs/acra-censor-demo/blob/master/images/image_2.png)

3. Check that you can access Mutillidae via HTTP (localhost:80): ![image](https://github.com/cossacklabs/acra-censor-demo/blob/master/images/image_3.png)

4. The database just created is empty, so we have to fill it first. Click on `setup/reset the DB` to do this. In Acra console you should see some activity that logs SQL queries to Mutillidae database. You should see main page of Mutillidae application in your browser: ![image](https://github.com/cossacklabs/acra-censor-demo/blob/master/images/image_4.png)

## Let's test known SQL injections and see how Acra can help:
1. In left menu of main page Go to "OWASP 2017" -> "A1 - Injection (SQL)" -> "SQLi - Extract data" -> User Info (SQL): ![image](https://github.com/cossacklabs/acra-censor-demo/blob/master/images/image_5.png)

![image](https://github.com/cossacklabs/acra-censor-demo/blob/master/images/image_5a.png)

2. Enter into "Password" text box: `' or 1='1` and press "View Account Details" button. This will construct SQL query to atabase: SELECT * FROM accounts WHERE username='' AND password='' or 1='1' which is injected with malicious instruction: ![image](https://github.com/cossacklabs/acra-censor-demo/blob/master/images/image_6.png)

3. Now let's tune Acra's censor. There are configuration files in `./.acraconfigs/acra-server/` folder:
- `acra-censor.norules.yaml` (minimal configuration that simply creates valueless AcraCensor)
- `acra-censor.ruleset01.yaml` (example: rule set based on typical allowlist - allow some / deny any other)
- `acra-censor.ruleset02.yaml` (example: rule set based on typical denylist - deny some / allow any other)
- `acra-censor.yaml` (active config, used by AcraCensor)

Replace active config with `acra-censor.ruleset01.yaml` (or `acra-censor.ruleset02.yaml`) and restart `acra-server` container:
```bash
cp ./.acraconfigs/acra-server/acra-censor.ruleset01.yaml ./.acraconfigs/acra-server/acra-censor.yaml
docker restart acra-censor-demo_acra-server_1
```

Finally again enter into "Password" text box:`' or 1='1`. You should see exception that MySQL server has gone away. In Acra's console you can find that malicious query is forbidden: ![image](https://github.com/cossacklabs/acra-censor-demo/blob/master/images/image_7.png)

You can also test blocking other injections (if apply any of rule sets provided):
- into Name or Password textbox: `qwerty' OR 6=6 -- `
- into Password textbox: `' union select ccid,ccnumber,ccv,expiration,null,null,null from credit_cards -- `

Or go to the following:
- OWASP 2017 -> A1 Injection (SQL) -> SQLi Bypass Authentication -> Login
- OWASP 2017 -> A1 Injection (SQL) -> Blind SQL via Timing -> Login
- OWASP 2017 -> A2 Broken authentication ... -> Authentication bypass -> via SQL injection -> Login

and try:

Username: `admin`
Password: `' or 1='1`
