module Source

    ##
    # Ensures the end state of the shell profile matches what we want.
    # (This is a concept borrowed from configuration management systems like Puppet.)
    class ShellProfileConverger

        def initialize(shell_profile)
            @shell_profile = shell_profile
        end

        ##
        # Ensure the presence of 'source' directives for the specified files.
        def ensure_source_directives_for(*files)
            the_unsourced_files = unsourced_files(files)
    
            if the_unsourced_files.empty?
                # the shell functions are already sourced, so no need to take action
                return
            end
    
            add_source_directives(the_unsourced_files)
        end

        def unsourced_files(files_to_source)
            u = []
    
            File.open(@shell_profile, 'r') do |f|
                rc = Source::ShellProfile.new(f)
                u = rc.unsourced_files(*files_to_source)
            end

            u
        end

        def add_source_directives(unsourced_files)
            File.open(@shell_profile, 'a') do |f|
                rc = Source::ShellProfile.new(f)
                rc.add_source_directives(*unsourced_files)
            end
        end
    end
end