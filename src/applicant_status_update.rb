
# first sorts participants by average_rating
# simultaneously creates csv to be saved at /public/applicant_statuses.csv and
# updates the statuses of participants based on their score
def update_participant_statuses(accept_num, waitlist_num, results, season, event, year)
  participants = @reg_request_manager.participants_for_event(season, year, event)
  sorted_participants = []
  results.each do |order|
    if order.to_i < participants.length
      sorted_participants << participants[order.to_i]
    end
  end
  CSV.open("public/applicant_statuses_#{event}_#{season}_#{year}.csv", "wb") do |csv|
  sorted_participants.each_with_index do |participant, index|
    status = 'accepted'
    if index < accept_num.to_i
      if participant['role']['attending'] == 1
        status = 'confirmed'
      end
      @reg_request_manager.update_participant_status(participant['role']['id'], status)
    elsif index < accept_num.to_i + waitlist_num.to_i
      status = 'waitlisted'
      @reg_request_manager.update_participant_status(participant['role']['id'], status)
    else
      status = 'rejected'
      @reg_request_manager.update_participant_status(participant['role']['id'], status)
    end
    puts participant['person']['first_name']
    csv << [participant['person']['first_name'], participant['person']['last_name'], 
            participant['person']['email'], participant['role']['id'], status]
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
