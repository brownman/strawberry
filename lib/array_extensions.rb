class Array
  require 'csv'
  def to_csv
    str = ''
    CSV::Writer.generate(str) do |csv|
      self.each do |r|
        csv << r
      end
    end
    str
  end
end
