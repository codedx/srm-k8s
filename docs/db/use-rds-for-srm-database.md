# Use Amazon RDS with MariaDB engine for your SRM database

Here are the steps required to use SRM with an external database hosted with AWS RDS:

>Note: SRM currently requires [MariaDB version 10.6.x](https://mariadb.com/kb/en/release-notes-mariadb-106-series/).

1. Your new MariaDB RDS database instance must use a configuration that's compatible with SRM. Follow the [Create a DB Parameter Group instructions](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithParamGroups.html#USER_WorkingWithParamGroups.Creating) to create a new DB Parameter Group named srm-mariadb-recommendation. Then edit the parameters of your new group by using the [Modifying Parameters in a DB Parameter Group instructions](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithParamGroups.html#USER_WorkingWithParamGroups.Modifying) to set the following parameter values:

- optimizer_search_depth=0
- character_set_server=utf8mb4
- collation_server=utf8mb4_general_ci
- lower_case_table_names=1
- log_bin_trust_function_creators=1

>Note: When editing a parameter value, the column to the right of the edit box shows the allowable values (not the current values).

The log_bin_trust_function_creators parameter is required when using MariaDB SQL replication, which is enabled by default with the AWS MariaDB Production template.

2. Provision a new Amazon RDS MariaDB database instance with the srm-mariadb-recommendation DB Parameter Group by following the [installation instructions](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MariaDB.html).

3. Connect to your RDS MariaDB database instance.

4. Create a database user for SRM. You can customize the following statement to create
   an SRM database user named srm (remove 'REQUIRE SSL' when not using TLS).

   CREATE USER 'srm'@'%' IDENTIFIED BY 'enter-a-password-here' REQUIRE SSL;

5. Create an SRM database. The following statement creates an SRM database named srmdb.

   CREATE DATABASE srmdb;

6. Grant required privileges on the SRM database to the database user you created. The
   following statements grant permissions to the srm database user.

   GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, ALTER, REFERENCES, INDEX, DROP, TRIGGER ON srmdb.* to 'srm'@'%';
   FLUSH PRIVILEGES;
