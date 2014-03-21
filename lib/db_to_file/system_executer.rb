module DbToFile
  class SystemExecuter
    def initialize(command)
      self.command = command
    end

    def command=(command)
      @command = command
    end

    def execute
      puts "Execute command: #{@command}"
      `#{@command}`
    end
  end
end
