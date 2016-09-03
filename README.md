# HackDuke Judging Bot

##Overview
This bot serves to facilitate pairwise judging of applicants and projects during HackDuke events. Judges will be asked to select between two choices, which is sent to an algorithm API that creates an ordered list over time. 

##Project Structure
- The command themselves can be found in src/judge_bot.rb
- Helper methods are in judge_leaderboard_handler.rb and judge_participant_handler.rb
- algorithm_request_manager.rb, registration_request_manager.rb, and judge_session_validator.rb are self-explanatory
- config.ru is the starting point for the application

##Getting Started
- use rbenv for ruby versioning (currently on 2.2.3)

```bash
$ cp ../hackduke-secrets/.env-hackduke-judging-bot .env  # assuming the projects share the same parent folder
$ bundle install                                         # Install project dependencies
$ bundle exec rackup                                     # Launch bot
```

##Merging changes
Make sure to squash all commits upon merge, using Github's "squash and merge" functionality. 

##Spacing
Please use 2 spaces to indent

##Deployment instructions
- currently using heroku for deployment
- run curl https://hackduke-judging-bot.herokuapp.com/start --user user:password to start bot
- run heroku ps:stop web to stop bot (may take a few seconds...)

##Applicant Status CSV instructions
- Run the update applicant status command on a local version of the slack bot
- CSV should appear in the public folder

## TODO
- Better development + deployment workflow
- Testing
- Continous integration
