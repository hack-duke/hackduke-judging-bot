#posts slack message with participant information
def post_participants_message(client, data, participant_one, participant_two, color)
  client.web_client.chat_postMessage(
        channel: data.channel,
        as_user: true,
        attachments: [
          {
            pretext: "Please choose between the following two entries",
            author_name:  "First Applicant",
            fields: fields_for_applicant(participant_one),
            color: @default_message_color
          }
        ]
      )
  client.web_client.chat_postMessage(
        channel: data.channel,
        as_user: true,
        attachments: [
          {
            author_name:  "Second Applicant",
            fields: fields_for_applicant(participant_two),
            color: @default_message_color
          }
        ]
      )
end

# checks whether the applicant ID is valid for the current event
def output_for_participant(id, data, requires_current_reviewer=true)
  if all_participant_ids_for_event.include? id
    output = "success"
  else
    output = "Applicant ID " + id.to_s + " does not exist for this event!"
  end
  output
end

# creates slack message field for returning an applicant's info
def fields_for_applicant(p)
  if p['resume'] == nil
    resume_link = @no_resume
  else
    resume_link = p['resume']
  end
  if p['github'] == nil
    github_link = @no_github
  else
    github_link = p['github']
  end
  fields = []
  i = 0
  while i < p['custom'].length
    hash = {}
    hash["title"] = p['custom'][i]
    hash["value"] = p['custom'][i+1]
    hash["short"] = false
    fields << hash
    i += 2
  end
  fields << {title: "Resume Link", value: resume_link, short: resume_link == @no_resume}
  fields << {title: "Github Link", value: github_link, short: github_link == @no_github}
  fields
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
  update_chosen_participants(triangle_students, 'accepted')
  update_chosen_participants(non_triangle_students, 'accepted')
end

def rank_triangle_participants(participants)
  new_hackers = []
  veteran_hackers = []
  participants.each do |participant|
    if ((participant['role']['github'].nil? || participant['role']['graduation_year'] == 2020) && new_hackers.length < 100)
      new_hackers << participant
    elsif (veteran_hackers.length < 150)
        veteran_hackers << participant
    end
  end
  triangle_hackers = new_hackers + veteran_hackers
end

def update_chosen_participants(participants, status)
  participants.each do |participant|
    @reg_request_manager.update_participant_status(participant['role']['id'], status)
  end
end


def all_participant_ids_for_event
  @reg_request_manager.participant_ids_for_event(@bot_season, @bot_year, @bot_event)
end
