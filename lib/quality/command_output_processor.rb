# frozen_string_literal: true
module Quality
  # Class processes output from a code quality command, tweaking it
  # for editor output and counting the number of violations found
  class CommandOutputProcessor
    attr_accessor :emacs_format
    attr_accessor :file
    attr_reader :found_output
    attr_reader :violations

    def initialize
      @emacs_format = false
      @found_output = false
      @violations = 0
    end

    def process(&count_violations_on_line)
      process_file(file, &count_violations_on_line)
    end

    private

    def process_file(file, &count_violations_on_line)
      out = ''
      while (@current_line = file.gets)
        out += process_line(&count_violations_on_line)
      end
      out
    end

    def process_line
      output =
        if emacs_format
          preprocess_line_for_emacs
        else
          @current_line
        end
      @found_output = true
      @violations += yield @current_line
      output
    end

    def preprocess_line_for_emacs
      if @current_line =~ /^ *(\S*.rb:[0-9]*) *(.*)/
        Regexp.last_match[1] + ': ' + Regexp.last_match[2] + "\n"
      elsif @current_line =~ /^ *(.*) +(\S*.rb:[0-9]*) *(.*)/
        Regexp.last_match[2] + ': ' + Regexp.last_match[1] + "\n"
      else
        @current_line
      end
    end
  end
end
