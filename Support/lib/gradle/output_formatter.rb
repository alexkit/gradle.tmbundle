module Gradle
  class OutputFormatter
    def format(line, type)
      line.chomp!
      line = "<span style=\"#{type == :err ? 'color: red' : ''}\">#{htmlize(line)}</span>"

      # Link individual test failures to their xml report files
      line.sub! /Test (.+) FAILED/, "Test <a href=\"javascript:TextMate.system('\\\\'#{ENV['TM_BUNDLE_SUPPORT']}/bin/open_test_result.rb\\\\' \\\\'\\1\\\\'')\">\\1</a> FAILED"

      # Italicise the task names
      line.sub! /^(<.+?>)((?::.+?)*:\S+)/, "\\1<span style='font-style: italic; color: LightSteelBlue'>\\2</span>"
      
      # Link compile error messages to the source
      line.sub! /^(<.+?>)(\/(?:.+?\/)+.+?\..+?):\s?(\d+)(.+)$/, "\\1<a href=\"javascript:TextMate.system('open \\\\'txmt://open/?url=file://\\2&line=\\3\\\\'')\">\\2:\\3</a>\\4"

      # Link test failures to the html report
      line.sub! /^(.+Cause: There were failing tests. See the report at )((?:\/.+)+)\.(.+)$/, "\\1<a href=\"javascript:TextMate.system('open \\\\'\\2/index.html\\\\'')\">\\2</a>.\\3"

      # Link build file errors
      line.sub! /^(<.+?>(?:Build file|Script) ')(.+)(')( line: (\d+))?/, "\\1<a href=\"javascript:TextMate.system('open \\\\'txmt://open/?url=file://\\2&line=\\5\\\\'')\">\\2</a>\\3\\4"
      
      # Colorise the UP-TO-DATE suffix
      line.sub! /UP-TO-DATE/, "<span style='color: Moccasin'>UP-TO-DATE</span>"

      # Colorise the UP-TO-DATE suffix
      line.sub! /SKIPPED/, "<span style='color: #ABFFE2'>UP-TO-DATE</span>"
      
      # Colorise the build status
      line.sub! /BUILD SUCCESSFUL/, "<span style='color: green; text-decoration: underline'>BUILD SUCCESSFUL</span>"
      line.sub! /BUILD FAILED/, "<span style='color: red; text-decoration: underline'>BUILD FAILED</span>"
      line
    end
  end
end 
