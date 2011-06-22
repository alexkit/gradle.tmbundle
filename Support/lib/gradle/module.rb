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
    
    def test_single(file = ENV['TM_SELECTED_FILE'])
      if file.nil?
        puts "No file selection"
        exit 1
      end
      
      task = test_task_for_file(file)
      run(task, test_single_arg(file, task))
    end
    
    def test_task_for_file(file = ENV['TM_SELECTED_FILE'])
      calculate_source_root(file)
    end
    
    def calculate_source_root(file = ENV['TM_SELECTED_FILE'])
      module_relative = module_relative_path(file)
      if module_relative =~ /src\/(\w+)\/.+/
        $1
      else
        raise "cannot determine source root for ‘#{file}’ as it is not under the module relative path of ‘src/«root»’"
      end
    end
    
    def module_relative_path(file = ENV['TM_SELECTED_FILE'])
      if file.start_with? @path
        file.sub /^@path\//, ""
      else
        raise "cannot get module relative path of ‘#{file}’ as it is not a child of ‘#{@path}’"
      end
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
    
    private
    
    def test_single_arg(file, task) 
      clazz = File.basename(file, File.extname(file))
      prefix = @name.empty? ? "" : ":#{@name}:"
      "-D#{prefix}#{task}.single=#{clazz}"
    end
    
  end
  
end