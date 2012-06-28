module GitlabEngine
  module CommitsHelper
    def commit_msg_with_link_to_issues(project, message)
      return '' unless message
      out = ''
      message.split(/(#[0-9]+)/m).each do |m|
        if m =~ /(#([0-9]+))/m
          begin
            issue = project.issues.find($2)
            out += link_to($1, gitlab_engine.project_issue_path(project, $2))
          rescue
            out += $1
          end
        else
          out += m
        end
      end
      preserve out
    end

    def identification_type(line)
      if line[0] == "+"
        "new"
      elsif line[0] == "-"
        "old"
      else
        nil
      end
    end

    def build_line_anchor(index, line_new, line_old)
      "#{index}_#{line_old}_#{line_new}"
    end

    def each_diff_line(diff_arr, index)
      line_old = 1
      line_new = 1
      type = nil

      lines_arr = diff_arr
      lines_arr.each do |line|
        next if line.match(/^\-\-\- \/dev\/null/)
        next if line.match(/^\+\+\+ \/dev\/null/)
        next if line.match(/^\-\-\- a/)
        next if line.match(/^\+\+\+ b/)

        full_line = html_escape(line.gsub(/\n/, ''))

        if line.match(/^@@ -/)
          type = "match"

          line_old = line.match(/\-[0-9]*/)[0].to_i.abs rescue 0
          line_new = line.match(/\+[0-9]*/)[0].to_i.abs rescue 0

          next if line_old == 1 && line_new == 1 # top of file
          yield(full_line, type, nil, nil, nil)
          next
        else
          type = identification_type(line)
          line_code = build_line_anchor(index, line_new, line_old)
          yield(full_line, type, line_code, line_new, line_old)
        end


        if line[0] == "+"
          line_new += 1
        elsif line[0] == "-"
          line_old += 1
        else
          line_new += 1
          line_old += 1
        end
      end
    end

    def image_diff_class(diff)
      if diff.deleted_file
        "diff_image_removed"
      elsif diff.new_file
        "diff_image_added"
      else
        nil
      end
    end
  end
end
