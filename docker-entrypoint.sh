#!/bin/bash
#
# Copyright © 2022 Thiago Moreira (tmoreira2020@gmail.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


set -e

: ${BACKUP_MARIADB_HOST:?"BACKUP_MARIADB_HOST env variable is required"}
: ${BACKUP_MARIADB_USER:?"BACKUP_MARIADB_USER env variable is required"}
: ${BACKUP_MARIADB_PASSWORD:?"BACKUP_MARIADB_PASSWORD env variable is required"}
: ${BACKUP_GITLAB_API_ENDPOINT:?"BACKUP_GITLAB_API_ENDPOINT env variable is required"}
: ${BACKUP_GITLAB_ACCESS_TOKEN:?"BACKUP_GITLAB_ACCESS_TOKEN env variable is required"}
BACKUP_CRON_SCHEDULE="${BACKUP_CRON_SCHEDULE:-0 3 * * *}"

LOGFIFO='/var/log/cron.fifo'
if [[ ! -e "$LOGFIFO" ]]; then
    mkfifo "$LOGFIFO"
fi
CRON_ENV="PARAMS='$PARAMS'"
CRON_ENV="$CRON_ENV\nBACKUP_MARIADB_HOST='$BACKUP_MARIADB_HOST'"
CRON_ENV="$CRON_ENV\nBACKUP_MARIADB_USER='$BACKUP_MARIADB_USER'"
CRON_ENV="$CRON_ENV\nBACKUP_MARIADB_PASSWORD='$BACKUP_MARIADB_PASSWORD'"
CRON_ENV="$CRON_ENV\nBACKUP_GITLAB_API_ENDPOINT='$BACKUP_GITLAB_API_ENDPOINT'"
CRON_ENV="$CRON_ENV\nBACKUP_GITLAB_ACCESS_TOKEN='$BACKUP_GITLAB_ACCESS_TOKEN'"
CRON_ENV="$CRON_ENV\nENVIRONMENT='$ENVIRONMENT'"
echo -e "$CRON_ENV\n$BACKUP_CRON_SCHEDULE /backup.sh > $LOGFIFO 2>&1" | crontab -
crontab -l
cron
tail -f "$LOGFIFO"
