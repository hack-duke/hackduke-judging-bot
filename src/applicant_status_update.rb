
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
    if (@triangle_schools.include?(school))
      triangle_students << participant
    else
      non_triangle_students << participant
    end
  end
  non_triangle_students = rank_other_participants(non_triangle_students)
  triangle_students = rank_triangle_participants(triangle_students)
  # update_chosen_participants(triangle_students, 'registered')
  # update_chosen_participants(non_triangle_students, 'registered')
end

def rank_other_participants(participants)
  # We want to accept people so they can use the buses.
  non_triangle_students = []
  participants.each do |participant|
    if non_triangle_students.length < @participants_per_category
      non_triangle_students << participant
    end
  end

  bus_students = []
  flight_students = []
  student_counter = 0
  non_triangle_students.each do |participant|
    school = participant['role']['school']
    if @bus_schools.include?(school)
      bus_students << participant
    elsif student_counter < @flight_hackers
      flight_students << participant
      student_counter += 1
    end
  end
  non_triangle_students
end

# Probably should consider ethnicity and gender
def rank_triangle_participants(participants)
  new_hackers = []
  veteran_hackers = []
  participants.each do |participant|
    info = participant['role']
    # we should probably manually check the "new" hackers
    if ((info['github'].nil? || info['graduation_year'] == @year_freshman) && new_hackers.length < @new_hacker_limit)
      new_hackers << participant
    elsif (veteran_hackers.length < @participants_per_category - @new_hacker_limit)
      veteran_hackers << participant
    end
  end
  triangle_hackers = new_hackers + veteran_hackers
end
