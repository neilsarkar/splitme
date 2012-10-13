class String
  def self.random_alphanumeric(size = 16)
    (1..size).map { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
  end
end
