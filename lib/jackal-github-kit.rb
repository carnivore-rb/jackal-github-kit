require 'jackal'

module Jackal
  module GithubKit
    autoload :Hubber, 'jackal-github-kit/hubber'
  end
end

require 'jackal-github-kit/version'

Jackal.service(
  :github_kit,
  :description => 'Interact with the GitHub API',
  :configuration => {
    :github__access_token => {
      :description => 'GitHub access token to use for API access'
    }
  }
)
