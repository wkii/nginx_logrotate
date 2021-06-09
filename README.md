# 使用方法

此镜像非常简单，就是使用官方Nginx镜像 `nginx:latest` 加上安装了logrotate。

Nginx 官方 docker 会有一个默认的日期切割配置文件：/etc/logrotate.d/nginx：

```ba
/var/log/nginx/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 640 nginx adm
    sharedscripts
    postrotate
        if [ -f /var/run/nginx.pid ]; then
            kill -USR1 `cat /var/run/nginx.pid`
        fi
    endscript
}
```

直接使用，即可以自动滚动`/var/log/nginx/` 下的所有扩展名为`.log` 的日志文件。

如果要替换文件，可以使用Volumer挂载的方式替换掉默认的这个 `/etc/logrotate.d/nginx` 文件。

如下例的配置，日志保留60天，滚动日志（未压缩时）扩展名后加上日期格式，如`error.log-20211001`：

```bas
/var/log/nginx/*.log {
    daily
    missingok
    rotate 60
    compress
    delaycompress
    dateext
    notifempty
    sharedscripts
    postrotate
        if [ -f /var/run/nginx.pid ]; then
            kill -USR1 `cat /var/run/nginx.pid`
        fi
    endscript
}
```

