require 'rubygems'
require 'bundler/setup'
require 'aws-sdk-s3'
require 'colorize'
Dir.glob(File.join('lib', '**', '*.rb')).each { |file| require_relative "#{file}" }
