module Gollum
  class GollumDisplayHistoryPage < Gollum::Page
    include Pagination

    Wiki.page_class = self

    def initialize(wiki)
      @wiki = wiki
      Gollum::Markup.register(:angry, "Angry") do |content|
	content.upcase
      end
    end

    #各ページのcommit履歴をcommit日時降順で取得
    def get_versions
      commits = Array.new
      pages =  @wiki.pages()
      pages.each { |page|
        page = @wiki.page(page.name)
        page.versions.each { |version|
          commit = {
            :authored_date => version.authored_date,
	    :page          => page.name,
	    :version       => version
	  }
          commits.push(commit)
	}
      }
      #authored_date降順でsort
      commits.sort!{|a,b|b[:authored_date] <=> a[:authored_date]}
    end
  end
end
