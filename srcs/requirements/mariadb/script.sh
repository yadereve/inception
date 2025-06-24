#!/bin/bash

mysql_install_db
mysqld --init-file=/etc/mysql/init.sql
