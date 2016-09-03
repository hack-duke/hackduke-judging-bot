require 'rubygems'
require 'bundler'
require 'sinatra'
require_relative 'src/judge_bot'

Bundler.require
run Sinatra::Application

get '/' do
  "Hello World"
end


get '/start' do
  JudgeBot.run
end
