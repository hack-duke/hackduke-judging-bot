require 'httparty'

class RegistrationRequestManager

  @@base_url = "https://hackduke-api.herokuapp.com/"

  def participant_ids_for_event(bot_season, bot_year, bot_event)
    endpoint = @@base_url + 'people/ids'
    options = { body: {:season => bot_season, :year => bot_year, :event_type => bot_event, :role => 'participant'} }
    body = HTTParty.post(endpoint, add_auth(options))
    if body.code != 200
      return []
    else
      return body
    end
  end

  def participants_for_event(bot_season, bot_year, bot_event)
    endpoint = @@base_url + 'people/roles'
    options = { body: {:season => bot_season, :year => bot_year, :event_type => bot_event, :role => 'participant'} }
    body = HTTParty.post(endpoint, add_auth(options))
    if body.code != 200
      return []
    else
      return body
    end
  end

  def participant_for_id(id)
    endpoint = @@base_url + 'people/id'
    options = { body: {:id => id, :role => 'participant'} }
    body = HTTParty.post(endpoint, add_auth(options))
    if body.code != 200
      return {}
    else
      return body
    end
  end

  def update_participant_status(id, status)
    endpoint = @@base_url + 'people/update_role_external'
    options = { body: {:id => id, :role => 'participant', :participant => {:status => status}} }
    body = HTTParty.post(endpoint, add_auth(options))
    if body.code != 200
      return 
    else
      return body
    end
  end

  def semesters
    endpoint = @@base_url + 'semesters'
    body = HTTParty.get(endpoint, add_auth({}))
  end

  def events
    endpoint = @@base_url + 'events'
    body = HTTParty.get(endpoint, add_auth({}))
  end

  def add_auth(options)
    options.merge!({basic_auth: {username: ENV['BASIC_AUTH_USERNAME'], password: ENV['BASIC_AUTH_PASSWORD']}})       
  end

end
