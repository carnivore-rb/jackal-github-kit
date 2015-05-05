Configuration.new do
  jackal do
    require [
      "carnivore-actor",
      "jackal-github-kit"
    ]

    github_kit do
      config do
        github do
          # Ensure this is an access token for a github account that you don't
          #   care about. We don't do anything destructive, but this token needs
          #   create / delete / comment privs on public repos. #pleasetobesecure
          access_token ENV['JACKAL_GITHUB_ACCESS_TOKEN']
        end
      end

      sources do
        input do
          type 'actor'
        end

        output do
          type 'spec'
        end
      end

      callbacks [ "Jackal::GithubKit::Hubber" ]
    end
  end
end
