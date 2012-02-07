# Cucumber format for displaying list of scenarios
module BVT
  class ListScenarios
    def initialize(step_mother, io, options)
      @io = io
    end

    def scenario_name(keyword, name, file_colon_line, source_indent)
      @io.puts(file_colon_line)
    end
  end
end
