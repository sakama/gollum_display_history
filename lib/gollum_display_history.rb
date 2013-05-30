# external
require 'sinatra/base'
require 'sinatra/contrib'
require 'gollum-lib'

# internal
require "gollum_display_history/version"
require 'gollum_display_history/wiki'
require 'gollum_display_history/page'

module Sinatra
  module GollumDisplayHistory

    def display_global_history
      wiki = Gollum::Wiki.new(".git", :base_path => "/root/repos")
      page = wiki.page('home')
      page.get_versions
    end
  end

  helpers GollumDisplayHistory
end
