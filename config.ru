require 'rubygems'
require 'bundler'
require 'dotenv'
require 'sinatra'
require_relative 'src/judge_bot'

Bundler.require
Dotenv.load
run Sinatra::Application

use Rack::Auth::Basic, "Protected Area" do |username, password|
  username == ENV['BASIC_AUTH_USERNAME'] && password == ENV['BASIC_AUTH_PASSWORD']
end

get '/' do
  "Hello World"
end

get '/start' do
  Thread.new {JudgeBot.run}
  'Judging Bot Started'
end
