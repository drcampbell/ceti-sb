class LoadZips < ActiveJob::Base
  def perform()
    f = File.read("zipcodes2013.txt")
    records = f.split("\n")
    cnames = Zipcode.column_names
    cnames = cnames[1..cnames.length]
    records.each do |r|
      if r.include? "ZIP"
        next
      end
      record = r.delete(' ').split(',')
      Zipcode.create!(Hash[cnames.zip record])
    end
  end
end
