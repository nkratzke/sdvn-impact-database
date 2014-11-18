# CREATE DATABASE FOR ANALYTICS
DROP DATABASE IF EXISTS experiment;
CREATE DATABASE experiment DEFAULT CHARACTER SET utf8;

USE experiment;

# CREATE TABLE FOR EXPERIMENTAL DATA
DROP TABLE IF EXISTS data;
CREATE TABLE data (
	  id INT NOT NULL AUTO_INCREMENT, # id of the test
	  document_path VARCHAR(256),     # requested message (e.g. /ping/5)
    document_length INT,            # length of the transfered message (bytes)
    test_duration DOUBLE,           # how long did the test run (miliseconds)
    completed_reqs INT,             # amount of completed requests
    failed_reqs INT,                # amount of non successfull requests
    concurrency_level INT,          # how many concurrent requests
    total_data BIGINT,              # data transfered in bytes
    rps DOUBLE,                     # requests per second
    transfer_rate DOUBLE,           # transfer rate in bytes/second
		time_per_request DOUBLE,        # requests per second
    tag VARCHAR(256),               # time per rer requst in miliseconds
    PRIMARY KEY (id)
);

# CREATE VIEWS FOR ANALYSIS OF EXPERIMENTAL DATA

# View to evaluate overall characteristics of the experiments
CREATE VIEW Characteristics AS
SELECT Tag AS Experiment,                                          # Experiment
       SUM(total_data) / 1024 / 1024 / 1024 AS 'Total Data (GB)',  # Transfered Data (GB)
	     SUM(completed_reqs) AS 'Requests',                          # Requests of each experiment
       SUM(test_duration) / 60 AS 'Duration (min)'                 # Time for each experiment
FROM   data
GROUP BY tag;

# View to analyze standard deviations of the experiments
CREATE VIEW Deviations AS
SELECT Tag AS Experiment,
       document_length,
       std(rps)/avg(rps) AS RSD_rps,                            # relative standard deviation of requests per second
			 std(transfer_rate)/avg(transfer_rate) AS RSD_trans,      # relative standard deviation of transfer rate
			 std(time_per_request)/avg(time_per_request) AS RSD_tpr   # relative standard deviation of time per request
FROM   data
GROUP BY document_length, tag;

# View to provide an overview of deviations of the experiments
CREATE VIEW DeviationsOverview AS
SELECT Experiment,                   # Experiment
       min(RSD_rps) AS min_RSD_rps,  # minimal RSD of requests per second
			 avg(RSD_rps) AS avg_RSD_rps,  # average RSD of requests per second
			 max(RSD_rps) AS max_RSD_rps   # maximal RSD of requests per second
FROM   Deviations
GROUP BY Experiment;

# View to evaluate the reference experiment
CREATE VIEW Reference AS
SELECT document_length,                        # Message size (bytes)
			 sum(completed_reqs) as n,               # how many requests for a message size
       avg(test_duration) as avg_duration,     # average duration of a benchmark run
       std(test_duration) as sd_duration,      # standard deviation of duration
       avg(rps) as avg_rps,                    # average requests per second of a benchmark run
       std(rps) as sd_rps,                     # standard deviation of requests per second
       avg(transfer_rate) as avg_transfer,     # average transfer rate of a benchmark run
       std(transfer_rate) as sd_transfer,      # standard deviation of transfer rate
   		 avg(time_per_request) as avg_tpr,       # average time per request of a benchmark run
			 std(time_per_request) as sd_tpr         # standard deviation of time per request
FROM   data
WHERE  tag = "Reference"
GROUP BY document_path
ORDER BY document_length;

# View to evaluate the cross-zone experiment
# Same structure like the reference experiment
CREATE VIEW CrossZone AS
SELECT document_length,
       sum(completed_reqs) as n,
			 avg(test_duration) as avg_duration,
			 std(test_duration) as sd_duration,
			 avg(rps) as avg_rps,
			 std(rps) as sd_rps,
			 avg(transfer_rate) as avg_transfer,
			 std(transfer_rate) as sd_transfer,
			 avg(time_per_request) as avg_tpr,
			 std(time_per_request) as sd_tpr
FROM   data
WHERE  tag = "Cross+Zone"
GROUP BY document_path
ORDER BY document_length;

# View to evaluate the cross-regional experiment
# Same structure like the reference experiment
CREATE VIEW CrossRegional AS
SELECT document_length,
       sum(completed_reqs) as n,
			 avg(test_duration) as avg_duration,
			 std(test_duration) as sd_duration,
			 avg(rps) as avg_rps,
			 std(rps) as sd_rps,
			 avg(transfer_rate) as avg_transfer,
			 std(transfer_rate) as sd_transfer,
			 avg(time_per_request) as avg_tpr,
			 std(time_per_request) as sd_tpr
FROM   data
WHERE  tag = "Cross+Regional"
GROUP BY document_path
ORDER BY document_length;

# View to evaluate the Docker experiment
# Same structure like the reference experiment
CREATE VIEW Docker AS
SELECT document_length,
			 sum(completed_reqs) as n,
       avg(test_duration) as avg_duration,
       std(test_duration) as sd_duration,
       avg(rps) as avg_rps,
       std(rps) as sd_rps,
       avg(transfer_rate) as avg_transfer,
       std(transfer_rate) as sd_transfer,
			 avg(time_per_request) as avg_tpr,
			 std(time_per_request) as sd_tpr
FROM   data
WHERE  tag = "Docker"
GROUP BY document_path
ORDER BY document_length;

# View to evaluate the SDVN experiment
# Same structure like the reference experiment
CREATE VIEW Docker_SDVN AS
SELECT document_length,
       sum(completed_reqs) as n,
       avg(test_duration) as avg_duration,
       std(test_duration) as sd_duration,
       avg(rps) as avg_rps,
       std(rps) as sd_rps,
       avg(transfer_rate) as avg_transfer,
       std(transfer_rate) as sd_transfer,
			 avg(time_per_request) as avg_tpr,
			 std(time_per_request) as sd_tpr
FROM   data
WHERE  tag = "Docker+SDN"
GROUP BY document_path
ORDER BY document_length;

# View to evaluate the encrypted SDVN experiment
# Same structure like the reference experiment
CREATE VIEW Docker_SDVN_Encrypted AS
SELECT document_length,
			 sum(completed_reqs) as n,
       avg(test_duration) as avg_duration,
       std(test_duration) as sd_duration,
       avg(rps) as avg_rps,
       std(rps) as sd_rps,
       avg(transfer_rate) as avg_transfer,
       std(transfer_rate) as sd_transfer,
			 avg(time_per_request) as avg_tpr,
			 std(time_per_request) as sd_tpr
FROM   data
WHERE  tag = "Docker+SDN+Encrypted"
GROUP BY document_path
ORDER BY document_length;

# Analytical view to compare absolute values of requests per seconds of the experiments
CREATE VIEW Comparison_of_rps AS
SELECT R.document_length,                    # Message size
	     R.avg_rps AS Reference,               # Average value (reference experiment)
       R.sd_rps AS Reference_SD,             # Standard deviation (reference experiment)
       D.avg_rps AS Docker,                  # Average value (docker experiment)
       D.sd_rps AS Docker_SD,                # Standard deviation (docker experiment)
       DS.avg_rps AS Docker_SDVN,            # Average value (SDVN experiment)
       DS.sd_rps AS Docker_SDVN_SD,          # Standard deviation (SDVN experiment)
       DSE.avg_rps AS Docker_Encrypted,      # Average value (Encrypted SDVN experiment)
       DSE.sd_rps AS Docker_Encrypted_SD,    # Standard deviation (Encrypted SDVN experiment)
	     CR.avg_rps AS CrossRegional,          # Average value (cross regional experiment)
       CR.sd_rps AS CrossRegional_SD,        # Standard deviation (cross regional experiment)
	     CZ.avg_rps AS CrossZone,              # Average value (cross zone experiment)
       CZ.sd_rps AS CrossZone_SD             # Standard deviation (cross zone experiment)
FROM   Reference as R,
       Docker AS D,
       Docker_SDVN AS DS,
       Docker_SDVN_Encrypted AS DSE,
			 CrossZone AS CZ,
			 CrossRegional AS CR
WHERE  R.document_length = D.document_length AND
       D.document_length = DS.document_length AND
	     DS.document_length = DSE.document_length AND
			 DSE.document_length = CZ.document_length AND
			 CZ.document_length = CR.document_length
;

#
# Views to compare performance indicators by absolute values
#

# Analytical view to compare absolute values of time per request (miliseconds) of the experiments
# Same structure and meaning like comparision of requests per second
CREATE VIEW Comparison_of_tpr AS
SELECT R.document_length,
			 R.avg_tpr AS Reference,
       R.sd_tpr AS Reference_SD,
			 D.avg_tpr AS Docker,
       D.sd_tpr AS Docker_SD,
			 DS.avg_tpr AS Docker_SDVN,
       DS.sd_tpr AS Docker_SDVN_SD,
			 DSE.avg_tpr AS Docker_Encrypted,
			 DSE.sd_tpr AS Docker_Encrypted_SD,
			 CR.avg_tpr AS CrossRegional,
			 CR.sd_tpr AS CrossRegional_SD,
			 CZ.avg_tpr AS CrossZone,
			 CZ.sd_tpr AS CrossZone_SD
FROM   Reference as R,
			 Docker AS D,
			 Docker_SDVN AS DS,
			 Docker_SDVN_Encrypted AS DSE,
			 CrossZone AS CZ,
			 CrossRegional AS CR
WHERE  R.document_length = D.document_length AND
			 D.document_length = DS.document_length AND
			 DS.document_length = DSE.document_length AND
			 DSE.document_length = CZ.document_length AND
			 CZ.document_length = CR.document_length
;

# Analytical view to compare absolute values of transfer rates (bytes/second) of the experiments
# Same structure and meaning like comparision of requests per second
CREATE VIEW Comparison_of_transfer AS
SELECT R.document_length,
	     R.avg_transfer AS Reference,
       R.sd_transfer AS Reference_SD,
       D.avg_transfer AS Docker,
       D.sd_transfer AS Docker_SD,
       DS.avg_transfer AS Docker_SDVN,
       DS.sd_transfer AS Docker_SDVN_SD,
       DSE.avg_transfer AS Docker_Encrypted,
       DSE.sd_transfer AS Docker_Encrypted_SD,
       CR.avg_transfer AS CrossRegional,
       CR.sd_transfer AS CrossRegional_SD,
       CZ.avg_transfer AS CrossZone,
       CZ.sd_transfer AS CrossZone_SD
FROM   Reference as R,
       Docker AS D,
       Docker_SDVN AS DS,
       Docker_SDVN_Encrypted AS DSE,
			 CrossZone AS CZ,
			 CrossRegional AS CR
WHERE  R.document_length = D.document_length AND
       D.document_length = DS.document_length AND
	     DS.document_length = DSE.document_length AND
			 DSE.document_length = CZ.document_length AND
			 CZ.document_length = CR.document_length
;

# Analytical view to compare absolute values of duration (seconds) of the experiments
# Same structure and meaning like comparision of requests per second
CREATE VIEW Comparison_of_duration AS
SELECT R.document_length,
	     R.avg_duration AS Reference,
       D.avg_duration AS Docker,
       DS.avg_duration AS Docker_SDVN,
       DSE.avg_duration AS Docker_Encrypted,
			 CR.avg_duration AS CrossRegional,
			 CZ.avg_duration AS CrossZone
FROM   Reference as R,
       Docker AS D,
       Docker_SDVN AS DS,
       Docker_SDVN_Encrypted AS DSE,
			 CrossRegional AS CR,
			 CrossZone AS CZ
WHERE  R.document_length = D.document_length AND
       D.document_length = DS.document_length AND
	     DS.document_length = DSE.document_length AND
			 DSE.document_length = CZ.document_length AND
			 CZ.document_length = CR.document_length
;

#
# Views to compare performance indicators in a relative way
#

# Analytical view to compare values of requests per seconds
# of the experiments with reference experiment
CREATE VIEW Relative_performance_rps AS
SELECT document_length,                                  # Message size
       Docker/Reference AS Docker,                       # Compare docker with reference
       Docker_SDVN/Reference AS Docker_SDVN,             # Compare SDVN with reference
       Docker_Encrypted/Reference AS Docker_Encrypted,   # Compare Encrypted SDN with reference
       CrossZone/Reference AS CrossZone,                 # Compare CrossZone with reference
       CrossRegional/Reference AS CrossRegional          # Compare CrossRegional with reference
FROM   Comparison_of_rps;

# Analytical view to compare values of transfer rates (bytes / second)
# of the experiments with reference experiment
# Same structure and meaning like the relative comparision of requests per second
CREATE VIEW Relative_performance_transfer AS
SELECT document_length,
       Docker/Reference AS Docker,
       Docker_SDVN/Reference AS Docker_SDVN,
       Docker_Encrypted/Reference AS Docker_Encrypted,
       CrossZone/Reference AS CrossZone,
       CrossRegional/Reference AS CrossRegional
FROM   Comparison_of_transfer;

# Analytical view to compare values of duration (seconds)
# of the experiments with reference experiment
# Same structure and meaning like the relative comparision of requests per second
CREATE VIEW Relative_performance_duration AS
SELECT document_length,
       Docker/Reference AS Docker,
       Docker_SDVN/Reference AS Docker_SDVN,
       Docker_Encrypted/Reference AS Docker_Encrypted,
       CrossZone/Reference AS CrossZone,
       CrossRegional/Reference AS CrossRegional
FROM   Comparison_of_duration;

# Analytical view to compare values of time per request (miliseconds)
# of the experiments with reference experiment
# Same structure and meaning like the relative comparision of requests per second
CREATE VIEW Relative_performance_tpr AS
SELECT document_length,
       Docker/Reference AS Docker,
       Docker_SDVN/Reference AS Docker_SDVN,
       Docker_Encrypted/Reference AS Docker_Encrypted,
       CrossZone/Reference AS CrossZone,
       CrossRegional/Reference AS CrossRegional
FROM   Comparison_of_tpr;

#
# Views to analyze resulting performance losses of causes
#

# Analytical view to identify transfer rate (bytes/second) performance losses due to
# containerization, SDVN, encryption.
CREATE VIEW Resulting_Transfer_Performance_Losses AS
SELECT document_length,                                               # Message size
       Docker/Reference AS 'Loss caused by containerization',         # Loss due to Docker containers
       Docker_SDVN/Docker AS 'Loss caused by SDVN',                   # Loss due to SDVN solution weave (without container)
       Docker_Encrypted/Docker_SDVN AS 'Loss caused by encryption'    # Loss due to Encryption (without SDVN and conatiner)
FROM   Comparison_of_transfer;

# Analytical view to identify request per second performance losses due to
# containerization, SDVN, encryption.
CREATE VIEW Resulting_RPS_Performance_Losses AS
SELECT document_length,
       Docker/Reference AS 'Loss caused by containerization',
       Docker_SDVN/Docker AS 'Loss caused by SDVN',
       Docker_Encrypted/Docker_SDVN AS 'Loss caused by encryption'
FROM   Comparison_of_rps;

# Analytical view to identify time per request performance losses due to
# containerization, SDVN, encryption.
CREATE VIEW Resulting_TPR_Performance_Losses AS
SELECT document_length,
       Reference/Docker AS 'Loss caused by containerization',
       Docker/Docker_SDVN AS 'Loss caused by SDVN',
       Docker_SDVN/Docker_Encrypted AS 'Loss caused by encryption'
FROM   Comparison_of_tpr;

# LOAD DATA FROM CSV INTO DATABASE
LOAD DATA LOCAL INFILE '/var/db/logdata.csv'
INTO TABLE data
COLUMNS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(tag,
 document_path,
 document_length,
 test_duration,
 completed_reqs,
 failed_reqs,
 concurrency_level,
 total_data,
 rps,
 transfer_rate,
 time_per_request
);
