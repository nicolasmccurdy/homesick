require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'homesick'
require 'rspec'
require 'rspec/autorun'
require 'test_construct'
require 'tempfile'

RSpec.configure do |config|
  config.include TestConstruct::Helpers

  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.before { ENV['HOME'] = home.to_s }

  config.before { silence! }

  def silence!
    allow(homesick).to receive(:say_status)
  end

  def given_castle(path, subdirs = [])
    name = Pathname.new(path).basename
    castles.directory(path) do |castle|
      Dir.chdir(castle) do
        repo = Rugged::Repository.init_at '.'
        repo.config['user.email'] = 'test@test.com'
        repo.config['user.name'] = 'Test Name'
        Rugged::Remote.add(repo, 'origin', "git://github.com/technicalpickles/#{name}.git")
        if subdirs
          subdir_file = castle.join(Homesick::SUBDIR_FILENAME)
          subdirs.each do |subdir|
            File.open(subdir_file, 'a') { |file| file.write "\n#{subdir}\n" }
          end
        end
        return castle.directory('home')
      end
    end
  end
end
