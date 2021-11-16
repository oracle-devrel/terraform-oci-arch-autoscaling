#!/bin/bash

echo '== [compute_instance1] 1. Install Oracle instant client & Python3 stuff'
if [[ $(uname -r | sed 's/^.*\(el[0-9]\+\).*$/\1/') == "el8" ]]
then 
  if [[ $(uname -m) == "aarch64" ]]
  then
    echo '=== 2.1 aarch64 platform & OL8' 
    yum install -y https://yum.oracle.com/repo/OracleLinux/OL8/oracle/instantclient/aarch64/getPackage/oracle-instantclient${oracle_instant_client_version_short}-basic-${oracle_instant_client_version_short}.0.0.0-1.aarch64.rpm
    yum install -y https://yum.oracle.com/repo/OracleLinux/OL8/oracle/instantclient/aarch64/getPackage/oracle-instantclient${oracle_instant_client_version_short}-sqlplus-${oracle_instant_client_version_short}.0.0.0-1.aarch64.rpm
    yum install -y python36
    yum install -y python3-devel
    pip3 install --upgrade setuptools
  else
    echo '=== 2.1 x86_64 platform & OL8'
    dnf install -y https://yum.oracle.com/repo/OracleLinux/OL8/oracle/instantclient/x86_64/getPackage/oracle-instantclient${oracle_instant_client_version_short}-basic-${oracle_instant_client_version_short}.0.0.0-1.x86_64.rpm
    dnf install -y https://yum.oracle.com/repo/OracleLinux/OL8/oracle/instantclient/x86_64/getPackage/oracle-instantclient${oracle_instant_client_version_short}-sqlplus-${oracle_instant_client_version_short}.0.0.0-1.x86_64.rpm
    yum install -y python36
  fi  
else
  if [[ $(uname -m) == "aarch64" ]]
  then      
    echo '=== 2.1 aarch64 platform & OL7' 
    yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/aarch64/getPackage/oracle-instantclient${oracle_instant_client_version_short}-basic-${oracle_instant_client_version_short}.0.0.0-1.aarch64.rpm
    yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/aarch64/getPackage/oracle-instantclient${oracle_instant_client_version_short}-sqlplus-${oracle_instant_client_version_short}.0.0.0-1.aarch64.rpm
    yum install -y python36
    yum install -y python3-devel
    pip3 install --upgrade setuptools
  else
    echo '=== 2.1 x86_64 platform & OL7'
    yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient${oracle_instant_client_version_short}-basic-${oracle_instant_client_version_short}.0.0.0-1.x86_64.rpm
    yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient${oracle_instant_client_version_short}-sqlplus-${oracle_instant_client_version_short}.0.0.0-1.x86_64.rpm
    yum install -y python36
  fi
fi 

echo '== [compute_instance1] 2. Install pip3 install for cx_Oracle and flask'
pip3 install cx_Oracle
pip3 install flask

echo '== [compute_instance1] 3. Disabling firewall and starting HTTPD service'
systemctl stop firewalld
systemctl disable firewalld
      
echo '== [compute_instance1] 4. Unzip TDE wallet zip file'
unzip -o /home/opc/${ATP_tde_wallet_zip_file} -d /usr/lib/oracle/${oracle_instant_client_version_short}/client64/lib/network/admin/
      
echo '== [compute_instance1] 5. Move sqlnet.ora to /usr/lib/oracle/.../client64/lib/network/admin/'
cp /home/opc/sqlnet.ora /usr/lib/oracle/${oracle_instant_client_version_short}/client64/lib/network/admin/

echo '== [compute_instance1] 6. Create DEPT table in ATP'
chmod +x /home/opc/db1.sh
/home/opc/db1.sh

echo '== [compute_instance1] 7. Run Flask with ATP access'
python3 --version
chmod +x /home/opc/app.sh
#nohup /home/opc/app.sh > /home/opc/app.log &
echo 'nohup /home/opc/app.sh > /home/opc/app.log &' | sudo tee -a  /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
systemctl enable rc-local
#systemctl status rc-local.service
systemctl start rc-local
sleep 5
ps -ef | grep app
