FROM centos:centos6
RUN mkdir -p /opt/chef/
RUN yum install -y hostname
ADD recipe.rb /opt/chef/recipe.rb
RUN curl -L http://www.opscode.com/chef/install.sh | bash
RUN chef-apply /opt/chef/recipe.rb
