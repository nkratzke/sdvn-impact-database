SDVN Impact Database
====================

A Docker container providing a MySQL database containing measurement data and analytical views of several experiments to identify the impact of

- Linux containers,
- Software Defined Virtual Networks (SDVN)
- and Encryption

to the network performance of cloud deployed REST-like services.

Run it by installing Docker and launch the following commands:

```
docker build -t sdvn github.com/nkratzke/sdvn-impact-database
docker run -d -p 3306:3306 sdvn
```

Feel free to access this readonly database with MySQLWorkbench to double check the underlying data. Connection parameters to this database are:

- __DB:__ experiment
- __Host:__ 
  - localhost _(if Docker runs natively on your workstation)_ or 
  - 192.168.59.103 (if you use boot2docker, if unsure use 'boot2docker ip' to figure out your ip adress).
- __Port:__ 3306
- __DB User:__ reviewer _(no password required)_

<img src='screenshot.png' width='100%'>


Data has been collected for a __Cloud Computing__ conference paper.
