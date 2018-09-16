# Vakhov.me

[Jekyll](http://jekyllrb.com/) + [Jekyll Now](http://jekyllnow.com/) + Custom styles


## cron

```
PATH=/root/bin:/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
23 7 * * 1-5 cd /root/blog && (echo STARTED_`date "+\%Y-\%m-\%d__\%H-\%M-\%S"` && git pull && NOCACHE=1 ./publish next && echo FINISHED_`date "+\%Y-\%m-\%d__\%H-\%M-\%S"`) >> /root/crontab.log 2>&1
```
