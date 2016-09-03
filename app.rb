require 'sinatra'
require_relative 'judge_bot'

configure do
  JudgeBot.run
end

get '/' do
  'Hello world!'
end