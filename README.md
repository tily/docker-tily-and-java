# dockerfile for tily and java

## what's installed

* git
* tmux
* java (open jdk 1.6 & 1.7)
* vim (with nerdtree & eclim)
* gradle
* scala (sbt)
* mysqld (5.6)

## how to use

* in host
```
$ docker pull tily/tily-and-java
$ docker run -ti tily/tily-and-java bash
```
* in container
```
# su tily
## start up eclim
$ Xvfb :1 -screen 0 1024x768x24 &
$ DISPLAY=:1 /opt/eclipse/eclimd &
```
