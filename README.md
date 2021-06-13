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

# 注意事项

关于logrotate时区的问题：

docker容器的时区需要用copy或挂载宿主机localtime的方式才可以按设定的时区进行切割。如果只是设定了环境变量`TZ=Asia/Shanghai` ，虽然时间看着是正确的，但是对logrotate是不生效的。设置挂载localtime的docker-compose示例如下：

```bash
version: "3.9"

services:
  nginx:
    image: wkii/nginx_logrotate:latest
    container_name: nginx
    restart: always
    networks:
      - nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/certs:/etc/nginx/certs
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/logrotate.d/nginx:/etc/logrotate.d/nginx
      - ./logs:/var/log/nginx
      # 使用服务器时区
      - /etc/localtime:/etc/localtime
    restart: always
    
networks:
  nginx:
```

