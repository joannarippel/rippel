#!/bin/bash

echo "Creating directory structure under /home/student/Europa with given permissions..."
mkdir -p /home/student/Europa
cd /home/student/Europa

mkdir -m 750 Germania
touch Germania/file1
chmod 771 Germania/file1

touch Franta
chmod 444 Franta

mkdir -m 750 Italia
touch Italia/file1
chmod 750 Italia/file1

touch Spania
chmod 621 Spania

touch Romania
chmod 000 Romania

touch Bulgaria
chmod 357 Bulgaria

echo "Changing permissions recursively for all files in Europa so group 'student' has read and write access..."
chmod -R g+rw /home/student/Europa

echo "Removing all rights from others for files ending with 'ia'..."
find /home/student/Europa -type f -name '*ia' -exec chmod o-rwx {} \;

echo "Creating users ana, gigel, chuck..."
sudo useradd ana
sudo useradd gigel
sudo useradd chuck

echo "Logging in as ana and creating files..."
sudo -u ana bash -c 'echo "Ana are mere" > ~/mere'
sudo -u ana bash -c 'echo "Ana are pere" > ~/pere'
chmod 764 /home/ana/mere
chmod 764 /home/ana/pere

echo "Modifying file permissions for 'mere' and 'pere' files..."
chmod o=w /home/ana/mere
chmod o=rw /home/ana/pere

echo "Checking permissions..."
ls -l /home/ana/mere /home/ana/pere

echo "Checking and creating users cameron and putin if needed..."
id cameron &>/dev/null || sudo useradd cameron
id putin &>/dev/null || sudo useradd putin

echo "Checking permissions on ~cameron and ~putin..."
ls -ld /home/cameron /home/putin

echo "Listing contents of ~cameron as putin..."
sudo -u putin ls /home/cameron

echo "Removing group and other rights from /home/cameron to make it private..."
chmod go-rwx /home/cameron

echo "Verifying that putin cannot access /home/cameron..."
sudo -u putin ls /home/cameron || echo "Access denied to putin as expected."

echo "Creating public_html directory and files for cameron..."
mkdir -p /home/cameron/public_html
touch /home/cameron/public_html/index.html
touch /home/cameron/secret

chmod o+x /home/cameron
chmod o+rX /home/cameron/public_html /home/cameron/public_html/index.html

echo "Verification done."
