# frozen_string_literal: true

require 'etc'

home_path = ENV['HOME']
app_path = "#{home_path}/workspace/grizzly"

pid    "#{app_path}/current/tmp/pids/unicorn.grizzly.pid"
listen "#{app_path}/current/tmp/sockets/unicorn.grizzly.sock", backlog: 8096

timeout 30

stderr_path 'log/unicorn.stderr.log'
stdout_path 'log/unicorn.stdout.log'

# worker_processes Etc.nprocessors * 2

preload_app true

# before_exec do |_server|
#   ENV['BUNDLE_GEMFILE'] = "#{app_path}/current/Gemfile"
# end

before_fork do |server, _worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH # rubocop:disable Lint/HandleExceptions
      # someone else did our job for us
    end
  end
end

after_fork do |_server, _worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end
