def fixture_line(name)
  File.read(File.join(File.dirname(__FILE__), '../fixtures/lines', "#{name}.txt"))
end

def mt940_file(name = 'mt940')
  File.read(File.join(File.dirname(__FILE__), '../fixtures', "#{name}.txt"))
end
