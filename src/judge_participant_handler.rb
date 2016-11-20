#posts slack message with participant information
def post_participants_message(client, data, participant_one, participant_two, color)
  client.web_client.chat_postMessage(
        channel: data.channel,
        as_user: true,
        attachments: [
          {
            pretext: "Please choose between the following two entries by typing '1' or '2'",
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

def post_submissions_message(client, data, submission_one, submission_two, color)
  client.web_client.chat_postMessage(
        channel: data.channel,
        as_user: true,
        attachments: [
          {
            pretext: "Please choose between the following two entries by typing '1' or '2'",
            author_name:  "First Submission",
            fields: fields_for_submission(submission_one),
            color: @default_message_color
          }
        ]
      )
  client.web_client.chat_postMessage(
        channel: data.channel,
        as_user: true,
        attachments: [
          {
            author_name:  "Second Submission",
            fields: fields_for_submission(submission_two),
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

def fields_for_submission(submission)
  fields = []
  fields << {title: "Submission Title", value: submission, short: false}
end

# creates slack message field for returning an applicant's info
def fields_for_applicant(participant)
  puts participant
  role = participant['role']
  if role['resume'] == nil
    resume_link = @no_resume
  else
    resume_link = role['resume']
  end
  if role['website'] == nil
    website_link = @no_website
  else
    website_link = role['website']
  end
  if role['portfolio'] == nil
    portfolio_link = @no_portfolio
  else
    portfolio_link = role['portfolio']
  end
  if role['github'] == nil
    github_link = @no_github
  else
    github_link = role['github']
  end
  fields = []
  i = 0
  while i < role['custom'].length
    hash = {}
    hash["title"] = role['custom'][i]
    hash["value"] = role['custom'][i+1]
    hash["short"] = false
    fields << hash
    i += 2
  end
  fields << {title: "Portfolio Link", value: portfolio_link, short: portfolio_link == @no_portfolio}
  fields << {title: "Website Link", value: website_link, short: website_link == @no_website}
  fields << {title: "Resume Link", value: resume_link, short: resume_link == @no_resume}
  fields << {title: "Github Link", value: github_link, short: github_link == @no_github}
  fields
end

def update_chosen_participants(participants, status)
  participants.each do |participant|
    @reg_request_manager.update_participant_status(participant['role']['id'], status)
  end
end


def all_participant_ids_for_event
  @reg_request_manager.participant_ids_for_event(@bot_season, @bot_year, @bot_event)
end
