require_relative 'api_request_manager.rb'

class JudgeSessionValidator

  @@api_request_manager = APIRequestManager.new

  # determines whether the judging session is active and replies if there's not an active session
  def active_judging_session(judging_status, client, data)
      if !judging_status
        client.say(text: "There is not an active judging session", channel: data.channel)
      end
      return judging_status
  end

  # validates the season
  def validate_season(season, client, data)
    semesters = @@api_request_manager.semesters
    seasons = semesters.map {|sem_object| sem_object['semester']['season']}.uniq
    valid = seasons.include? season
    if !valid 
      client.say(text: generate_error_from_options(seasons, "season"), channel: data.channel)
    end
    valid
  end

  # validates the year
  def validate_year(year, client, data)
    semesters = @@api_request_manager.semesters
    years = semesters.map {|sem_object| sem_object['semester']['year'].to_s}.uniq
    valid = years.include? year.to_s
    if !valid 
      client.say(text: generate_error_from_options(years, "year"), channel: data.channel)
    end
    valid
  end

  # validates the type
  def validate_type(type, bot_types, client, data)
    valid = bot_types.include? type
    if !valid
      client.say(text: generate_error_from_options(@bot_types, "type"), channel: data.channel)
    end
    valid
  end

  # validates the event
  def validate_event(event, client, data)
    events = @@api_request_manager.events
    events = events.map {|event| event['event_type']}.uniq
    valid = events.include? event
    if !valid
      client.say(text: generate_error_from_options(events, "event"), channel: data.channel)
    end
    valid
  end

  # generates an error string from a category and string options array
  def generate_error_from_options(options, category)
    list = ""
    options.each do |elem|
      list << elem + ", "
    end
    list.chop!
    list.chop!
    "Please enter a valid " + category + " out of " + list
  end

end