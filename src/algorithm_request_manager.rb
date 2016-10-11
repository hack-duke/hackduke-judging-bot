
class AlgorithmRequestManager

  @@base_url = "https://hackduke-judging.herokuapp.com/"
  @session_name = 'session'

  def start_judging_session(number, session_name)
    endpoint = @@base_url + 'init'
    @session_name = session_name
    options = { :body => {:num_alts => number, :session_name => @session_name}.to_json,
                         :headers => { 'Content-Type' => 'application/json' } }
    body = HTTParty.post(endpoint, add_auth(options))
    return body['error'].to_s
  end

  def get_judge_decision(number, judge_id)
    endpoint = @@base_url + "get_decision"
    options = { :body => {:num_alts => number, :judge_id => judge_id, :session_name => @session_name}.to_json,
                         :headers => { 'Content-Type' => 'application/json' } }
    body = HTTParty.post(endpoint, add_auth(options))
    if body['error'].to_s == ''
      [body['choice_a'], body['choice_b']]
    else
      [body['error']]
    end
  end

  def perform_judge_decision(judge_id, favored)
    endpoint = @@base_url + "perform_decision"
    options = { :body => {:judge_id => judge_id, :favored => favored, :session_name => @session_name}.to_json,
                           :headers => { 'Content-Type' => 'application/json' } }
    body = HTTParty.post(endpoint, add_auth(options))
    return body['error'].to_s
  end

  def get_results(number)
    endpoint = @@base_url + 'results'
    options = { :body => {:num_alts => number, :session_name => @session_name}.to_json,
                           :headers => { 'Content-Type' => 'application/json' } }
    body = HTTParty.post(endpoint, add_auth(options))
  end

  def curr_session
    endpoint = @@base_url + 'curr_session'
    options = { :body => {:session_name => @session_name}.to_json,
                         :headers => { 'Content-Type' => 'application/json' } }
    body = HTTParty.post(endpoint, add_auth(options))
    return body['error'].to_s
  end

  def add_auth(options)
    options.merge!({basic_auth: {username: ENV['BASIC_AUTH_USERNAME'], password: ENV['BASIC_AUTH_PASSWORD']}})       
  end

end