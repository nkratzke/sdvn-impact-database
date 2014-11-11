# CREATE DATABASE FOR ANALYTICS
DROP DATABASE IF EXISTS experiment;
CREATE DATABASE experiment DEFAULT CHARACTER SET utf8;

USE experiment;

# CREATE TABLE FOR EXPERIMENTAL DATA
DROP TABLE IF EXISTS data;
CREATE TABLE data (
	id INT NOT NULL AUTO_INCREMENT,
	document_path VARCHAR(256),
    document_length INT,
    test_duration DOUBLE,
    completed_reqs INT,
    failed_reqs INT,
    concurrency_level INT,
    total_data BIGINT,
    rps DOUBLE,
    transfer_rate DOUBLE,
		time_per_request DOUBLE,
    tag VARCHAR(256),
    PRIMARY KEY (id)
);

# CREATE VIEWS FOR ANALYSIS OF EXPERIMENTAL DATA

CREATE VIEW Characteristics AS
SELECT Tag AS Experiment, SUM(total_data) / 1024 / 1024 / 1024 AS 'Total Data (GB)',
	     SUM(completed_reqs) AS 'Requests',
       SUM(test_duration) / 60 AS 'Duration (min)'
FROM data
GROUP BY tag;

CREATE VIEW Reference AS
SELECT document_length,
       avg(test_duration) as avg_duration,
       std(test_duration) as sd_duration,
       avg(rps) as avg_rps,
       std(rps) as sd_rps,
       avg(transfer_rate) as avg_transfer,
       std(transfer_rate) as sd_transfer,
   		 avg(time_per_request) as avg_tpr,
			 std(time_per_request) as sd_tpr
FROM   data
WHERE  tag = "Reference"
GROUP BY document_path
ORDER BY document_length;

CREATE VIEW CrossZone AS
SELECT document_length,
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

CREATE VIEW CrossRegional AS
SELECT document_length,
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

CREATE VIEW Docker AS
SELECT document_length,
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

CREATE VIEW Docker_SDN AS
SELECT document_length,
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

CREATE VIEW Docker_SDN_Encrypted AS
SELECT document_length,
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

CREATE VIEW Comparison_of_rps AS
SELECT R.document_length,
	     R.avg_rps AS Reference,
       R.sd_rps AS Reference_SD,
       D.avg_rps AS Docker,
       D.sd_rps AS Docker_SD,
       DS.avg_rps AS Docker_SDN,
       DS.sd_rps AS Docker_SDN_SD,
       DSE.avg_rps AS Docker_Encrypted,
       DSE.sd_rps AS Docker_Encrypted_SD,
	     CR.avg_rps AS CrossRegional,
       CR.sd_rps AS CrossRegional_SD,
	     CZ.avg_rps AS CrossZone,
       CZ.sd_rps AS CrossZone_SD
FROM   Reference as R,
       Docker AS D,
       Docker_SDN AS DS,
       Docker_SDN_Encrypted AS DSE,
			 CrossZone AS CZ,
			 CrossRegional AS CR
WHERE  R.document_length = D.document_length AND
       D.document_length = DS.document_length AND
	     DS.document_length = DSE.document_length AND
			 DSE.document_length = CZ.document_length AND
			 CZ.document_length = CR.document_length
;

CREATE VIEW Comparison_of_tpr AS
SELECT R.document_length,
			 R.avg_tpr AS Reference,
       R.sd_tpr AS Reference_SD,
			 D.avg_tpr AS Docker,
       D.sd_tpr AS Docker_SD,
			 DS.avg_tpr AS Docker_SDN,
       DS.sd_tpr AS Docker_SDN_SD,
			 DSE.avg_tpr AS Docker_Encrypted,
			 DSE.sd_tpr AS Docker_Encrypted_SD,
			 CR.avg_tpr AS CrossRegional,
			 CR.sd_tpr AS CrossRegional_SD,
			 CZ.avg_tpr AS CrossZone,
			 CZ.sd_tpr AS CrossZone_SD
FROM   Reference as R,
			 Docker AS D,
			 Docker_SDN AS DS,
			 Docker_SDN_Encrypted AS DSE,
			 CrossZone AS CZ,
			 CrossRegional AS CR
WHERE  R.document_length = D.document_length AND
			 D.document_length = DS.document_length AND
			 DS.document_length = DSE.document_length AND
			 DSE.document_length = CZ.document_length AND
			 CZ.document_length = CR.document_length
;

CREATE VIEW Comparison_of_transfer AS
SELECT R.document_length,
	     R.avg_transfer AS Reference,
       R.sd_transfer AS Reference_SD,
       D.avg_transfer AS Docker,
       D.sd_transfer AS Docker_SD,
       DS.avg_transfer AS Docker_SDN,
       DS.sd_transfer AS Docker_SDN_SD,
       DSE.avg_transfer AS Docker_Encrypted,
       DSE.sd_transfer AS Docker_Encrypted_SD,
       CR.avg_transfer AS CrossRegional,
       CR.sd_transfer AS CrossRegional_SD,
       CZ.avg_transfer AS CrossZone,
       CZ.sd_transfer AS CrossZone_SD
FROM   Reference as R,
       Docker AS D,
       Docker_SDN AS DS,
       Docker_SDN_Encrypted AS DSE,
			 CrossZone AS CZ,
			 CrossRegional AS CR
WHERE  R.document_length = D.document_length AND
       D.document_length = DS.document_length AND
	     DS.document_length = DSE.document_length AND
			 DSE.document_length = CZ.document_length AND
			 CZ.document_length = CR.document_length
;

CREATE VIEW Comparison_of_duration AS
SELECT R.document_length,
	     R.avg_duration AS Reference,
       D.avg_duration AS Docker,
       DS.avg_duration AS Docker_SDN,
       DSE.avg_duration AS Docker_Encrypted,
			 CR.avg_duration AS CrossRegional,
			 CZ.avg_duration AS CrossZone
FROM   Reference as R,
       Docker AS D,
       Docker_SDN AS DS,
       Docker_SDN_Encrypted AS DSE,
			 CrossRegional AS CR,
			 CrossZone AS CZ
WHERE  R.document_length = D.document_length AND
       D.document_length = DS.document_length AND
	     DS.document_length = DSE.document_length AND
			 DSE.document_length = CZ.document_length AND
			 CZ.document_length = CR.document_length
;

CREATE VIEW Relative_performance_rps AS
SELECT document_length,
       Docker/Reference AS Docker,
       Docker_SDN/Reference AS Docker_SDN,
       Docker_Encrypted/Reference AS Docker_Encrypted,
       CrossZone/Reference AS CrossZone,
       CrossRegional/Reference AS CrossRegional
FROM   Comparison_of_rps;

CREATE VIEW Relative_performance_transfer AS
SELECT document_length,
       Docker/Reference AS Docker,
       Docker_SDN/Reference AS Docker_SDN,
       Docker_Encrypted/Reference AS Docker_Encrypted,
       CrossZone/Reference AS CrossZone,
       CrossRegional/Reference AS CrossRegional
FROM   Comparison_of_transfer;

CREATE VIEW Relative_performance_duration AS
SELECT document_length,
       Docker/Reference AS Docker,
       Docker_SDN/Reference AS Docker_SDN,
       Docker_Encrypted/Reference AS Docker_Encrypted,
       CrossZone/Reference AS CrossZone,
       CrossRegional/Reference AS CrossRegional
FROM   Comparison_of_duration;

CREATE VIEW Relative_performance_tpr AS
SELECT document_length,
       Docker/Reference AS Docker,
       Docker_SDN/Reference AS Docker_SDN,
       Docker_Encrypted/Reference AS Docker_Encrypted,
       CrossZone/Reference AS CrossZone,
       CrossRegional/Reference AS CrossRegional
FROM   Comparison_of_tpr;

# Now we analyze resulting performance losses of causers

CREATE VIEW Resulting_Transfer_Performance_Losses AS
SELECT document_length,
       Docker/Reference AS 'Loss caused by containerization',
       Docker_SDN/Docker AS 'Loss caused by SDN',
       Docker_Encrypted/Docker_SDN AS 'Loss caused by encryption'
FROM   Comparison_of_transfer;


CREATE VIEW Resulting_RPS_Performance_Losses AS
SELECT document_length,
       Docker/Reference AS 'Loss caused by containerization',
       Docker_SDN/Docker AS 'Loss caused by SDN',
       Docker_Encrypted/Docker_SDN AS 'Loss caused by encryption'
FROM   Comparison_of_rps;

CREATE VIEW Resulting_TPR_Performance_Losses AS
SELECT document_length,
       Reference/Docker AS 'Loss caused by containerization',
       Docker/Docker_SDN AS 'Loss caused by SDN',
       Docker_SDN/Docker_Encrypted AS 'Loss caused by encryption'
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
