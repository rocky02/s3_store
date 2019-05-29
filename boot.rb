require 'aws-sdk-s3'
require 'colorize'
require 'byebug'
require_relative 'application'
Dir.glob(File.join('lib', '**', '*.rb')).each { |file| require_relative "#{file}" }
