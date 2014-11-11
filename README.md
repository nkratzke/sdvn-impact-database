SDVN Impact Database
====================

A MySQL database providing measurement data and analytical views of several experiments to identify the impact of 

- Linux containers,
- Software Defined Virtual Networks (SDVN)
- and Encryption

to the network performance of cloud deployed REST-like services. 

Run it by installing Docker and launch the following commands:

```
docker build -t sdvn github.com/nkratzke/sdvn-impact-database
docker run -d -p 3306:3306 sdvn
```

Feel free to access this database with MySQLWorkbench to retrace the underlying data. Data has been collected for a conference paper for the [CLOSER 2015](http://closer.scitevents.org/Home.aspx) conference on Cloud Computing and Service Sciences.