
def fields_for_leaderboard(judge_counts)
  fields = []
  leaderboard_hash = create_leaderboard_hash(judge_counts)
  fields << {title: "Leader", value: "@" + leaderboard_hash.sort_by {|k,v| v}.reverse[0][0].to_s, short: true}
  fields << {title: "Full Leaderboard", value: create_leaderboard(leaderboard_hash), short: false}
  fields
end

def create_leaderboard_hash(judge_counts)
  leaderboard_hash = Hash.new
  judge_counts.each do |slack_id, count|
    judge = name_from_slack_id(slack_id)
    leaderboard_hash[judge] = count
  end
  leaderboard_hash
end

def create_leaderboard(leaderboard_hash)
  leaderboard = ""
  sorted_array = leaderboard_hash.sort_by {|k,v| v}.reverse
  sorted_array.each do |entry|
    leaderboard << "@" + entry[0].to_s + ": " + entry[1].to_s + "\n"
  end
  leaderboard
end

def name_from_slack_id(slack_id) 
  users = @slack.users_info(user: slack_id)
  users = users_to_hash(users.to_s)
  name = users["name"]
end

# slack web client api returns string of information which must be transformed into hash to be useable
def users_to_hash(str)
  array = str.split(',')
  hash = Hash.new
  array.each do |e|
    key_value = e.split('=')
    hash[key_value[0].strip!] = key_value[1]
  end
  hash
end