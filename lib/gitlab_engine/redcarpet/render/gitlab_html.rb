class Redcarpet::Render::GitlabHTML < Redcarpet::Render::HTML
  def block_code(code, language)
    if Pygments::Lexer.find(language)
      Pygments.highlight(code, :lexer => language, :options => {:encoding => 'utf-8'}) rescue code
    else
      Pygments.highlight(code, :options => {:encoding => 'utf-8'}) rescue code
    end
  end
end
