FROM centos:centos6

RUN adduser tily

RUN yum install -y hostname git sudo vim ncurses-devel
RUN yum groupinstall -y "development tools"

## javas
RUN yum install -y java-1.6.0-openjdk java-1.6.0-openjdk-demo java-1.6.0-openjdk-devel java-1.6.0-openjdk-javadoc java-1.6.0-openjdk-src
RUN yum install -y java-1.7.0-openjdk java-1.7.0-openjdk-demo java-1.7.0-openjdk-devel java-1.7.0-openjdk-javadoc java-1.7.0-openjdk-src
RUN yum install -y ant

## libevent
RUN cd /usr/local/src && curl -LO https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz
RUN cd /usr/local/src && tar -xvf libevent-2.0.21-stable.tar.gz && cd libevent-2.0.21-stable && ./configure && make && make install
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/libevent.conf && ldconfig

## tmux
RUN cd /usr/local/src && curl -LO http://downloads.sourceforge.net/tmux/tmux-1.9a.tar.gz
RUN cd /usr/local/src && tar -xvf tmux-1.9a.tar.gz && cd tmux-1.9a && ./configure && make && make install

## eclipse
RUN cd /usr/local/src && curl -LO http://ftp.jaist.ac.jp/pub/eclipse/technology/epp/downloads/release/luna/SR1/eclipse-java-luna-SR1-linux-gtk-x86_64.tar.gz
RUN cd /opt && tar xzvf /usr/src/eclipse-java-luna-SR1-linux-gtk-x86_64.tar.gz

## xvfb
RUN yum remove -y fakesystemd
RUN yum groupinstall -y "x window system"
RUN yum install -y xorg-x11-server-Xvfb

## eclim
RUN yum install -y libXfont
RUN mkdir -p /opt/eclim
RUN cd /opt/eclim && curl -LO http://jaist.dl.sourceforge.net/project/eclim/eclim/2.3.2/eclim_2.3.2.jar
RUN sudo -u tily java -Dvim.files=/home/tily/.vim -Declipse.home=/opt/eclipse -jar /opt/eclim/eclim_2.3.2.jar install
RUN sudo -u tily Xvfb :1 -screen 0 1024x768x24 &
RUN sudo -u tily DISPLAY=:1 /opt/eclipse/eclimd &

## chef
RUN curl -L http://www.opscode.com/chef/install.sh | bash
