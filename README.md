# dockeray-backup-gitlab

Docker Compose usage

```
  bkp:
    container_name: bkp.mydomain.com
    environment:
      - BACKUP_MARIADB_HOST=dba.mydomain.com
      - BACKUP_CRON_SCHEDULE=* */6 * * *
      - BACKUP_MARIADB_USER=mycustomuser
      - BACKUP_MARIADB_PASSWORD=mycustomuserpassword
      - BACKUP_GITLAB_API_ENDPOINT=https://gitlab.com/api/v4/projects/myprojectid/packages/generic
      - BACKUP_GITLAB_ACCESS_TOKEN=mygitlabtoken
      - ENVIRONMENT=${ENVIRONMENT}
    image: dockeraystack/dockeray-backup-gitlab:10.7.3-1.1.0
    hostname: bkp
    domainname: mydomain.com
    volumes:
      - backup:/data:rw
    links:
      - dba:dba.mydomain.com
    depends_on:
      - dba
    networks:
      - backend
```