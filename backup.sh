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

echo "Backup started: $(date)"

BACKUP_TIME=`date "+%Y%m%d%H%M"`
BACKUP_FOLDER=/tmp/$BACKUP_TIME
BACKUP_DUMP_FILENAME=liferay-dump-$ENVIRONMENT-$BACKUP_TIME.sql.gz
BACKUP_DUMP_FILEPATH=$BACKUP_FOLDER/$BACKUP_DUMP_FILENAME
BACKUP_DUMP_URL=$BACKUP_GITLAB_API_ENDPOINT/liferay-backup/$ENVIRONMENT/$BACKUP_DUMP_FILENAME
BACKUP_DATA_FILENAME=liferay-data-$ENVIRONMENT-$BACKUP_TIME.tar.gz
BACKUP_DATA_FILEPATH=$BACKUP_FOLDER/$BACKUP_DATA_FILENAME
BACKUP_DATA_URL=$BACKUP_GITLAB_API_ENDPOINT/liferay-backup/$ENVIRONMENT/$BACKUP_DATA_FILENAME

mkdir -p $BACKUP_FOLDER

find /data -print0 | sort -z | tar czf $BACKUP_DATA_FILEPATH --no-recursion --null -T -
mysqldump -h"$BACKUP_MARIADB_HOST" -u"$BACKUP_MARIADB_USER" -p"$BACKUP_MARIADB_PASSWORD" --protocol=tcp --all-databases --lock-all-tables --no-tablespaces > $BACKUP_FOLDER/temp.sql

gzip $BACKUP_FOLDER/temp.sql

mv $BACKUP_FOLDER/temp.sql.gz $BACKUP_DUMP_FILEPATH

curl --header "PRIVATE-TOKEN: $BACKUP_GITLAB_ACCESS_TOKEN" --upload-file $BACKUP_DUMP_FILEPATH $BACKUP_DUMP_URL
curl --header "PRIVATE-TOKEN: $BACKUP_GITLAB_ACCESS_TOKEN" --upload-file $BACKUP_DATA_FILEPATH $BACKUP_DATA_URL

echo -n $BACKUP_DUMP_URL > $BACKUP_FOLDER/LATEST
echo -n $BACKUP_DATA_URL >> $BACKUP_FOLDER/LATEST

curl --header "PRIVATE-TOKEN: $BACKUP_GITLAB_ACCESS_TOKEN" --upload-file $BACKUP_FOLDER/LATEST "$BACKUP_GITLAB_API_ENDPOINT/liferay-backup/$ENVIRONMENT/LATEST"

rm -rf $BACKUP_FOLDER 

echo "Backup finished: $(date)"