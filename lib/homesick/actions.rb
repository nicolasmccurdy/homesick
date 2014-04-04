# -*- encoding : utf-8 -*-
require 'rugged'

class Homesick
  # Git-related and file-related helper methods for the Homesick class
  module Actions
    # TODO: move this to be more like thor's template, empty_directory, etc

    def rugged_repo(*args)
      Rugged::Repository.new Rugged::Repository.discover(*args)
    end

    def git_clone(repo, config = {})
      config ||= {}
      destination = config[:destination] || File.basename(repo, '.git')

      destination = Pathname.new(destination) unless destination.kind_of?(Pathname)
      FileUtils.mkdir_p destination.dirname

      if destination.directory?
        say_status :exist, destination.expand_path, :blue unless options[:quiet]
      else
        say_status 'git clone',
                   "#{repo} to #{destination.expand_path}",
                   :green unless options[:quiet]
        system "git clone -q --config push.default=upstream --recursive #{repo} #{destination}" unless options[:pretend]
      end
    end

    def git_init(path = '.')
      path = Pathname.new(path)

      inside path do
        if path.join('.git').exist?
          say_status 'git init', 'already initialized', :blue unless options[:quiet]
        else
          say_status 'git init', '' unless options[:quiet]
          Rugged::Repository.init_at '.' unless options[:pretend]
        end
      end
    end

    def git_remote_add(name, url)
      existing_remote = rugged_repo.config["remote.#{name}.url"]
      existing_remote = nil if existing_remote == ''

      if existing_remote
        say_status 'git remote', "#{name} already exists", :blue unless options[:quiet]
      else
        say_status 'git remote', "add #{name} #{url}" unless options[:quiet]
        Rugged::Remote.add rugged_repo, name, url unless options[:pretend]
      end
    end

    def git_submodule_init(config = {})
      say_status 'git submodule', 'init', :green unless options[:quiet]
      system 'git submodule --quiet init' unless options[:pretend]
    end

    def git_submodule_update(config = {})
      say_status 'git submodule', 'update', :green unless options[:quiet]
      system 'git submodule --quiet update --init --recursive >/dev/null 2>&1' unless options[:pretend]
    end

    def git_pull(config = {})
      say_status 'git pull', '', :green unless options[:quiet]
      system 'git pull --quiet' unless options[:pretend]
    end

    def git_push(config = {})
      say_status 'git push', '', :green unless options[:quiet]
      system 'git push' unless options[:pretend]
    end

    def git_commit_all(config = {})
      say_status 'git commit all', '', :green unless options[:quiet]
      if config[:message]
        system "git commit -a -m '#{config[:message]}'" unless options[:pretend]
      else
        system 'git commit -v -a' unless options[:pretend]
      end
    end

    def git_add(file, config = {})
      say_status 'git add file', '', :green unless options[:quiet]
      system "git add '#{file}'" unless options[:pretend]
    end

    def git_status(config = {})
      say_status 'git status', '', :green unless options[:quiet]
      system 'git status' unless options[:pretend]
    end

    def git_diff(config = {})
      say_status 'git diff', '', :green unless options[:quiet]
      system 'git diff' unless options[:pretend]
    end

    def mv(source, destination, config = {})
      source = Pathname.new(source)
      destination = Pathname.new(destination + source.basename)

      if destination.exist?
        say_status :conflict, "#{destination} exists", :red unless options[:quiet]

        FileUtils.mv source, destination if (options[:force] || shell.file_collision(destination) { source }) && !options[:pretend]
      else
        # this needs some sort of message here.
        FileUtils.mv source, destination unless options[:pretend]
      end
    end

    def rm_rf(dir)
      say_status "rm -rf #{dir}", '', :green unless options[:quiet]
      FileUtils.rm_r dir, force: true
    end

    def rm_link(target)
      target = Pathname.new(target)

      if target.symlink?
        say_status :unlink, "#{target.expand_path}", :green unless options[:quiet]
        FileUtils.rm_rf target
      else
        say_status :conflict, "#{target} is not a symlink", :red unless options[:quiet]
      end
    end

    def rm(file)
      say_status "rm #{file}", '', :green unless options[:quiet]
      FileUtils.rm file, force: true
    end

    def rm_r(dir)
      say_status "rm -r #{dir}", '', :green unless options[:quiet]
      FileUtils.rm_r dir
    end

    def ln_s(source, destination, config = {})
      source = Pathname.new(source)
      destination = Pathname.new(destination)
      FileUtils.mkdir_p destination.dirname

      action = if destination.symlink? && destination.readlink == source
                 :identical
               elsif destination.symlink?
                 :symlink_conflict
               elsif destination.exist?
                 :conflict
               else
                 :success
               end

      handle_symlink_action action, source, destination
    end

    def handle_symlink_action(action, source, destination)
      case action
      when :identical
        say_status :identical, destination.expand_path, :blue unless options[:quiet]
      when :symlink_conflict
        say_status :conflict,
                   "#{destination} exists and points to #{destination.readlink}",
                   :red unless options[:quiet]

        FileUtils.rm destination
        FileUtils.ln_s source, destination, force: true unless options[:pretend]
      when :conflict
        say_status :conflict, "#{destination} exists", :red unless options[:quiet]

        if collision_accepted?
          FileUtils.rm_r destination, force: true unless options[:pretend]
          FileUtils.ln_s source, destination, force: true unless options[:pretend]
        end
      else
        say_status :symlink,
                   "#{source.expand_path} to #{destination.expand_path}",
                   :green unless options[:quiet]
        FileUtils.ln_s source, destination unless options[:pretend]
      end
    end
  end
end
