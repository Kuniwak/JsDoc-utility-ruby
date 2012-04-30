# This script licensed under the MIT.
# http://orgachem.mit-license.org

# This script can works on above directory structure.
#
# {ProjectRoot} / *.js
#               / tools / jsdoc.rb (This script)
#
# Or, you can set another input directory name with -i.
#
# The documentation will be create {ProjectRoot} / docs.
# You can set another output directory name with -o.

# Arguments processing module
require 'optparse'

# Absolute path of directory including this script
SCRIPT_DIR_PATH = File.dirname(File.expand_path(__FILE__))

# Add goog.events.EventTarget and goog.Disposable
CLOSURE_LIB_PATH = '/opt/closure-library-read-only/closure/goog'

# Absolute path of Root directory
ROOT_DIR_PATH = SCRIPT_DIR_PATH + "/.."

# Absolute path of Jsdoc
JSDOC_DIR = ENV["JSDOCDIR"] || "/opt/jsdoc-toolkit"

# Absolute path of Jsdoc Base dir
BASE_DIR = JSDOC_DIR

# Absolute path of run.js
JSDOC_JS = JSDOC_DIR + "/app/run.js"

# Absolute path of jsrun.jar
JSDOC_JAR = JSDOC_DIR + "/jsrun.jar"

# Absolute path of Template
#TEMPLATE_DIR = ENV["JSDOCTEMPLATEDIR"]
TEMPLATE_DIR = JSDOC_DIR + "/templates/aias-frame"

search_depth = nil
show_private = false
visible_private = false
input_dir = ""
output_dir = "docs"
visible_goog = false

# Arguments processing
opt = OptionParser.new()
opt.on('-a', '--allfunctions', 'Include all functions, even undocumented ones.') {show_private = true}
opt.on('-r', '--recurse <DEPTH>', 'Descend into src directories.') {|v| search_depth = v} 
opt.on('-p', '--private', 'Include symbols tagged as private, underscored and inner symbols.') {visible_private = true} 
opt.on('-o', '--output <OUTPUT_DIR>', 'Output to this directory (defaults to "docs").') {|v| output_dir = v} 
opt.on('-i', '--input <INPUT_DIR>', 'Intput to this directory.') {|v| input_dir = v} 
opt.on('-g', '--goog', 'Output with basic class defind on Closure library') {visible_goog = true} 
argv = opt.parse!(ARGV)

input_dir_abs = "#{ROOT_DIR_PATH}/#{input_dir}"
output_dir_abs = "#{ROOT_DIR_PATH}/#{output_dir}"

# Create new directory, if output directory is not exists.
if !Dir.exist?(output_dir_abs)
	Dir.mkdir(output_dir_abs)
end

# Add basic class in Closure library
js_list = []
js_list.push(CLOSURE_LIB_PATH + "/events/eventtarget.js")
js_list.push(CLOSURE_LIB_PATH + "/disposable/disposable.js")
js_list.push(CLOSURE_LIB_PATH + "/disposable/idisposable.js")

# Options of JavaScriptDoc
# See: 
#  http://code.google.com/p/jsdoc-toolkit/wiki/CommandlineOptions
# Refer_ja:
#  http://www12.atwiki.jp/aias-jsdoctoolkit/pages/54.html
cmd = [
	"java",
	"-Djsdoc.dir=#{JSDOC_DIR}",
	"-jar #{JSDOC_JAR}",
	"#{JSDOC_JS}",
	'-D=lang:en',
	"--template=#{TEMPLATE_DIR}",
	"--directory=#{output_dir_abs}",
	"--exclude=docs/.*",
	show_private ? "--allfunctions" : "",
	visible_private ? "--private" : "",
	search_depth ? "--recurse=#{search_depth}" : "",
	input_dir_abs,
	visible_goog ? js_list.join(" ") : ""
].join(" ")

# Executes JsDoc and prints the result
puts `#{cmd}`

# Alert by Glowlnotify
`growlnotify -t "JavaScriptDoc" -m "Completed."`
