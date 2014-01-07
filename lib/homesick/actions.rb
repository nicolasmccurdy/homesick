# -*- encoding : utf-8 -*-
class Homesick
  module Actions
    # TODO move this to be more like thor's template, empty_directory, etc
    def git_clone(repo, config = {})
      config ||= {}
      destination = config[:destination] || File.basename(repo, '.git')

      destination = Pathname.new(destination) unless destination.kind_of?(Pathname)
      FileUtils.mkdir_p destination.dirname

      if ! destination.directory?
        smart_say_status 'git clone', "#{repo} to #{destination.expand_path}", :green
        smart_system "git clone -q --config push.default=upstream --recursive #{repo} #{destination}"
      else
        smart_say_status :exist, destination.expand_path, :blue
      end
    end

    def git_init(path = '.')
      path = Pathname.new(path)

      inside path do
        if !path.join('.git').exist?
          smart_say_status 'git init', ''
          smart_system 'git init >/dev/null'
        else
          smart_say_status 'git init', 'already initialized', :blue
        end
      end
    end

    def git_remote_add(name, url)
      existing_remote = `git config remote.#{name}.url`.chomp
      existing_remote = nil if existing_remote == ''

      if !existing_remote
        smart_say_status 'git remote', "add #{name} #{url}"
        smart_system "git remote add #{name} #{url}"
      else
        smart_say_status 'git remote', "#{name} already exists", :blue
      end
    end

    def git_submodule_init(config = {})
      smart_say_status 'git submodule', 'init', :green
      smart_system 'git submodule --quiet init'
    end

    def git_submodule_update(config = {})
      smart_say_status 'git submodule', 'update', :green
      smart_system 'git submodule --quiet update --init --recursive >/dev/null 2>&1'
    end

    def git_pull(config = {})
      smart_say_status 'git pull', '', :green
      smart_system 'git pull --quiet'
    end

    def git_push(config = {})
      smart_say_status 'git push', '', :green
      smart_system 'git push'
    end

    def git_commit_all(config = {})
      smart_say_status 'git commit all', '', :green
      if config[:message]
        smart_system "git commit -a -m '#{config[:message]}'"
      else
        smart_system 'git commit -v -a'
      end
    end

    def git_add(file, config = {})
      smart_say_status 'git add file', '', :green
      smart_system "git add '#{file}'"
    end

    def git_status(config = {})
      smart_say_status 'git status', '', :green
      smart_system "git status"
    end

    def git_diff(config = {})
      smart_say_status 'git diff', '', :green
      smart_system "git diff"
    end

    def mv(source, destination, config = {})
      source = Pathname.new(source)
      destination = Pathname.new(destination + source.basename)

      if destination.exist?
        smart_say_status :conflict, "#{destination} exists", :red

        if options[:force] || shell.file_collision(destination) { source }
          system "mv '#{source}' '#{destination}'" unless options[:pretend]
        end
      else
        # this needs some sort of message here.
        smart_system "mv '#{source}' '#{destination}'"
      end
    end

    def rm_link(target)
      target = Pathname.new(target)

      if target.symlink?
        smart_say_status :unlink, "#{target.expand_path}", :green
        FileUtils.rm_rf target
      else
        smart_say_status :conflict, "#{target} is not a symlink", :red
      end
    end

    def rm(file)
      smart_say_status "rm #{file}", '', :green
      system "rm #{file}" if File.exists?(file)
    end

    def rm_rf(dir)
      smart_say_status "rm -rf #{dir}", '', :green
      system "rm -rf #{dir}"
    end

    def rm_link(target)
      target = Pathname.new(target)

      if target.symlink?
        smart_say_status :unlink, "#{target.expand_path}", :green
        FileUtils.rm_rf target
      else
        smart_say_status :conflict, "#{target} is not a symlink", :red
      end
    end

    def rm(file)
      smart_say_status "rm #{file}", '', :green
      system "rm #{file}"
    end

    def rm_r(dir)
      smart_say_status "rm -r #{dir}", '', :green
      system "rm -r #{dir}"
    end

    def ln_s(source, destination, config = {})
      source = Pathname.new(source)
      destination = Pathname.new(destination)
      FileUtils.mkdir_p destination.dirname

      if destination.symlink?
        if destination.readlink == source
          smart_say_status :identical, destination.expand_path, :blue
        else
          smart_say_status :conflict, "#{destination} exists and points to #{destination.readlink}", :red

          if options[:force] || shell.file_collision(destination) { source }
            system "ln -nsf '#{source}' '#{destination}'" unless options[:pretend]
          end
        end
      elsif destination.exist?
        smart_say_status :conflict, "#{destination} exists", :red

        if options[:force] || shell.file_collision(destination) { source }
          smart_system "rm -rf '#{destination}'"
          smart_system "ln -sf '#{source}' '#{destination}'"
        end
      else
        smart_say_status :symlink, "#{source.expand_path} to #{destination.expand_path}", :green
        smart_system "ln -s '#{source}' '#{destination}'"
      end
    end
  end
end
