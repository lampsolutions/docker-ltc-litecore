#!/bin/sh

cd /opt/litecore/mynode/
exec /sbin/setuser litecore /usr/local/bin/litecore-node start >> /var/log/litecore-node.log 2>&1
