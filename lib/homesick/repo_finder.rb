# -*- encoding : utf-8 -*-
require 'grit'

class Homesick
  # Helper methods for finding the current git repository
  #
  # Based on https://github.com/mojombo/grit/pull/178 by https://github.com/derricks
  module RepoFinder
    extend self

    # Returns true if the given path represents a root directory (/ or C:/)
    def root_directory?(file_path)
      # Implementation inspired by http://stackoverflow.com/a/4969416:
      # Does file + ".." resolve to the same directory as file_path?
      File.directory?(file_path) && 
        File.expand_path(file_path) == File.expand_path(File.join(file_path, '..'))
    end

    # Returns the git root directory given a path inside the repo. Returns nil if
    # the path is not in a git repo.
    def find_git_repo(start_path = '.')
      raise NoSuchPathError unless File.exists?(start_path)

      current_path = File.expand_path(start_path)

      # for clarity: set to an explicit nil and then just return whatever
      # the current value of this variable is (nil or otherwise)
      return_path = nil

      until root_directory?(current_path)
        if File.exists?(File.join(current_path, '.git'))   
          # done
          return_path = current_path
          break
        else
          # go up a directory and try again
          current_path = File.dirname(current_path)
        end
      end
      return_path
    end

    # Returns a new Grit::Repo instance for the repo that has the given path.
    # Returns nil if the path is not in a git repo.
    def find_grit_repo(start_path = '.')
      path = find_git_repo start_path

      path.nil? ? nil : Grit::Repo.new(path)
    end
  end
end
