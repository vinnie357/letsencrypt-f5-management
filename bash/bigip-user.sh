#!/bin/bash
echo "Enter admin user name "
read admin
echo "Enter NEW user name "
read user
echo "enter NEW user password"
read -s userPass
echo "Enter hosts: hostname hostname "
read hosts

for host in $hosts
do
    echo "adding $user to $host"
    ssh -oStrictHostKeyChecking=no $admin@$host "tmsh create auth user $user partition-access add { all-partitions { role admin } } shell bash password "$userPass";tmsh save sys config"
done
