#!/usr/bin/env ruby

require 'optparse'
require 'yaml'

ITERMOCIL_NAME = "kubeexec"

def get_pods(search_term)
  cmd = "kubectl get pods | grep ^#{search_term} | awk '{print $1}' | xargs"
  `#{cmd}`.split
end

def get_itermocil_yaml_config(pods, command_to_execute, container)
  panes_config = pods.map do |pod|
    cmd = "kubectl exec -it #{pod}"
    cmd << " -c #{container}" if container
    cmd << " #{command_to_execute}"
    {'commands' => [cmd]}
  end

  {
    'windows' => [
      {
        'name' => ITERMOCIL_NAME,
        'layout' => 'tiled',
        'panes' => panes_config
      }
    ]
  }.to_yaml
end

def execute_itermocil(config)
  filename = File.expand_path("~/.itermocil/#{ITERMOCIL_NAME}.yml")
  File.write(filename, config)
  `itermocil #{ITERMOCIL_NAME}`
  File.delete(filename)
end

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: kubeexec <search term> [-c <container>] [-s] <command>"

  opts.on("-c", "--container [String]", "The name of the container to exec in the pod (if multiple containers are defined).") do |c|
    options[:container] = c
  end

  opts.on("-s", "--show", "Shows the generated iTermocil configuration file, but doesn't execute it.") do |s|
    options[:show] = s
  end

  opts.on_tail("-h", "--help", "Show this message.") do
    puts opts
    exit
  end
end

optparse.parse!

search_term = ARGV[0]
command_to_execute = ARGV[-1]

unless search_term && command_to_execute
  puts optparse
  exit 1
end

pods = get_pods(search_term)
config = get_itermocil_yaml_config(pods, command_to_execute, options[:container])

if options[:show]
  puts config
else
  execute_itermocil(config)
end
