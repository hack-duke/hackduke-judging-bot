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


def rank_participants_by_school
  participants = @reg_request_manager.participants_for_event(@bot_season, @bot_year, @bot_event)
  duke_students = []
  non_duke_students = []
  participants.each do |participant|
    if ((participant['role']['school'].include? 'Duke') && (duke_students.length < 50))
      duke_students << participant
    else 
      if (!(participant['role']['school'].include? 'Duke') && (non_duke_students.length < 50))
        non_duke_students << participant
      end
    end
  end
  update_chosen_participants(duke_students, 'accepted')
  update_chosen_participants(non_duke_students, 'accepted')
end

def update_chosen_participants(participants, status)
  participants.each do |participant|
    @reg_request_manager.update_participant_status(participant['role']['id'], status)
  end
end


def all_participant_ids_for_event
  @reg_request_manager.participant_ids_for_event(@bot_season, @bot_year, @bot_event)
end
