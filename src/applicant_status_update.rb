
# first sorts participants by average_rating
# simultaneously creates csv to be saved at /public/applicant_statuses.csv and
# updates the statuses of participants based on their score
def update_participant_statuses(accept_num, waitlist_num, results, season, event, year)
  CSV.open("public/applicant_statuses_#{event}_#{season}_#{year}.csv", "wb") do |csv|
    results.each do |id|
      body = @reg_request_manager.participant_for_id(id)
      if body.length != 0
        participant = body['role']
        person = body['person']
        csv << [person['first_name'], person['last_name'], person['ethnicity'], person['over_eighteen'],
                person['gender'], participant['id'], participant['school'], participant['resume'],
                participant['graduation_year'], participant['github']]
      else
        puts resume
      end
    end
  end
end


def rank_participants(participants)
  triangle_students = []
  non_triangle_students = []
  participants.each do |participant|
    school = participant['role']['school']
    if (!school.include?('Duke') && !school.include?('North Carolina'))
      if non_triangle_students.length < @participants_per_category
        non_triangle_students << participant
      end
      participants.delete(participant)
    end
  end
  triangle_students = rank_triangle_participants(participants)
  update_chosen_participants(triangle_students, 'registered')
  update_chosen_participants(non_triangle_students, 'registered')
end

# Probably should consider ethnicity and gender
def rank_triangle_participants(participants)
  new_hackers = []
  veteran_hackers = []
  participants.each do |participant|
    info = participant['role']
    if ((info['github'].nil? || info['graduation_year'] == @year_freshman) && new_hackers.length < @new_hacker_limit)
      new_hackers << participant
    elsif (veteran_hackers.length < @participants_per_category - @new_hacker_limit)
      veteran_hackers << participant
    end
  end
  triangle_hackers = new_hackers + veteran_hackers
end
