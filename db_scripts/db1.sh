export LD_LIBRARY_PATH=/usr/lib/oracle/${oracle_instant_client_version_short}/client64/lib
/usr/lib/oracle/${oracle_instant_client_version_short}/client64/bin/sqlplus admin/${ATP_password}@${ATP_alias} @/home/opc/db1.sql > /home/opc/db1.log
