require 'jackal-github-kit'
require 'octokit'

describe Jackal::GithubKit::Hubber do
  REPO_NAME      = 'jackal-test-repo'
  COMMIT_COMMENT = 'Snazzy comment!'
  STATUS_STATE   = 'pending'

  before do
    @runner = run_setup(:test)
    @client = Octokit::Client.new(:access_token => access_token)
    @repo = @client.create_repository(REPO_NAME, :auto_init => true)
    @commit_sha = @client.commits(@repo[:id]).first[:sha]
  end

  after do
    @runner.terminate if @runner && @runner.alive?
    @client.delete_repository(@repo[:id])
  end

  let(:supervisor) do
    Carnivore::Supervisor.supervisor[:jackal_github_kit_input]
  end

  describe 'github api interaction' do
    it 'creates commit comment' do
      result = supervisor.transmit(payload(:commit))
      source_wait { !MessageStore.messages.empty? }

      comment = @client.commit_comments(@repo[:id], @commit_sha).first
      comment.body.must_equal(COMMIT_COMMENT)
    end

    it 'updates commit state' do
      result = supervisor.transmit(payload(:status))
      source_wait { !MessageStore.messages.empty? }

      commit = @client.commits(@repo[:id], @commit_sha)
      status = @client.statuses(@repo[:id], @commit_sha).first
      status[:state].must_equal(STATUS_STATE)
    end

  end

  private

  def access_token
    env_var = 'JACKAL_GITHUB_ACCESS_TOKEN'
    msg = "#{env_var} must be set (see config.test.rb for caveat)"
    token = ENV[env_var]
    raise msg unless token
    token
  end

  def payload(type = :commit)
    shared = { :repository => @repo[:full_name], :reference => @commit_sha}
    types = { :commit => { :commit_comment => shared.merge(:message => COMMIT_COMMENT) },
              :status => { :status => shared.merge(:state => STATUS_STATE ) } }
    Jackal::Utils.new_payload('test', { :github_kit => types[type] })
  end

end
