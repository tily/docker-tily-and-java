
FROM centos:centos6
MAINTAINER tidnlyam@gmail.com

RUN cat /etc/redhat-release

RUN adduser tily

RUN yum install -y hostname git sudo vim ncurses-devel tar
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
ADD dot.tmux.conf /home/tily/.tmux.conf

## eclipse
RUN cd /usr/local/src && curl -LO http://ftp.jaist.ac.jp/pub/eclipse/technology/epp/downloads/release/luna/SR1/eclipse-java-luna-SR1-linux-gtk-x86_64.tar.gz
RUN cd /opt && tar xzvf /usr/local/src/eclipse-java-luna-SR1-linux-gtk-x86_64.tar.gz

## xvfb
RUN yum remove -y fakesystemd
RUN yum groupinstall -y "x window system"
RUN yum install -y xorg-x11-server-Xvfb

## eclim
RUN yum install -y libXfont
RUN mkdir -p /opt/eclim
RUN cd /opt/eclim && curl -LO http://jaist.dl.sourceforge.net/project/eclim/eclim/2.3.4/eclim_2.3.4.jar
RUN sed -i -e 's/\s*Defaults\s*requiretty$/#Defaults    requiretty/' /etc/sudoers
RUN java -Dvim.files=/home/tily/.vim -Declipse.home=/opt/eclipse -jar /opt/eclim/eclim_2.3.4.jar install
RUN sudo -u tily Xvfb :1 -screen 0 1024x768x24 &
RUN sudo -u tily DISPLAY=:1 /opt/eclipse/eclimd &

## chef
RUN curl -L http://www.opscode.com/chef/install.sh | bash

## scala
ADD typesafe.repo /etc/yum.repos.d/typesafe.repo
RUN yum install -y typesafe-stack

## gradle
RUN cd /usr/local/src && curl -LO https://services.gradle.org/distributions/gradle-2.2.1-bin.zip
RUN sudo -u tily mkdir /home/tily/.gradle
RUN sudo -u tily bash -c "cd /home/tily/.gradle && unzip /usr/local/src/gradle-2.2.1-bin.zip"
RUN sudo -u tily bash -c "cd /home/tily/.gradle && ln -s gradle-2.2.1 gradle"
RUN sudo -u tily bash -c "echo export PATH=$PATH:~/.gradle/gradle/bin >> /home/tily/.bashrc"

## vim: neobundle & nerdtree
RUN chown -R tily:tily /home/tily/.vim
RUN sudo -u tily bash -c "curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh"
ADD dot.vimrc /home/tily/.vimrc
RUN sudo -u tily bash -c 'vim -u /home/tily/.vimrc -i NONE -c "try | NeoBundleUpdate! | finally | q! | endtry" -e -s -V1' || echo 0

## mysql server
RUN yum install -y http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
RUN yum install -y mysql mysql-devel mysql-server mysql-utilities

## ssh server
RUN yum install -y openssh-server

## supervisor
RUN rpm -ivh http://ftp.riken.jp/Linux/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum install -y supervisor
ADD supervisord.conf /etc/supervisord.conf

RUN sed -ri 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config
RUN echo 'root:java' | chpasswd
RUN echo 'tily:java' | chpasswd
RUN /usr/bin/ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -C '' -N ''
RUN /usr/bin/ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N ''

EXPOSE 22
CMD /usr/bin/supervisord -n
