module SlackRubyBot
  module Commands
    class HelpCommand < Base
      help do
        title 'help'
        desc 'Shows help information.'
      end

      command 'help' do |client, data, match|
        command = match[:expression]

        text = if command.present?
                 CommandsHelper.instance.command_full_desc(command)
               else
                 general_text
               end

        client.say(channel: data.channel, text: text)
      end

      class << self
        private

        def general_text
          bot_desc = CommandsHelper.instance.bot_desc_and_commands
          other_commands_descs = CommandsHelper.instance.other_commands_descs
          <<TEXT
#{bot_desc.join("\n")}


TEXT
        end
      end
    end
  end
end
