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
        memoize(:github_client) do
          gh_conf = {
            :access_token => config.fetch(:github, :access_token,
              app_config.get(:github, :access_token)
            )
          }
          Octokit::Client.new(gh_conf)
        end
      end

      # Add comment to GitHub commit SHA
      #
      # @param message [Carnivore::Message]
      def execute(message)
        failure_wrap(message) do |payload|
          write_release(payload) if payload.get(:data, :github_kit, :release)
          write_commit_comment(payload) if payload.get(:data, :github_kit, :commit_comment)
          write_status(payload) if payload.get(:data, :github_kit, :status)
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

      # Write release to github
      #
      # @param payload [Smash]
      # @return [TrueClass]
      def write_release(payload)
        info 'Creating new release on GitHub'
        rel = payload[:data][:github_kit].delete(:release)
        release = github_client.create_release(
          rel[:repository],
          rel[:tag_name],
          :name => rel[:name],
          :target_commitish => rel[:reference],
          :prerelease => rel[:prerelease],
          :body => rel[:body]
        )

        api_release_url = release.rels[:self].href
        public_release_url = release.rels[:html].href

        info 'New release created on GitHub. Uploading assets.'
        rel[:assets].each do |asset|
          debug "Uploading release asset - #{asset}"
          github_client.upload_asset(
            api_release_url,
            asset_store.get(asset),
            :name => asset.sub(/^.+?_/, ''),
            :content_type => 'application/octet-stream'
          )
          debug "Completed release asset upload - #{asset}"
        end

        payload.set(:data, :github_kit, :release, :api_url, api_release_url)
        payload.set(:data, :github_kit, :release, :public_url, public_release_url)
        true
      end

    end
  end
end
