module Gradle

  class Module 
    attr_reader :project, :path, :name, :prefix, :prefs
  
    def initialize(project, path, name)
      @project = project
      @path = path
      @name = name
      @prefs = Prefs.new(path)
    end
  
    def prefix_task(task) 
      @name.empty? ? task : "#{name}:#{task}"
    end
  
    def test_single_arg(file = ENV['TM_SELECTED_FILE']) 
      if file.nil?
        puts "No file selection"
        exit 1
      end

      clazz = File.basename(file, File.extname(file))
      prefix = @name.empty? ? "" : "#{@name}."
      "-D#{prefix}test.single=#{clazz}"
    end
  
    def test_single(file = ENV['TM_SELECTED_FILE'])
      run("test", test_single_arg(file))
    end
  
    def prompt_for_command_and_run
      previous = @prefs.get("prev_prompt")
      command = TextMate::UI.request_string(
        :title => "GradleMate", 
        :prompt => "Enter a gradle command" + (@name.empty? ? ' (for root module):' : " (for “#{@name}”):"), 
        :default => previous
      )
    
      if command.nil?
        puts "Command cancelled"
        false
      else
        @prefs.set("prev_prompt", command) unless command.nil?
        run_string(command)
        true
      end
    end

    def run_string(command)
      run(*Shellwords.shellwords(command))
    end
  
    def run(*args)
      prefixed_args = args.collect { |a| a[0..0] == "-" ? a : prefix_task(a) }
      @project.run(prefixed_args)
    end
  end
  
end