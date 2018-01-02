apt_update 'update'

apt_package "unzip" do
  package_name "unzip"
  action "install"
end

apt_package "unzip" do
  action :install
end

apt_package %w(libwww-perl libdatetime-perl) do
  action :install
end

execute "download CloudWatchMonitoringScripts" do
  command "curl http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip -O"
  cwd "/tmp"
  action :run
end

execute "unzip CloudWatchMonitoringScripts" do
  command "unzip CloudWatchMonitoringScripts-1.2.1.zip -d /opt"
  cwd "/tmp"
  action :run
end

template "/opt/aws-scripts-monawscreds.conf" do
  variables ({
      :aws_access_key_id => node[:aws_memory][:aws_access_key_id],
      :aws_secret_key => node[:aws_memory][:aws_secret_key]
  })
  source "awscreds.conf.erb"
  action :create
end

cron 'crontab mon-put-instance-data' do
  hour '*'
  minute '5'
  month '*'
  weekday '*'
  user node[:aws_memory][:user]
  command "/opt/aws-scripts-mon/mon-put-instance-data.pl --mem-used-incl-cache-buff --mem-util --disk-space-util --disk-path=/ --from-cron"
end
