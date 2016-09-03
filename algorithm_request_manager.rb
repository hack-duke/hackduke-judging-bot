
class AlgorithmRequestManager

  @@base_url = "https://hackduke-judging.herokuapp.com/"
  @session_name = 'session'

  def start_judging_session(number, session_name)
    endpoint = @@base_url + 'init'
    @session_name = session_name
    body = HTTParty.post(endpoint, :body => {:num_alts => number, :session_name => @session_name}.to_json,
                         :headers => { 'Content-Type' => 'application/json' })
    return body['error'].to_s
  end

  def get_judge_decision(judge_id)
    endpoint = @@base_url + "get_decision"
    body = HTTParty.post(endpoint, :body => {:judge_id => judge_id, :session_name => @session_name}.to_json,
                         :headers => { 'Content-Type' => 'application/json' })
    if body['error'].to_s == ''
      [body['choice_a'], body['choice_b']]
    else
      [body['error']]
    end
  end

  def perform_judge_decision(judge_id, favored)
    endpoint = @@base_url + "perform_decision"
    body = HTTParty.post(endpoint, :body => {:judge_id => judge_id, :favored => favored, :session_name => @session_name}.to_json,
                           :headers => { 'Content-Type' => 'application/json' })
    return body['error'].to_s
  end

  def get_results
    endpoint = @@base_url + 'results'
    body = HTTParty.post(endpoint, :body => {:session_name => @session_name}.to_json,
                       		 :headers => { 'Content-Type' => 'application/json' })
  end

  def curr_session
    endpoint = @@base_url + 'curr_session'
    body = HTTParty.post(endpoint, :body => {:session_name => @session_name}.to_json,
                         :headers => { 'Content-Type' => 'application/json' })
    return body['error'].to_s
  end

end