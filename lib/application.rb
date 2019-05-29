class Application

  def self.root
    @@root ||= Dir.pwd
  end
end
