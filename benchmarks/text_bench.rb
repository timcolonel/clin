require 'benchmark/ips'
$LOAD_PATH.push File.expand_path('../..', __FILE__)
$LOAD_PATH.push File.expand_path('../../lib', __FILE__)
require 'clin'

values = ['Some value 1', 'Some value 2']
Benchmark.ips do |x|
  x.report('Normal <<') do
    t = ''
    t << 'Usage:' << "\n"
    t << '  display Message' << "\n"
    t << '  print Message' << "\n"
    t << '     --echo' << "\n"
    t << '     --verbose' << "\n"
    t << 'Description: ' << "\n"
    t << '   This is a description' << "\n"
    t << '' << "\n"
    t << 'Examples:' << "\n"
    t << 'Examples:' << "\n"
    t << ' -display Message' << "\n"
    t << ' -print Message' << "\n"
    t << 'Values: ' << "\n"
    values.each do |val|
      t << "***#{val}" << "\n"
    end
    t = 'You have an error!' + "\n" << t
  end

  x.report('Normal +=') do
    t = ''
    t += 'Usage:' + "\n"
    t += '  display Message' + "\n"
    t += '  print Message' + "\n"
    t += '     --echo' + "\n"
    t += '     --verbose' + "\n"
    t += 'Description: ' + "\n"
    t += '   This is a description' + "\n"
    t += '' + "\n"
    t += 'Examples:' + "\n"
    t += 'Examples:' + "\n"
    t += ' -display Message' + "\n"
    t += ' -print Message' + "\n"
    t += 'Values: ' + "\n"
    values.each do |val|
      t += "***#{val}" + "\n"
    end
    t = 'You have an error!' + "\n" + t
  end

  x.report('Text builder') do
    Clin::Text.new do |t|
      t.line 'Usage:'
      t.indent ' ' do
        t.line 'display Message'
        t.line 'print Message'

        t.indent '  ' do
          t.line '--echo'
          t.line '--verbose'
        end
      end
      t.line 'Description: '
      t.line 'This is a description', indent: '   '
      t.blank
      t.line 'Examples:'
      t.indent ' -' do
        t.line 'display Message'
        t.line 'print Message'
      end
      t.line 'Values: '
      t.lines values, indent: '*** '

      t.prefix 'You have an error!'
    end.to_s
  end

  x.compare!
end
