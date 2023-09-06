# What is this?

This project illustrates how to use [AcraCensor](https://docs.cossacklabs.com/pages/documentation-acra/#acracensor-acra-s-firewall) as SQL firewall to prevent SQL injections. Target application is a well-known vulnerable web application [OWASP Mutillidae 2](https://github.com/webpwnized/mutillidae).

AcraCensor – is a built-in SQL firewall of [Acra data protection suite](https://cossacklabs.com/acra/). This project is one of numerous Acra's example applications. If you are curious about other Acra features, like transparent encryption, intrusion detection, load balancing support – [Acra Example Applications](https://github.com/cossacklabs/acra-engineering-demo/).

# What's inside?

The demo project has a [Docker compose file](docker-compose.acra-censor-demo.yml) that runs the following web infrastructure:
- OWASP Mutillidae web application,
- [Acra encryption suite](https://github.com/cossacklabs/acra).

Acra works as a proxy between web and database. AcraCensor inspects every SQL query that runs from the web application to the database, and back.

<p align="center"><img src="images/acra-censor-scheme.png" alt="Protecting OWASP web application: Acra architecture with AcraCensor" width="700"></p>

This is a slide from [a talk by Cossack Labs' security software engineer Artem Storozhuk](https://speakerdeck.com/storojs72/building-sql-firewall-insights-from-developers) on building SQL firewalls, which illustrates how SQL firewalls can prevent more SQLi than WAF.

<img src="images/SQL-firewall-vs-WAF.png" width="600">


## Screencast

<a href="https://youtu.be/ABjIfx2_hJk" target="_blank"><img src="images/youtube-video.png" alt="Watch the video" width="700"></a>


## How to run the demo

1. Use docker-compose command to set up and run the whole infrastructure:

```
docker-compose -f docker-compose.acra-censor-demo.yml up --build
```

<img src="images/image_1.png" width="700">


2. Check that the containers are up and running:

```
docker ps -a
``` 

<img src="images/image_2.png" width="700">

3. Open Mutillidae web portal at `localhost:8080`:

<img src="images/image_3.png" width="700">

4. The database is still empty so we need to fill it first by clicking on `Click here to attempt to setup the database` and then `Opt out of database warnings`.

In the Docker console you should see SQL queries in Acra logs. After resetting the database, the main page of Mutillidae application looks like this:

<img src="images/image_4.png" width="700">

## How to perform SQL injections

1. Start with selecting a vulnerable web page. In the menu on the left, go to "OWASP 2017" -> "A1 - Injection (SQL)" -> "SQLi - Extract data" -> User Info (SQL).

<img src="images/image_5.png" width="700">
<img src="images/image_5a.png" width="700">

2. Now, let's run an SQL injection. Try to login any name and password `' or 1='1`.

This will construct an SQL query `SELECT * FROM accounts WHERE username='' AND password='' or 1='1'` — containing a typical SQL injection — to the database.

<img src="images/image_6.png" width="700">


## How AcraCensor prevents SQL injections

1. Now, let's fine-tune AcraCensor for preventing this injection.

There are configuration files in `./.acraconfigs/acra-server/` folder:
- `acra-censor.norules.yaml` (minimal configuration that simply creates valueless AcraCensor);
- `acra-censor.ruleset01.yaml` (example: ruleset based on typical allowlist - allow some / deny any other);
- `acra-censor.ruleset02.yaml` (example: ruleset based on typical denylist - deny some / allow any other);
- `acra-censor.yaml` (active config, used by AcraCensor).

AcraCensor uses empty configuration file by default (no rules setup at all). We need to update the configuration file to change that.

Replace the active config with `acra-censor.ruleset01.yaml` (or `acra-censor.ruleset02.yaml`) and restart the `acra-server` container:

```bash
cp ./.acraconfigs/acra-server/acra-censor.ruleset01.yaml ./.acraconfigs/acra-server/acra-censor.yaml
docker restart acra-censor-demo_acra-server_1
```

In the docker log, you will see that AcraServer has restarted with an updated configuration file:

```bash
acra-server_1_979c50cd7b3e | time="2019-02-05T18:53:22Z" level=info msg="Server graceful shutdown completed, bye PID: 1"
acra-censor-demo-master_acra-server_1_979c50cd7b3e exited with code 0
```


2. Test if the new AcraCensor configuration prevents injections.

On the same web page, try to login again using the password `' or 1='1`.

You should see that the response from MySQL server is blocked. In Acra's console, you can see that the malicious query is forbidden:

<img src="images/image_7.png" width="700">

3. Try other SQL injections.

You can also test the process of blocking other injections (if applies to any of the provided rulesets):
- into Name or Password textbox: `qwerty' OR 6=6 -- `;
- into Password textbox: `' union select ccid,ccnumber,ccv,expiration,null,null,null from credit_cards -- `.

4. Try other vulnerable web pages. Select one of the following:

- OWASP 2017 -> A1 Injection (SQL) -> SQLi Bypass Authentication -> Login
- OWASP 2017 -> A1 Injection (SQL) -> Blind SQL via Timing -> Login
- OWASP 2017 -> A2 Broken authentication ... -> Authentication bypass -> via SQL injection -> Login

and try to use `admin` as a username and `' or 1='1` as a password.

## Learn more

1. Read more about [how SQL firewall works and how it is different from WAF](https://www.cossacklabs.com/blog/sql-firewall-vs-waf-against-sqli.html).
2. Read out blog post [how we built AcraCensor](https://www.cossacklabs.com/blog/how-to-build-sql-firewall-acracensor.html).
3. Watch the slides about the developers' perspective on [building SQL firewall](https://speakerdeck.com/storojs72/building-sql-firewall-insights-from-developers).
4. Check [Mutillidae repository](https://github.com/webpwnized/mutillidae).
5. Check [Mutillidae docker](https://github.com/webpwnized/mutillidae-docker).

# Further steps

Let us know if you have any questions by dropping an email to [dev@cossacklabs.com](mailto:dev@cossacklabs.com).

1. [Acra features](https://cossacklabs.com/acra/) – check out full features set and available licenses.
2. Other [Acra example applications](https://github.com/cossacklabs/acra-engineering-demo/) – try other Acra features, like transparent encryption, SQL firewall, load balancing support.

# Need help?

Need help in configuring Acra? Our support is available for [Acra Pro and Acra Enterprise versions](https://www.cossacklabs.com/acra/#pricing).
