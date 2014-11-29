def main
	add_user
	install_development_tools
	install_sudo
	install_git
	install_vim
	install_libevent
	install_ncurses
	install_tmux
	install_systemd	
	install_xvfb
	install_javas
	install_scala
	install_eclipse
	install_eclim
end

def add_user
	user 'tily' do
		action :create
	end
end

def install_development_tools
	execute 'development tools' do
		command 'yum groupinstall -y "Development Tools"'
	end
end

def install_sudo
	package 'sudo' do
		action :install
	end
end

def install_git
	package 'git' do
		action :install
	end
end

def install_javas
	pkgs = %w(
		java-1.6.0-openjdk
		java-1.6.0-openjdk-demo
		java-1.6.0-openjdk-devel
		java-1.6.0-openjdk-javadoc
		java-1.6.0-openjdk-src
		java-1.7.0-openjdk
		java-1.7.0-openjdk-demo
		java-1.7.0-openjdk-devel
		java-1.7.0-openjdk-javadoc
		java-1.7.0-openjdk-src
		ant
	)
	pkgs.each do |pkg|
		package pkg do
			action :install
		end
	end
end

def install_scala
	## install scala and sbt
	file '/etc/yum.repos.d/typesafe.repo' do
		content <<-EOF
[typesafe]
name=Typesafe RPM Repository
baseurl=http://rpm.typesafe.com/
enabled=1
gpgcheck=0
		EOF
		action :create
	end

	package 'typesafe-stack' do
		action :install
	end
end

def install_xvfb
	execute "x window system" do
		user "root"
		command 'yum groupinstall -y "X Window System"'
		action :run
	end

	package "xorg-x11-server-Xvfb" do
		action :install
	end
end

def install_systemd
	execute "swap fakesystemd with real systemd" do
		user "root"
		command 'yum swap -y -- remove fakesystemd -- install systemd systemd-libs'
		action :run
		only_if { `rpm -qa | grep fakesystemd | wc -l`.to_i > 0 }
	end
end

def install_vim
	## install vim
	package "vim" do
		action :install
	end
end

def install_libevent
	remote_file '/usr/local/src/libevent-2.0.21-stable.tar.gz' do
		source 'https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz'
	end

	execute 'libevent' do
		command <<-EOC
			cd /usr/local/src
			tar -xvf libevent-2.0.21-stable.tar.gz
			cd libevent-2.0.21-stable
			./configure && make
			make install
			echo "/usr/local/lib" > /etc/ld.so.conf.d/libevent.conf
			ldconfig
		EOC
	end
end

def install_ncurses
	#pkgs = %w(ncurses-devel ncurses-c++-devel)
	pkgs = %w(ncurses-devel)
	pkgs.each do |pkg|
		package pkg do
			action :install
		end
	end
end

def install_tmux
	remote_file '/usr/local/src/tmux-1.9a.tar.gz' do
		source 'http://downloads.sourceforge.net/tmux/tmux-1.9a.tar.gz'
	end

	execute "tmux" do
		command <<-EOC
			ldconfig
			cd /usr/local/src
			tar -xvf tmux-1.9a.tar.gz
			cd tmux-1.9a
			./configure && make
			make install
		EOC
	end
end

def install_eclipse
        remote_file '/tmp/eclipse-java-luna-SR1-linux-gtk-x86_64.tar.gz' do
                source 'http://ftp.jaist.ac.jp/pub/eclipse/technology/epp/downloads/release/luna/SR1/eclipse-java-luna-SR1-linux-gtk-x86_64.tar.gz'
        end

        execute 'extract eclipse tarball' do
                command 'cd /opt && tar xzvf /tmp/eclipse-java-luna-SR1-linux-gtk-x86_64.tar.gz'
		not_if { File.exists?("/opt/eclipse") }
        end
end

def install_eclim
	package 'libXfont' do
		action :install
	end

	directory '/opt/eclim' do
		action :create
	end

	remote_file '/opt/eclim/eclim_2.3.2.jar' do
		source 'http://jaist.dl.sourceforge.net/project/eclim/eclim/2.3.2/eclim_2.3.2.jar'
	end

	execute 'eclim' do
		user 'tily'
		command <<-EOC
			java -Dvim.files=/home/tily/.vim -Declipse.home=/opt/eclipse -jar /opt/eclim/eclim_2.3.2.jar install
			Xvfb :1 -screen 0 1024x768x24 &
			DISPLAY=:1 /opt/eclipse/eclimd &
		EOC
	end
end

main
