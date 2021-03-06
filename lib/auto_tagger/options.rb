module AutoTagger
  class Options

    def self.from_command_line(args)
      options = {}
      args.extend(::OptionParser::Arguable)
      args.options do |opts|
        opts.banner = [
          "",
          "  USAGE: autotag command [stage] [options]",
          "",
          "  Examples:",
          "",
          "    autotag help",
          "    autotag version",
          "    autotag create demo",
          "    autotag create demo .",
          "    autotag create demo ../",
          "    autotag create ci /data/myrepo",
          "    autotag create ci /data/myrepo --fetch-refs=false --push-refs=false",
          "    autotag create ci /data/myrepo --offline",
          "    autotag create ci /data/myrepo --dry-run",
          "",
          "    autotag list demo",
          "",
          "    autotag cleanup demo --refs-to-keep=2",
          "    autotag cleanup demo --refs-to-keep=2",
          "    autotag delete_locally demo",
          "    autotag delete_on_remote demo",
          "",
          "",
        ].join("\n")

        common_options(opts, options)

        opts.on("--opts-file OPTS_FILE",
                "full path to the opts file",
                "Defaults to working directory's .auto_tagger file",
                "Example: /usr/local/.auto_tagger") do |o|
          options[:opts_file] = o
        end

        opts.on_tail("-h", "--help", "-?", "You're looking at it.") do
          options[:show_help] = true
          options[:command] = :help
        end

        opts.on_tail("--version", "-v", "Show version") do
          options[:show_version] = true
          options[:command] = :version
        end

      end.parse!

      case args.first.to_s.downcase
        when "config"
          options[:command] = :config
        when "version"
          options[:show_version] = true
          options[:command] = :version
        when "help"
          options[:show_help] = true
          options[:help_text] = args.options.help
          options[:command] = :help
        when ""
          if options[:show_version]
            options[:command] = :version
          else
            options[:show_help] = true
            options[:help_text] = args.options.help
            options[:command] = :help
          end
        when "cleanup"
          options[:command] = :cleanup
          options[:stage] = args[1]
        when "delete_locally"
          options[:command] = :delete_locally
          options[:stage] = args[1]
        when "delete_on_remote"
          options[:command] = :delete_on_remote
          options[:stage] = args[1]
        when "list"
          options[:command] = :list
          options[:stage] = args[1]
        when "create"
          options[:command] = :create
          options[:stage] = args[1]
          options[:path] = args[2]
        else
          if options[:command].nil?
            options[:command] = :create # allow 
            options[:deprecated] = true
            options[:stage] = args[0]
            options[:path] = args[1]
          end
      end

      options
    end

    def self.from_file(args)
      options = {}
      args.extend(::OptionParser::Arguable)
      args.options do |opts|
        common_options(opts, options)
      end.parse!
      options
    end

    private

    def self.common_options(opts, options)

      opts.on("--date-separator SEPARATOR",
              "Sets the separator of the date part of the ref",
              "Defaults to ''") do |o|
        options[:date_separator] = o
      end

      opts.on("--fetch-refs FETCH_REFS", TrueClass,
              "Whether or not to fetch tags before creating the tag",
              "Defaults to true") do |o|
        options[:fetch_refs] = o
      end

      opts.on("--push-refs PUSH_REFS", TrueClass,
              "Whether or not to push tags after creating the tag",
              "Defaults to true") do |o|
        options[:push_refs] = o
      end

      opts.on("--remote REMOTE",
              "specify the git remote",
              "Defaults to origin") do |o|
        options[:remote] = o
      end

      opts.on("--ref-path REF_PATH",
              "specify the ref-path",
              "Defaults to auto_tags") do |o|
        options[:ref_path] = o
      end

      opts.on("--stages STAGES",
              "specify a comma-separated list of stages") do |o|
        options[:stages] = o
      end

      opts.on("--offline [OFFLINE]", FalseClass,
              "Same as --fetch-refs=false and --push-refs=false") do |o|
        options[:offline] = o
      end

      opts.on("--dry-run [DRYRUN]", TrueClass,
              "doesn't execute anything, but logs what it would run") do |o|
        options[:dry_run] = o.nil? || (o == true)
      end

      opts.on("--verbose [VERBOSE]", TrueClass,
              "logs all commands") do |o|
        options[:verbose] = o
      end

      opts.on("--refs-to-keep REFS_TO_KEEP",
              "logs all commands") do |o|
        options[:refs_to_keep] = (o ? o.to_i : nil)
      end

      opts.on("--executable EXECUTABLE",
              "the full path to the git executable",
              "Defaults to git (and assumes git is your path)",
              "Example: /usr/local/bin/git") do |o|
        options[:git] = o
      end
    end

  end
end