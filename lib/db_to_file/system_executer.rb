class SystemExecuter
  def initialize(command)
    self.command = command
  end

  def command=(command)
    @command = command
  end

  def execute
    `#{@command}`
  end
end
