require "thor"
require "fontcustom"
require "fontcustom/watcher"

module Fontcustom
  class CLI < Thor
    # Actual defaults are stored in Fontcustom::DEFAULT_OPTIONS instead of Thor
    class_option :output, :aliases => "-o", :desc => "The output directory (will be created if it doesn't exist). Default: INPUT/fontcustom/"
    class_option :config, :aliases => "-c", :desc => "Path to or containing directory of fontcustom.yml (relative to PWD). Default: none" 
    class_option :templates, :aliases => "-t", :type => :array, :desc => "List of templates to compile alongside fonts. Accepts 'css', 'css-ie7', 'scss', 'preview' or arbitrary paths (relative to INPUT or PWD). Default: 'css preview'"
    class_option :font_name, :aliases => "-n", :desc => "The font name used in your templates (automatically normalized to lowercase spinal case). Default: 'fontcustom'"
    class_option :file_hash, :aliases => "-h", :type => :boolean, :desc => "Generate font files with asset-busting hashes. Default: true"
    class_option :css_prefix, :aliases => "-p", :desc => "The prefix for each glyph's CSS class. Default: 'icon-'"
    class_option :debug, :aliases => "-d", :type => :boolean, :desc => "Display debug messages from fontforge. Default: false"
    class_option :verbose, :aliases => "-v", :type => :boolean, :desc => "Display output messages. Default: true"

    desc "compile [INPUT]", "Generates webfonts and CSS from *.svg and *.eps files in INPUT."
    def compile(input)
      opts = options.merge :input => input
      opts = Fontcustom::Util.collect_options opts
      Fontcustom::Generator::Font.start [opts]
      Fontcustom::Generator::Template.start [opts]
    rescue Fontcustom::Error => e
      puts "ERROR: #{e.message}"
    end

    desc "watch [INPUT]", "Watches INPUT for changes and regenerates webfonts and CSS automatically. Ctrl + C to stop."
    method_option :first, :aliases => "-f", :type => :boolean, :default => false, :desc => "Compile immediately upon watching. Default: false"
    def watch(input)
      opts = options.merge :input => input, :first => options[:first]
      opts = Fontcustom::Util.collect_options opts
      Fontcustom::Watcher.new(opts).watch
    rescue Fontcustom::Error => e
      puts "ERROR: #{e.message}"
    end

    desc "version", "Shows the version information."
    def version
      puts "fontcustom-#{Fontcustom::VERSION}"
    end
  end
end
