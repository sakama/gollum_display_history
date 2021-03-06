# -*- encoding: utf-8 -*-
# external
require 'sinatra/base'
require 'sinatra/contrib'
require 'gollum-lib'

# internal
require 'gollum_display_history/version'
require 'gollum_display_history/wiki'
require 'gollum_display_history/page'

module Sinatra
  module GollumDisplayHistory
    @@view_path = File.expand_path("../views/", __FILE__)
    @@template_engine = :haml
    
    def display_global_history
      wiki = Gollum::Wiki.new(".git", :base_path => @base_url)
      page = wiki.page("home")
      @base_url = url('/', false).chomp('/')
      @escaped_url_path = page.escaped_url_path
      @versions = page.get_versions
      send @@template_engine,  get_view_as_string("show.#{@@template_engine}")
    end

    private
      def get_view_as_string(filename)
        view = File.join(@@view_path, filename)
	data = ""
        f = File.open(view, "r")
        f.each_line do |line|
          data += line
        end
        return data
      end
  end
  helpers GollumDisplayHistory
end
