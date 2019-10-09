#!/usr/bin/env bash

set -euo pipefail

SERVICE=$1
BASE_PATH=$2
ARGS=
if [ -n "${3+x}" ]; then
    ARGS=$3
fi

adduser --disabled-password --gecos "" ${SERVICE} || true
usermod -aG sudo ${SERVICE}

SERVICE_PATH=/lib/systemd/system/${SERVICE}.service
cat > ${SERVICE_PATH} <<EOF
[Unit]
Description=${SERVICE} service
ConditionPathExists=${BASE_PATH}/${SERVICE}
After=network.target

[Service]
Type=simple
User=${SERVICE}
Group=${SERVICE}
LimitNOFILE=1048576
LimitNPROC=1048576
EnvironmentFile=/etc/environment

Restart=on-failure
RestartSec=5

WorkingDirectory=${BASE_PATH}
ExecStart=${BASE_PATH}/${SERVICE} ${ARGS}

# make sure log directory exists and owned by syslog
PermissionsStartOnly=true
ExecStartPre=/bin/mkdir -p /var/log/${SERVICE}
ExecStartPre=/bin/chown -R syslog:adm /var/log/${SERVICE}
ExecStartPre=/bin/chmod 755 /var/log/${SERVICE}
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=${SERVICE}

[Install]
WantedBy=multi-user.target
EOF
chown ${SERVICE}: ${SERVICE_PATH}
chmod 0755 ${SERVICE_PATH}
systemctl daemon-reload
systemctl enable ${SERVICE}.service
systemctl start ${SERVICE}.service


cat > /etc/rsyslog.d/30-${SERVICE}.conf <<EOF
template(name="OnlyMsg" type="string" string="%msg:2:$%\n")

if ( \$programname == '${SERVICE}' or \$syslogtag == '${SERVICE}' ) then {
    if ( \$syslogseverity < 5 or \$msg contains "\"Error\"" or \$msg contains "[M] " or \$msg contains "[A] " or \$msg contains "[A] " or \$msg contains "[C] " or \$msg contains "[E] " or \$msg contains "[W] "  ) then {
        action(template="OnlyMsg" type="omfile" file="/var/log/${SERVICE}/error.log")
    } else {
        action(template="OnlyMsg" type="omfile" file="/var/log/${SERVICE}/access.log")
    }
    stop
}

EOF
systemctl restart rsyslog.service


cat > /etc/rsyslog.d/30-${SERVICE}.conf <<EOF
/var/log/${SERVICE}/*.log {
	rotate 12
	daily
	missingok
	notifempty
	copytruncate
	delaycompress
	compress
	maxage 7
}
EOF





