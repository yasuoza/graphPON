SCHEME = ENV['SCHEME'] || 'graphPON'

desc 'clean build'
task :clean do
  success = system %(set -o pipefail &&
                    xcodebuild clean -scheme #{SCHEME} -sdk iphonesimulator8.2 ONLY_ACTIVE_ARCH=NO |
                    xcpretty -c)
  exit! success unless success
end

desc 'test build'
task :test do
  success = system %(set -o pipefail &&
                     xcodebuild test -scheme #{SCHEME} -sdk iphonesimulator8.2 ONLY_ACTIVE_ARCH=NO |
                     xcpretty -c)
  exit! success unless success
end

task default: %w[clean test]
