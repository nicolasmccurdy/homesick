# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Homesick::RepoFinder do
  let(:home) { create_construct }
  after { home.destroy! }

  let(:homesick) { Homesick.new }

  it 'should determine if the given path represents a root directory' do
    expect(Homesick::RepoFinder.root_directory? '.').to be_false
    expect(Homesick::RepoFinder.root_directory? '/').to be_true
  end
  
  it 'should find the git root directory given a path inside the repo' do
    expect(Homesick::RepoFinder.find_git_repo '.').to match(/homesick\z/)
    expect(Homesick::RepoFinder.find_git_repo 'lib').to match(/homesick\z/)
    expect(Homesick::RepoFinder.find_git_repo '/').to be_nil
  end

  it 'should create a new Grit::Repo instance for the repo that has the ' \
     'given path' do
    expect(Homesick::RepoFinder.find_grit_repo '.').to be_a Grit::Repo
    expect(Homesick::RepoFinder.find_grit_repo 'lib').to be_a Grit::Repo
    expect(Homesick::RepoFinder.find_grit_repo '/').to be_nil
  end
end
