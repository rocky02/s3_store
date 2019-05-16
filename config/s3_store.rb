# This class contains methods and constants to be used throughout 
# the application among all classes and modules.
class S3Store
 
  @@root ||= Dir.pwd
  
  def self.root
    @@root
  end
end
