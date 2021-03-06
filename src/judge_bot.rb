require 'slack-ruby-client'
require 'dotenv'
require_relative '../slack-ruby-bot/slack-ruby-bot'
require_relative 'applicant_status_update.rb'
require_relative 'algorithm_request_manager.rb'
require_relative 'registration_request_manager.rb'
require_relative 'judge_session_validator.rb'
require_relative 'judge_participant_handler.rb'
require_relative 'judge_leaderboard_handler.rb'

class JudgeBot < SlackRubyBot::Bot

  Slack.configure do |config|
    Dotenv.load
    config.token = ENV['SLACK_API_TOKEN']
  end

  # constants
  @slack = Slack::Web::Client.new
  @algo_request_manager = AlgorithmRequestManager.new
  @reg_request_manager = RegistrationRequestManager.new
  @session_validator = JudgeSessionValidator.new
  @success = 'success'
  @error = 'error'
  @default_message_color = '#36a64f'
  @no_resume = 'No resume'
  @no_github = 'No github'
  @no_portfolio = 'No portfolio'
  @no_website = 'No website'
  @bot_types = ['applicant', 'project']
  @choice_a = 'CHOICE_A'
  @choice_b = 'CHOICE_B'
  # @year_freshman = 2020
  @participants_per_category = 250
  @new_hacker_limit = 100

  # judging session variables
  @judging_status = false
  @bot_season = 'season'
  @bot_event = 'event'
  @bot_type = 'applicant'
  @bot_year = 9999

  help do
    title 'Judging Bot'
    desc 'Performs pairwise judging on applicants and projects.'

    command 'j or judge' do
      desc 'Retrieves a pair of entries for the user to judge.'
    end

    command '1/2 or select <first/second>' do
      desc 'Selects the first or second entry in a pairwise comparison'
    end

    command 'l or leaderboard' do
      desc 'Shows a leaderboard for the judges'
    end

    # command 'start judging session <season> <event> <year> <type>' do
    #   desc 'This starts a judging session with the specified season, event, year, and type'
    # end

    # command 'stop judging session' do 
    #   desc 'This stops the currently active judging session if available'
    # end

    # command 'update applicant status <accept number> <waitlist number>' do
    #   desc 'Updates accepted, waitlisted, and rejected participants based on given numbers (applicant-specific)'
    # end

    # command 'applicant <ID>' do
    #   desc 'Displays information about the specified applicant (applicant-specific)'
    # end
  end

  command 'judge' do |client, data, match|
    judge_command(client, data, match)
  end

  command 'j' do |client, data, match|
    judge_command(client, data, match)
  end

  command 'leaderboard' do |client, data, match|
    leaderboard_command(client, data, match)
  end

  command 'l' do |client, data, match|
    leaderboard_command(client, data, match)
  end

  match /^select (?<firstsecond>\w*)$/i do |client, data, match|
    select_command(client, data, match)
  end

  command '1' do |client, data, match|
    select_command(client, data, match, 1)
  end

  command '2' do |client, data, match|
    select_command(client, data, match, 2)
  end

  match /^start judging session (?<season>\w*) (?<event>\w*) (?<year>\d{4}*) (?<type>\w*)$/i do |client, data, match|
    if @judging_status
      client.say(text: 'An active ' + @bot_type + ' judging session for ' + @bot_event + ' ' + 
                 @bot_season + ' ' + @bot_year.to_s + ' is already active!' , channel: data.channel)
      return
    end
    @bot_season = "#{match[:season]}".to_s
    @bot_event = "#{match[:event]}".to_s
    @bot_year = "#{match[:year]}".to_i
    @bot_type = "#{match[:type]}".to_s
    valid_season = @session_validator.validate_season(@bot_season, client, data)
    valid_event = @session_validator.validate_event(@bot_event, client, data)
    valid_year = @session_validator.validate_year(@bot_year, client, data)
    valid_type =  @session_validator.validate_type(@bot_type, @bot_types, client, data)
    return unless valid_season && valid_event && valid_year && valid_type
    session_name = @bot_season + @bot_event + @bot_year.to_s + @bot_type
    ids = @reg_request_manager.participant_ids_for_event(@bot_season, @bot_year, @bot_event)
    error = @algo_request_manager.start_judging_session(ids, session_name)
    if error == ''
      @judging_status = true
      client.say(text: 'An active ' + @bot_type + ' judging session for ' + @bot_event + ' ' + 
                 @bot_season + ' ' + @bot_year.to_s + ' has begun!' , channel: data.channel)
    else
      client.say(text: error, channel: data.channel)
    end
  end

  command 'stop judging session' do |client, data, match|
    return unless @session_validator.active_judging_session(@judging_status, client, data)
    @judging_status = false
     client.say(text: 'The active ' + @bot_type + ' judging session for ' + @bot_event + ' ' + 
               @bot_season + ' ' + @bot_year.to_s + ' has been stopped!' , channel: data.channel)
  end

  match /^applicant (?<id>\w*)/i do |client, data, match|
    return unless @session_validator.active_judging_session(@judging_status, client, data)
    id = "#{match[:id]}".to_i
    output = output_for_participant(id, data, false)
    if output == @success
       p = @reg_request_manager.participant_for_id(id)
       client.web_client.chat_postMessage(
        channel: data.channel,
        as_user: true,
        attachments: [
          {
            pretext: 'Information for applicant ' + p['id'].to_s,
            fields: fields_for_applicant(p),
            color: @default_message_color
          }
        ]
      )
    else
      client.say(text: output, channel: data.channel)
    end
  end

  match /^update applicant status (?<accept_num>\d*) (?<waitlist_num>\d*)$/i do |client, data, match|
    return unless @session_validator.active_judging_session(@judging_status, client, data)
    accept_num = "#{match[:accept_num]}".to_i
    waitlist_num = "#{match[:waitlist_num]}".to_s
    ids = @reg_request_manager.participant_ids_for_event(@bot_season, @bot_year, @bot_event)
    body = @algo_request_manager.get_results(ids)
    if body['error'].to_s == ''
      results = body['ranking']
      update_participant_statuses(accept_num, waitlist_num, results, @bot_season, @bot_event, @bot_year)
      client.say(text: 'Participant statuses updated!', channel: data.channel)
    else 
      client.say(text: body['error'], channel: data.channel)
    end
  end

  # match /^rank (?<season>\w*) (?<event>\w*) (?<year>\d{4}*)$/i do |client, data, match|
  #   @bot_season = "#{match[:season]}".to_s
  #   @bot_event = "#{match[:event]}".to_s
  #   @bot_year = "#{match[:year]}".to_i
  #   valid_season = @session_validator.validate_season(@bot_season, client, data)
  #   valid_event = @session_validator.validate_event(@bot_event, client, data)
  #   valid_year = @session_validator.validate_year(@bot_year, client, data)
  #   return unless valid_season && valid_event && valid_year
  #   participants = @reg_request_manager.participants_for_event(@bot_season, @bot_year, @bot_event)
  #   # Assuming participants is sorted by rank
  #   rank_participants(participants)
  # end

end

def select_command(client, data, match, shortcut=0)
  return unless @session_validator.active_judging_session(@judging_status, client, data)
  if shortcut == 0
    result = "#{match[:firstsecond]}".to_s
  elsif shortcut == 1
    result = 'first'
  elsif shortcut == 2
    result = 'second'
  end
  if result.downcase != 'first' && result.downcase != 'second'
    client.say(text: 'You must select the first or second!', channel: data.channel)
  else
    if result == 'first' 
      favored = @choice_a
    else
      favored = @choice_b
    end
    error = @algo_request_manager.perform_judge_decision(data.user, favored)
    if error == '' 
      client.say(text: 'Successfully performed judge decision, please choose again!', channel: data.channel)
      judge_command(client, data, match)
    else
      client.say(text: error, channel: data.channel)
    end
  end
end

def leaderboard_command(client, data, match)
  return unless @session_validator.active_judging_session(@judging_status, client, data)
  ids = @reg_request_manager.participant_ids_for_event(@bot_season, @bot_year, @bot_event)
  body = @algo_request_manager.get_results(ids)
  if body['error'].to_s == ''
    judge_counts = body['judge_counts']
    if judge_counts.length == 0
      client.say(text: "No entries have been judged!", channel: data.channel)
    else
      client.web_client.chat_postMessage(
        channel: data.channel,
        as_user: true,
        attachments: [
          {
            title: "Current Leaderboard",
            fields: fields_for_leaderboard(body['judge_counts']),
            color: @default_message_color
          }
        ]
      )
    end
  else
    client.say(text: body['error'], channel: data.channel)
  end
end

def judge_command(client, data, match)
  return unless @session_validator.active_judging_session(@judging_status, client, data)
  ids = @reg_request_manager.participant_ids_for_event(@bot_season, @bot_year, @bot_event)
  result = @algo_request_manager.get_judge_decision(ids, data.user)
  participant_one = @reg_request_manager.participant_for_id(result[0])
  participant_two = @reg_request_manager.participant_for_id(result[1])
  post_participants_message(client, data, participant_one, participant_two, @default_message_color)
end
  
