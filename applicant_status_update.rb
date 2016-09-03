
# first sorts participants by average_rating
# simultaneously creates csv to be saved at /public/applicant_statuses.csv and
# updates the statuses of participants based on their score
def update_participant_statuses(accept_num, waitlist_num, results, season, event, year)
  participants = @api_request_manager.participants_for_event(season, year, event)
  sorted_participants = []
  results.each do |order|
    if order.to_i < participants.length
      sorted_participants << participants[order.to_i]
    end
  end
  CSV.open("public/applicant_statuses_#{event}_#{season}_#{year}.csv", "wb") do |csv|
  sorted_participants.each_with_index do |participant, index|
    status = 'accepted'
    if index < accept_num
      if participant['role']['attending'] == 1
        status = 'confirmed'
      end
      @api_request_manager.update_participant_status(participant['role']['id'], status)
    elsif index < accept_num + waitlist_num
      status = 'waitlisted'
      @api_request_manager.update_participant_status(participant['role']['id'], status)
    else
      status = 'rejected'
      @api_request_manager.update_participant_status(participant['role']['id'], status)
    end
    csv << [participant['person']['first_name'], participant['person']['last_name'], 
            participant['person']['email'], participant['role']['id'], status]
    end
  end
end
