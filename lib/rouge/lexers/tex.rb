module Rouge
  module Lexers
    class TeX < RegexLexer
      desc "The TeX typesetting system"
      tag 'tex'
      aliases 'TeX', 'LaTeX', 'latex'

      filenames '*.tex', '*.aux', '*.toc'
      mimetypes 'text/x-tex', 'text/x-latex'

      def self.analyze_text(text)
        return 1 if text =~ /\A\s*\\documentclass/
        return 1 if text =~ /\A\s*\\input/
        return 1 if text =~ /\A\s*\\documentstyle/
        return 1 if text =~ /\A\s*\\relax/
      end

      command = /\\([a-z]+|\s+|.)/i

      state :general do
        rule /%.*$/, Comment
        rule /[{}&_^]/, Punctuation
      end

      state :root do
        rule /\\\[/, Punctuation, :displaymath
        rule /\\\(/, Punctuation, :inlinemath
        rule /\$\$/, Punctuation, :displaymath
        rule /\$/, Punctuation, :inlinemath
        rule /\\(begin|end)\{.*?\}/, Name::Tag

        rule /(\\verb)\b(\S)(.*?)(\2)/ do |m|
          group Name::Builtin
          group Keyword::Pseudo
          group Str::Other
          group Keyword::Pseudo
        end

        rule command, Keyword, :command
        mixin :general
        rule /[^\\$%&_^{}]+/, Text
      end

      state :math do
        rule command, Name::Variable
        mixin :general
        rule /[0-9]+/, Num
        rule /[-=!+*\/()\[\]]/, Operator
        rule /[^=!+*\/()\[\]\\$%&_^{}0-9-]+/, Name::Builtin
      end

      state :inlinemath do
        rule /\\\)/, Punctuation, :pop!
        rule /\$/, Punctuation, :pop!
        mixin :math
      end

      state :displaymath do
        rule /\\\]/, Punctuation, :pop!
        rule /\$\$/, Punctuation, :pop!
        rule /\$/, Name::Builtin
        mixin :math
      end

      state :command do
        rule /\[.*?\]/, Name::Attribute
        rule /\*/, Keyword
        rule(//) { pop! }
      end
    end
  end
end
