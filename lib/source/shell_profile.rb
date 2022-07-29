# frozen_string_literal: true

module Source
    ##
    # Support functions for parsing shell profiles (.rc, .bashrc, .zshrc and so on).
    class ShellProfile

        ##
        # Determine whether str contains a 'source' directive for the specified shell functions script
        def self.includes_source_directive?(str, shell_functions_script)
            str =~ /^[^#]*(source|\.)\s+#{shell_functions_script}(#.*|\s.*|\b)$/
        end

        ##
        # Scan the provided rc file for the expected 'source' directives, and output which ones are missing from it.
        def self.missing_source_directives(rc, files_to_source=[])
            # 1. Convert to set (to ensure element uniqueness)
            # 2. Ensures data is copied (to avoid mutating the original)
            missing_directives = files_to_source.to_set

            rc.each do |line|
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