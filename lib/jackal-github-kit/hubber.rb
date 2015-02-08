require 'jackal-github-kit'

module Jackal
  module GithubKit
    class Hubber < Callback

      # Setup callback
      def setup(*_)
        require 'octokit'
      end

      # Determine validity of message
      #
      # @param message [Carnivore::Message]
      # @return [Truthy, Falsey]
      def valid?(message)
        super do |payload|
          payload.get(:data, :github_kit, :commit_comment) ||
            payload.get(:data, :github_kit, :status)
        end
      end

      # @return [Octokit::Client]
      def github_client
        gh_conf = config.fetch(:github,
          app_config.get(:github)
        )
        memoize("github_client_#{gh_conf.checksum}") do
          Octokit::Client.new(gh_conf)
        end
      end

      # Add comment to GitHub commit SHA
      #
      # @param message [Carnivore::Message]
      def execute(message)
        failure_wrap(message) do |payload|
          write_commit_comment(payload) if(payload.get(:data, :github_kit, :commit_comment))
          write_status(payload) if(payload.get(:data, :github_kit, :status))
          job_completed(:github_kit, payload, message)
        end
      end

      # Write comment to GitHub SHA reference
      #
      # @param payload [Smash]
      # @return [TrueClass]
      def write_commit_comment(payload)
        comment = payload[:data][:github_kit].delete(:commit_comment)
        info 'Writing commit comment to GitHub'
        debug "GitHub commit comment: #{comment.inspect}"
        github_client.create_commit_comment(
          comment[:repository],
          comment[:reference],
          comment[:message]
        )
        true
      end

      # Write status of pull request to github
      #
      # @param payload [Smash]
      # @return [TrueClass]
      def write_status(payload)
        status = payload[:data][:github_kit].delete(:status)
        info 'Writing repository status to GitHub'
        debug "GitHub repository status: #{status.inspect}"
        github_client.create_status(
          status[:repository],
          status[:reference],
          status[:state].to_sym,
          status.fetch(:extras, Smash.new)
        )
        true
      end

    end
  end
end
