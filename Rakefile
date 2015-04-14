SCHEME = ENV['SCHEME'] || 'graphPON'
SDK    = 'iphonesimulator8.3'

desc 'clean build'
task :clean do
  success = system %(set -o pipefail &&
                    xcodebuild clean -scheme #{SCHEME} -sdk #{SDK} ONLY_ACTIVE_ARCH=NO |
                    xcpretty -c)
  exit! success unless success
end

desc 'test build'
task :test do
  success = system %(set -o pipefail &&
                     xcodebuild test -scheme #{SCHEME} -sdk #{SDK} ONLY_ACTIVE_ARCH=NO |
                     xcpretty -c)
  exit! success unless success
end

task default: %w[clean test]
