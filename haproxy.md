<h3> HA-Proxy ( Load Balancer ) Setup on CentOS 7 / RHEL 7 </h3>

<ol>
  <li>Install the package</li>
  <pre>
  yum install haproxy -y
  </pre>
  <li>Edit the configuration file /etc/haproxy/haproxy.conf</li>
  <pre>
  #---------------------------------------------------------------------
# Example configuration for a possible web application.  See the
# full configuration options online.
#
#   http://haproxy.1wt.eu/download/1.4/doc/configuration.txt
#
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#Global settings
#---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
#common defaults that all the 'listen' and 'backend' sections will
#use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

#---------------------------------------------------------------------
#main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend apache-http
    bind *:80
    default_backend apache-http
    mode http
    option tcplog

backend apache-http
    balance source
    mode http
    server server0 x.x.x.x:80 check
    server server1 x.x.x.x:80 check

frontend apache-https
    bind *:443
    default_backend apache-https
    mode http
    option tcplog

backend apache-https
    balance source
    mode http
    server server0 x.x.x.x:443 check
    server server1 x.x.x.x:443 check
  </pre>
  <li> Enable and start the haproxy service </li>
  <pre>systemctl enable haproxy.service</pre>
  <pre>systemctl start haproxy.service</pre>
</ol>
 
