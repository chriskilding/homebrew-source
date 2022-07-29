# frozen_string_literal: true

module Source
    ##
    # Support functions for parsing shell profiles (.rc, .bashrc, .zshrc and so on).
    class ShellProfile

        def initialize(content=[])
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
    end
end