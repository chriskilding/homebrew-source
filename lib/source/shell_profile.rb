# frozen_string_literal: true

module Source
    ##
    # Support functions for parsing shell profiles (.rc, .bashrc, .zshrc and so on).
    class ShellProfile

        ##
        # content is expected to be along the lines of a file (a StringIO or string array also work)
        def initialize(content)
            @content = content
        end

        ##
        # Determine whether str contains a 'source' directive for the specified shell functions script
        def self.includes_source_directive?(str, shell_functions_script)
            str =~ /^[^#]*(source|\.)\s+#{shell_functions_script}(#.*|\s.*|\b)$/
        end

        ##
        # Scan the shell profile for the expected files, and output which files are not 'source'd.
        def unsourced_files(*files_to_source)
            # 1. Converts to set (to ensure element uniqueness)
            # 2. Ensures data is copied (to avoid mutating the original)
            missing_directives = files_to_source.to_set

            @content.each do |line|
                missing_directives.each do |directive|
                    if Source::ShellProfile.includes_source_directive?(line, directive)
                        missing_directives.delete directive
                    end
                end
            end

            missing_directives
        end

        ##
        # Add 'source' directives for each of the specified files to the shell profile.
        # Deduplicates the files_to_source before performing any operations.
        def add_source_directives(*files_to_source)
            f = files_to_source.to_set

            f.each do |file_to_source|
                @content.write(". #{file_to_source}\n")
            end
        end
    end
end