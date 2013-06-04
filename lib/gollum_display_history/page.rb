# -*- encoding: utf-8 -*-
module Gollum
  class GollumDisplayHistoryPage < Gollum::Page
    include Pagination

    Wiki.page_class = self

    def initialize(wiki)
      @wiki = wiki
    end

    #各ページのcommit履歴をcommit日時降順で取得
    def get_versions
      commits = Array.new
      @wiki.pages().each { |page|
        page = @wiki.page(page.name)
        page.versions.each { |v|
          @left_diff_line_number = 0
          @right_diff_line_number = 0
          commit = {
            :id                      => v.id,
            :short_id                => v.id.slice(0,7),
            :authored_date           => v.authored_date,
	    :authored_formatted_date => v.authored_date.strftime("%b %d, %Y"),
	    :page                    => page.name,
	    :author_name             => v.author.name,
	    :author_email            => v.author.email,
	    :committer_name          => v.committer.name,
	    :committer_email         => v.committer.email,
	    :full_diff               => @wiki.full_reverse_diff(v),
	    :full_diff_lines         => get_formatted_diff(@wiki.full_reverse_diff(v)),
	    :version                 => v
	  }
          commits.push(commit)
	}
      }
      #authored_date降順でsort
      commits.sort!{|a,b|b[:authored_date] <=> a[:authored_date]}
      commits
    end

    # commitのdiffを画面表示用にフォーマットする
    def get_formatted_diff(full_diff)
      lines = []
      if full_diff.split("\n").length<3
	return lines
      end
      full_diff.split("\n")[4..-1].each_with_index do |line, line_index|
        lines << { :line  => line,
                   :class => line_class(line),
                   :ldln  => left_diff_line_number(0, line),
                   :rdln  => right_diff_line_number(0, line) }
      end if full_diff
      lines
    end

    # 画面にdiff表示する際に必要なCSSのクラス名を返す
    def line_class(line)
      if line =~ /^@@/
        'gc'
      elsif line =~ /^\+/
        'gi'
      elsif line =~ /^\-/
        'gd'
      else
        ''
      end
    end

    # commit前(左列)の行番号を求める
    def left_diff_line_number(id, line)
      if line =~ /^@@/
        m, li = *line.match(/\-(\d+)/)
        @left_diff_line_number = li.to_i
        @current_line_number = @left_diff_line_number
        ret = '...'
      elsif line[0] == ?-
        ret = @left_diff_line_number.to_s
        @left_diff_line_number += 1
        @current_line_number = @left_diff_line_number - 1
      elsif line[0] == ?+
        ret = ' '
      else
        ret = @left_diff_line_number.to_s
        @left_diff_line_number += 1
        @current_line_number = @left_diff_line_number - 1
      end
      ret
    end

    # commit後(右列)の行番号を求める
    def right_diff_line_number(id, line)
      if line =~ /^@@/
        m, ri = *line.match(/\+(\d+)/)
        @right_diff_line_number = ri.to_i
        @current_line_number = @right_diff_line_number
        ret = '...'
      elsif line[0] == ?-
        ret = ' '
      elsif line[0] == ?+
        ret = @right_diff_line_number.to_s
        @right_diff_line_number += 1
        @current_line_number = @right_diff_line_number - 1
      else
        ret = @right_diff_line_number.to_s
        @right_diff_line_number += 1
        @current_line_number = @right_diff_line_number - 1
      end
      ret
    end
  end
end
